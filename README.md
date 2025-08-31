This repository is built on the [GentzkowLabTemplate](https://github.com/gentzkowlab/GentzkowLabTemplate), © 2024 by Matthew Gentzkow and distributed under the [MIT license](https://github.com/gentzkow/GentzkowLabTemplate/blob/main/LICENSE.txt). 


## External links

Use this section to document resources external to this repository that are part of the project.

## Running the repository

To get started, follow the steps below. For complete documentation, see the [GentzkowLabTemplate Docs](https://gentzkowlab.github.io/GentzkowLabTemplate/).

### Getting started

1. Clone the repository and move into the project directory:

    ```sh
    git clone https://github.com/YourUsername/YourRepoName.git
    cd YourRepoName
    ```

2. Run the setup script to create a local settings file (`local_env.sh`) and populate input files:

    ```sh
    bash setup.sh
    ```

### Running modules

This repository is organized into modules, each located in a subdirectory like `1_data/`, `2_analysis/`, etc. Each module contains a `make.sh` script that runs the code in that module from beginning to end.

To run a module, navigate into its folder and run:  

```sh
bash make.sh
```

Each module:
- Reads inputs from its `/input/` directory (populated automatically via `get_inputs.sh`)
- Runs code from its `/source/` directory
- Writes outputs to its `/output/` directory

### Running the whole project

To execute the full project pipeline, run:

```sh
bash run_all.sh
```

This will run all modules sequentially.

## Notes

Use this section for additional information.
