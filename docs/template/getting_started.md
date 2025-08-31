### Creating a repository

To create your own repository from the template, navigate to its [GitHub page](https://github.com/gentzkow/GentzkowLabTemplate) and click **Use this template**. See GitHub's [documentation](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-repository-from-a-template) for more details.

### Opening an existing project

Follow these steps:

1. Clone the repository and move into its directory:

    ```sh
    git clone https://github.com/MyRepoName
    cd MyRepoName
    ```

2. Run the `setup.sh` script to create the local settings file `local_env.sh`, and verify that local executables are correctly installed:

    ```sh
    bash setup.sh
    ```

3. Run the `run_all.sh` script to check that the template runs without error:

    ```sh
    bash run_all.sh
    ```