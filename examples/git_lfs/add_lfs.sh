#!/bin/bash

# Ensure git lfs is installed and initialized
if ! git lfs &> /dev/null; then
  echo "Git LFS is not installed. Please install Git LFS first."
  exit 1
fi

# Store current wd, cd into repo root
ORIGINAL_DIR=$(pwd)
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
cd "$REPO_ROOT"

git lfs install

# Add LFS tracking
# Add more file types below if needed
git lfs track "*.pdf"
git lfs track "*.csv"
git lfs track "*.dta"
git lfs track "*.mat"
git lfs track "*.rda"
git lfs track "*.rds"
git lfs track "*.rdata"
git lfs track "*.png"
git lfs track "*.jpg"
git lfs track "*.xls"
git lfs track "*.xlsx"
git lfs track "*.sql"
git lfs track "*.sqlite"
git lfs track "*.sav"
git lfs track "*.sas7bdat"

git add .gitattributes

git lfs pull

# Read .gitattributes to find patterns of files tracked by LFS
if [ ! -f ".gitattributes" ]; then
  echo ".gitattributes file not found. Please create and add LFS tracking rules."
  exit 1
fi

# Extract file patterns tracked by LFS
tracked_files=$(grep filter=lfs .gitattributes | cut -d' ' -f1)

# Variable to store local modifications
local_modifications=()
files_processed=0

# Check for local modifications before adding any files
for pattern in $tracked_files; do
  # List tracked files recursively (including subdirectories)
  files_to_check=$(git ls-files "$pattern" -- "$pattern")

  # Check if any tracked files have local modifications
  for file in $files_to_check; do
    if ! git diff --quiet -- "$file"; then
      local_modifications+=("$file")
    fi
  done
done

# If any files have local modifications, print a warning and prompt user for action
if [ ${#local_modifications[@]} -ne 0 ]; then
  echo -e "\n\033[0;31mWarning\033[0m: The following files have local modifications:"
  for file in "${local_modifications[@]}"; do
    echo "  - $file"
  done
  echo "Proceeding will add these files to LFS with their current changes."
  read -p "Do you want to proceed? (y/n): " user_choice

  if [ "$user_choice" != "y" ]; then
    echo "Operation aborted. Please resolve local modifications and run the script again."
    exit 1
  fi
fi

# Remove files from cache if they are already tracked and need to be moved to LFS
for pattern in $tracked_files; do
  # List files that are tracked by Git and match the pattern
  files_to_remove=$(git ls-files "$pattern")

  for file in $files_to_remove; do
    git rm --cached "$file" > /dev/null 2>&1 
  done
done

# Re-add the files to Git, now tracked by LFS
for pattern in $tracked_files; do
  # Add files recursively (including subdirectories)
  files_to_add=$(git ls-files --others --exclude-standard "$pattern")

  for file in $files_to_add; do
    git add "$file"
    echo "Added $file to Git LFS."
    files_processed=$((files_processed + 1))
  done
done

# Inform the user to commit the changes
if [ $files_processed -eq 0 ]; then
  echo "No applicable files were found to process for Git LFS."
else
  echo -e "\nAll applicable files have been removed from cache and re-added to Git LFS."
  echo "Remember to commit the changes by running: git commit -m 'Add files to Git LFS'"
fi

# Return to the original working directory
cd "$ORIGINAL_DIR"