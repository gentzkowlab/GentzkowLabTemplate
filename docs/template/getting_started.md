To create your own repository from the template, navigate to its [GitHub page](https://github.com/gentzkow/GentzkowLabTemplate) and click `Use this template`. See GitHub's [documentation](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-repository-from-a-template) for more details.

Then follow these steps.

```sh
# Clone the repo, cd into it
git clone https://github.com/MyRepoName
cd MyRepoName

# Run the `setup.sh` script to create local settings file 
# local_env.sh, and check that local executables are correctly 
# installed.
bash setup.sh

# Run the `run_all.sh` script to check that the template runs 
# without error
bash run_all.sh
```