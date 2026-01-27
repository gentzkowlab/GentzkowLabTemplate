#!/usr/bin/env bash
#
# sync_inputs.sh
#
# Syncs external files (figures, tables, etc.) from remote Git repositories into
# the local input/ directory, as specified in setup/inputs.spec. Generates setup/inputs.lock to track what was copied.
#
# Note: This script deletes the entire input/ directory at the start to ensure
# all inputs are fresh and come from the spec file. If you need to manually add files,
# place them in raw/ instead of input/.
#
set -euo pipefail

# Detect repository root using git
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo '')"
if [[ -z "$ROOT" ]]; then
  echo -e "\033[0;31mERROR\033[0m: Not in a git repository" >&2
  exit 1
fi

# Change to repository root
cd "$ROOT"

SPEC_FILE="${1:-setup/inputs.spec}"
CACHE_ROOT=".cache/input_sources"
LOCK_FILE="setup/inputs.lock"

# ----------------------------
# Preconditions
# ----------------------------
SHA_CMD=""
if command -v shasum >/dev/null 2>&1; then
  SHA_CMD="shasum -a 256"
elif command -v sha256sum >/dev/null 2>&1; then
  SHA_CMD="sha256sum"
else
  echo -e "\033[0;31mERROR\033[0m: need shasum (macOS) or sha256sum (Git Bash/Linux) to write $LOCK_FILE" >&2
  exit 1
fi

[[ -f "$SPEC_FILE" ]] || { echo -e "\033[0;31mERROR\033[0m: spec file not found: $SPEC_FILE" >&2; exit 1; }

mkdir -p "$CACHE_ROOT"

# ----------------------------
# Clean input/ directory
# ----------------------------
# Delete input/ to ensure all inputs are fresh and come from the spec file.
if [[ -d "input" ]]; then
  echo "Cleaning input/ directory..."
  rm -rf "input"
fi
mkdir -p "input"

# ----------------------------
# Lock header
# ----------------------------
{
  echo "# setup/inputs.lock"
  echo "# generated_at_utc: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "# format: repo_url<TAB>ref<TAB>commit_sha<TAB>src_pattern<TAB>dst_file<TAB>sha256<TAB>size_bytes"
  echo
} > "$LOCK_FILE"

