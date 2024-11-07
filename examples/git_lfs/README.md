
# Initializing Git LFS for large file tracking

## Summary
This directory has instructions for activating Git LFS tracking in repositories created with GentzkowLabTemplate. This optional feature is highly recommended, as it allows Git to store large binary files (including PDFs) efficiently.

### How to use

The extension requires that you have Git LFS installed. You can install it from [here](https://git-lfs.github.com/).

After installing, from the root of the repository, run the script located in `./examples/git_lfs/add_lfs.sh`.

This script will initialize `git lfs` for usage. First, it will instruct `git lfs` to handle files with extensions such as `.pdf`, `.png`, etc. You can change the extensions to be handled by `git lfs` by modifying `./examples/git_lfs/add_lfs.sh`. The script will also download large files from the remote repository to your local computer, if any exist. Then, it will re-upload any large files that were previously committed without `git lfs` to ensure they are being tracked. 

See [here](https://git-lfs.github.com/) for more on how to modify your `git lfs` settings. 

After activating `git lfs`, you should also modify the file in `./lib/shell/check_setup.sh` by uncommenting the relevant lines. This will warn any users of your repository that they should install `git lfs` first:

```
# Optional: Check that Git LFS is installed
# Uncomment the lines below if you'd like to activate Git LFS for this project
# if ! which git-lfs > /dev/null; then
#   echo "Warning: It looks like Git Large File Storage (LFS) is not installed."
#   echo "You should install it before using this repository to make sure that"
#   echo "large files are handled correctly. See https://git-lfs.com/ for more"
#   echo "information."
# fi
```
