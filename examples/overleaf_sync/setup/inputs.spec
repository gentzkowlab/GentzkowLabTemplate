# inputs.spec
#
# Declares which external files (figures/tables/etc.) should be copied into this repo's
# input/ folder.
#
# Note: The setup/sync_inputs.sh script deletes the entire input/ directory at the start
# to ensure all inputs are fresh and come from this spec file. If you need to manually add
# files, place them in raw/ instead of input/.

# Format
# ------
# Each non-empty, non-comment line has 3-4 TAB-separated fields:
#
#   repo_url<TAB>ref<TAB>src_pattern<TAB>[dst_path]
#
# The dst_path field is optional. If omitted, files are copied to input/.
#
# Fields
# ------
# - repo_url:
#     Git URL of the source repo (SSH or HTTPS).
#
# - ref:
#     Branch name, tag name, or commit SHA in the source repo.
#
# - src_pattern (path inside the source repo, relative to its root):
#     Three supported forms:
#
#     (1) Directory copy (recursive):
#           analysis/output/Figures/
#         Copies all files under that directory, creating a subfolder named after the source
#         directory (e.g., "Figures") in dst_path, preserving the folder structure.
#
#     (2) Wildcard match within a directory:
#           analysis/output/Figures/*
#         Copies matching files directly into dst_path (flat; filenames only, no subfolder).
#
#     (3) Extension wildcard:
#           analysis/output/Figures/*.jpg
#         Same as (2), but filters by extension (or any glob pattern).
#
# - dst_path (optional; path relative to input/):
#     If omitted, files are copied to input/. If provided, it's relative to input/ (don't include
#     "input/" prefix). Examples: "Figures/", "Tables/", or leave empty for input/.
#
#     Rules:
#     - If src_pattern ends with "/", dst_path MUST end with "/" (directory-to-directory).
#     - If src_pattern contains a wildcard (* ? [), dst_path MUST end with "/" (copies into a folder).
#     - If src_pattern is a single file path, dst_path may be:
#         * a directory ending with "/" (copy into folder, keep original filename), or
#         * a full file path (copy and rename).
#
# Notes
# -----
# - Different lines can come from different repos and/or different branches/commits.
# - Git LFS is supported. If any requested files are stored in LFS, the script fetches the LFS
#   objects and materializes before copying.
# - setup/inputs.lock is a log/lockfile written by the script, recording the commit SHA for what was copied.
#
# Examples
# --------
# 1) Copy an entire folder (recursive; creates subfolder named after source directory)
# git@github.com:exampleuser/ExampleRepo.git    main    analysis/output/Figures/
#     This creates input/Figures/ with all files preserving their structure.
#     (dst_path omitted, defaults to input/)
#
# 2) Copy all files in a folder (flat; no subfolder)
# git@github.com:exampleuser/ExampleRepo.git    main    analysis/output/Figures/*
#     This copies files directly into input/.
#     (dst_path omitted, defaults to input/)
#
# 3) Copy only JPGs into a specific subfolder
# git@github.com:exampleuser/ExampleRepo.git    main    analysis/output/Figures/*.jpg    Figures/
#     This copies files into input/Figures/.
#
# 4) Copy one file into a folder (keeps name)
# git@github.com:exampleuser/ExampleRepo.git    main    analysis/output/Tables/table1.tex  Tables/
#     This copies to input/Tables/table1.tex.
#
# 5) Copy one file and rename it
# git@github.com:exampleuser/ExampleRepo.git    main    analysis/output/Tables/table1.tex  Tables/main_table.tex
#     This copies to input/Tables/main_table.tex.
#
# --------
# Add your paths below, following the format as in the examples above:
# repo_url	ref	src_pattern	dst_path