# ----------------------------
# Main loop: one spec line at a time
# ----------------------------
while IFS= read -r line || [[ -n "$line" ]]; do
  # strip CR (Windows line endings) + trim
  line="${line%$'\r'}"
  line="$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

  [[ -n "$line" ]] || continue
  [[ "$line" != \#* ]] || continue

  # Parse fields: split on tabs or multiple spaces (treating them as field separators)
  # Use awk to handle multiple spaces/tabs as delimiters
  repo="$(echo "$line" | awk -F'[\t ]+' '{print $1}')"
  ref="$(echo "$line" | awk -F'[\t ]+' '{print $2}')"
  src="$(echo "$line" | awk -F'[\t ]+' '{print $3}')"
  dst="$(echo "$line" | awk -F'[\t ]+' '{print $4}')"

  repo="${repo%$'\r'}"; ref="${ref%$'\r'}"; src="${src%$'\r'}"; dst="${dst%$'\r'}"
  repo="$(echo "$repo" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
  ref="$(echo "$ref" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
  src="$(echo "$src" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
  dst="$(echo "$dst" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

  [[ -n "$repo" && -n "$ref" && -n "$src" ]] || {
    echo -e "\033[0;31mERROR\033[0m: bad spec line (need at least 3 TAB-separated fields: repo, ref, src_pattern): $line" >&2; exit 1;
  }
  
  # dst_path is optional; if not provided, default to "input/"
  # If provided, it's relative to input/
  if [[ -z "$dst" ]]; then
    dst="input/"
  else
    # Remove any leading "input/" if user accidentally included it
    dst="${dst#input/}"
    # Prepend "input/"
    dst="input/$dst"
  fi
  
  # Ensure dst ends with / to indicate it's always a directory
  [[ "$dst" == */ ]] || dst="${dst}/"

  echo "Resolving $repo @ $ref ..."
  sha=""
  last_error=""
  
  # Check if ref looks like a commit SHA (7+ hex characters)
  if [[ "$ref" =~ ^[0-9a-f]{7,40}$ ]]; then
    # It's a commit SHA - use it directly (git fetch will validate it exists)
    sha="$ref"
  else
    # Try refs/heads/ first
    if output=$(git ls-remote "$repo" "refs/heads/$ref" 2>&1); then
      if [[ -n "$output" ]]; then
        sha="$(echo "$output" | awk 'NR==1{print $1}')"
      fi
    else
      last_error="$output"
    fi
    
    # Try refs/tags/ if not found
    if [[ -z "$sha" ]]; then
      if output=$(git ls-remote "$repo" "refs/tags/$ref" 2>&1); then
        if [[ -n "$output" ]]; then
          sha="$(echo "$output" | awk 'NR==1{print $1}')"
        fi
      else
        last_error="$output"
      fi
    fi
    
    # Try direct ref (for other refs)
    if [[ -z "$sha" ]]; then
      if output=$(git ls-remote "$repo" "$ref" 2>&1); then
        if [[ -n "$output" ]]; then
          sha="$(echo "$output" | awk 'NR==1{print $1}')"
        fi
      else
        last_error="$output"
      fi
    fi
  fi
  
  if [[ -z "$sha" ]]; then
    echo -e "\033[0;31mERROR\033[0m: could not resolve ref '$ref' in repo '$repo'" >&2
    if [[ -n "$last_error" ]]; then
      # Remove leading "ERROR:" or "fatal:" if present to avoid duplication
      clean_msg="${last_error#ERROR: }"
      clean_msg="${clean_msg#fatal: }"
      echo "$clean_msg" >&2
    else
      echo "Ref '$ref' not found (tried refs/heads/, refs/tags/, and direct ref)" >&2
    fi
    exit 1
  fi

  key="$(printf "%s" "$repo@$sha" | git hash-object --stdin)"
  cache_dir="$CACHE_ROOT/$key"

  if [[ ! -d "$cache_dir/.git" ]]; then
    echo "Cloning into $cache_dir ..."
    # Clone with single branch and no checkout, but don't filter trees (LFS needs them)
    if ! GIT_LFS_SKIP_SMUDGE=1 git clone --single-branch --no-checkout "$repo" "$cache_dir" >/dev/null 2>&1; then
      echo -e "\033[0;31mERROR\033[0m: failed to clone repository: $repo" >&2
      exit 1
    fi
  fi

  (
    cd "$cache_dir"

    echo "Fetching commit $sha ..."
    # Fetch the specific commit we need (unfiltered, to get full tree objects)
    if ! GIT_LFS_SKIP_SMUDGE=1 git fetch --no-tags origin "$sha" >/dev/null 2>&1; then
      echo -e "\033[0;31mERROR\033[0m: failed to fetch commit $sha from repository: $repo" >&2
      exit 1
    fi

    # sparse pattern: dir/ => dir/** ; otherwise pattern as-is (supports *.jpg etc)
    sparse_pat="$src"
    if [[ "$src" == */ ]]; then
      sparse_pat="${src}**"
    fi

    echo "Sparse checkout: $sparse_pat"
    git sparse-checkout init --no-cone >/dev/null 2>&1 || true
    if ! git sparse-checkout set --no-cone "$sparse_pat" >/dev/null 2>&1; then
      echo -e "\033[0;31mERROR\033[0m: failed to set sparse checkout pattern: $sparse_pat" >&2
      exit 1
    fi
    
    # Configure LFS to only fetch files in the sparse checkout
    git config lfs.fetchinclude "$sparse_pat" >/dev/null 2>&1 || true

    echo "Checking out $sha ..."
    if ! GIT_LFS_SKIP_SMUDGE=1 git checkout --detach "$sha" >/dev/null 2>&1; then
      echo -e "\033[0;31mERROR\033[0m: failed to checkout commit $sha" >&2
      exit 1
    fi

    # Build a concrete file list to copy (in a temp file)
    tmp_files="$(mktemp -t sync_inputs_files.XXXXXX)"
    : > "$tmp_files"

    if [[ "$src" == */ ]]; then
      [[ -d "$src" ]] || { echo -e "\033[0;31mERROR\033[0m: source directory not found: $src" >&2; exit 1; }
      find "$src" -type f -print > "$tmp_files"

    elif [[ "$src" == *"*"* || "$src" == *"?"* || "$src" == *"["* ]]; then
      # expand globs inside repo worktree
      matches="$(compgen -G "$src" || true)"
      [[ -n "$matches" ]] || { echo -e "\033[0;31mERROR\033[0m: no files matched pattern: $src" >&2; exit 1; }
      printf "%s\n" $matches > "$tmp_files"
      # ensure all are files
      while IFS= read -r f; do
        [[ -f "$f" ]] || { echo -e "\033[0;31mERROR\033[0m: pattern matched a directory; use trailing '/' to copy directories: $src -> $f" >&2; exit 1; }
      done < "$tmp_files"

    else
      [[ -f "$src" ]] || { echo -e "\033[0;31mERROR\033[0m: source file not found: $src" >&2; exit 1; }
      echo "$src" > "$tmp_files"
    fi

    # If any of those files are LFS pointers, pull them
    tmp_ptrs="$(mktemp -t sync_inputs_ptrs.XXXXXX)"
    tmp_oids="$(mktemp -t sync_inputs_oids.XXXXXX)"
    : > "$tmp_ptrs"
    : > "$tmp_oids"

    while IFS= read -r f || [[ -n "$f" ]]; do
      [[ -n "$f" ]] || continue
      if head -c 200 "$f" | grep -a -q 'git-lfs.github.com/spec/v1'; then
        oid="$(grep -a '^oid sha256:' "$f" | head -n1 | sed 's/^oid sha256://')"
        if [[ -n "$oid" ]]; then
          echo "$f" >> "$tmp_ptrs"
          echo "$oid" >> "$tmp_oids"
        fi
      fi
    done < "$tmp_files"

    if [[ -s "$tmp_ptrs" ]]; then
      # Check if git-lfs is installed
      if ! command -v git-lfs >/dev/null 2>&1 && ! git lfs version >/dev/null 2>&1; then
        echo -e "\033[0;31mERROR\033[0m: git-lfs is not installed but LFS files were detected." >&2
        echo "Please install git-lfs to sync files stored in Git LFS." >&2
        echo "See: https://git-lfs.github.com/" >&2
        exit 1
      fi
      
      total_files=$(wc -l < "$tmp_ptrs" | tr -d ' ')
      echo "Downloading $total_files LFS objects (this may take 30-60 seconds)..."
      
      # Do a single git lfs pull - show actual progress
      # Don't suppress output so user can see it's working
      if ! git lfs pull 2>&1; then
        echo -e "\033[0;31mWARNING\033[0m: git lfs pull had errors, checking if files downloaded anyway..." >&2
      fi
      
      # Verify all files were downloaded
      echo "Verifying downloads..."
      failed_files=""
      while IFS= read -r f; do
        if head -c 200 "$f" | grep -a -q 'git-lfs.github.com/spec/v1'; then
          failed_files="$failed_files $f"
        fi
      done < "$tmp_ptrs"
      
      if [[ -n "$failed_files" ]]; then
        echo -e "\033[0;31mERROR\033[0m: Some LFS files were not downloaded:" >&2
        echo "$failed_files" >&2
        exit 1
      fi
      
      echo "✓ All LFS files downloaded successfully."
    fi

    # Copy + lock lines
    # dst is always a directory (ends with /)
    mkdir -p "$ROOT/$dst"
    
    while IFS= read -r f || [[ -n "$f" ]]; do
      [[ -n "$f" ]] || continue

      if [[ "$src" == */ ]]; then
        # Directory: create subfolder named after source directory, preserve structure
        # Extract directory name from src (e.g., "analysis/output/Figures/" -> "Figures")
        src_dir_name="$(basename "${src%/}")"
        rel="${f#$src}"
        out="$ROOT/$dst$src_dir_name/$rel"
        mkdir -p "$(dirname "$out")"
        dst_file="$dst$src_dir_name/$rel"
      else
        # Single file or wildcard: use basename in dst (flat copy)
        base="$(basename "$f")"
        out="$ROOT/$dst$base"
        dst_file="$dst$base"
      fi

      # Handle duplicate filenames by appending "_copy" suffix
      original_out="$out"
      original_dst_file="$dst_file"
      copy_num=1
      while [[ -f "$out" ]]; do
        if [[ "$original_out" == *.* ]]; then
          # Has extension
          name="${original_out%.*}"
          ext="${original_out##*.}"
          out="${name}_copy${copy_num}.${ext}"
          dst_file="${original_dst_file%.*}_copy${copy_num}.${ext}"
        else
          # No extension
          out="${original_out}_copy${copy_num}"
          dst_file="${original_dst_file}_copy${copy_num}"
        fi
        copy_num=$((copy_num + 1))
      done

      cp -f "$f" "$out"
      [[ -f "$out" ]] || { echo -e "\033[0;31mERROR\033[0m: copy failed: $f -> $out" >&2; exit 1; }

      h="$($SHA_CMD "$out" | awk '{print $1}')"
      s="$(wc -c < "$out" | tr -d ' ')"
      printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\n" "$repo" "$ref" "$sha" "$src" "$dst_file" "$h" "$s" >> "$ROOT/$LOCK_FILE"
    done < "$tmp_files"

    rm -f "$tmp_files" "$tmp_ptrs" "$tmp_oids"
  )

done < "$SPEC_FILE"

# ----------------------------
# Cleanup cache
# ----------------------------
echo "Cleaning up cache..."
rm -rf "$CACHE_ROOT"

echo "Done."
echo "Updated: input/ ... and setup/inputs.lock."
echo "Make sure to git status, commit input/ + setup/inputs.lock, and push."