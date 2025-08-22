## Overview

* `README.txt`: The repository's readme file.
* `LICENSE.txt`: The template's MIT License.
* `run_all.sh`: Runs the repository from beginning to end.
* `setup.sh`: Meant to be run when you first clone the template (or first clone a repo based on the template). It creates local_env.sh, runs get_inputs.sh in each module, and runs make_externals.sh.
* `local_env.sh`: Stores settings and paths specific to a user's local environment. This file is not committed to Git. If it doesn't exist it is created when you run `lib/shell/check_setup.sh` or `setup.sh`"
* `/lib/`: Contains code libraries/packages that are used across multiple parts of the repository.
* `/examples/`: Examples that illustrate how to use the template with specific software tools.
* `/0_raw/`: Contains raw data, images, etc. that are inputs to the code downstream and are committed to the repository.
* `/1_data/`: Cleans and wrangles the data.
* `/2_analysis/`: Runs the analysis.
* `/3_slides/`: Makes the slides.
* `/4_paper/`: Makes the paper.

## Modules

The template is organized into *modules*. A module is a subdirectory with a `make.sh` script at its root, a `/source/` subdirectory,
and an `/output/` subdirectory. Each module is a self-contained unit that runs code in `/source/` to produce output in
`/output/`. If a module uses inputs beyond the code itself (e.g., data stored elsewhere in the repository and/or externally), these
are placed in an `/input/` subdirectory with copies (and/or symlinks) of the relevant inputs.

Out of the box, the template contains 4 modules, `1_data`, `2_analysis`, `3_slides`, and `4_paper`. The subdirectory `0_raw` is not a module because it does not contain code -- it is only used for storing static data.

Organizing a repository into modules has several advantages:

* The high-level structure of the repository is clear to the user
* Each module is a self-contained unit that a user can understand without looking at other modules
* Any given module can be run from beginning to end in a reasonable amount of time
* Well-organized modules produce clean commit histories

The default structure of the template is just an example. You should define and organize modules
in the way that makes sense for your projet. You can add additional modules at the top level of the repository --
for example,

* `1_data`
* `2_descriptive_analysis`
* `3_structural_estimation`
* `4_slides`
* `5_paper`

Each of these subdirectories should have its own `make.sh`, `/source/`, and `/output/`.

You can also subdivide top-level subdirectories into multiple modules -- for example,

* `1_data`
    - `1_survey_data`
    - `2_geo_data`
    - `3_admin_data`

In this case, each of `1_survey_data`, `2_geo_data`, and `3_admin_data` should have their own `make.sh`, `/source/`, and `/output/`. The top-level `1_data` directory should not contain anything other than the subdirectories.

Here are some **key principles** for organizing modules:

* Use numerical prefixes like `1_xxx`, `2_xxx`, etc. to make clear the order in which modules should be run.
* Each module should have a clear scope and purpose that a user can easily guess from its name.
* Modules should be small enough that the `make.sh` script can be run in a reasonable amount of time. If a module takes hours or days to run, it is often a good idea to break it up into multiple smaller modules.
* Very slow steps should be isolated in separate modules. For example, if there is an estimation step that takes many days to run, this should be in a separate module from other steps like descriptive analysis, formatting tables and figures, etc.
* Steps that are modified and re-run frequently should be isolated in separate modules. For example, it often makes sense to separate formatting tables and figures from the analysis code that produces the inputs to the tables and figures.
* Modules should be defined to keep the dependency tree of the repository as simple and untangled as possible. For example, it is often a good sign if all downstream analysis modules call inputs from one or a small number of upstream data-building modules.

## Make scripts

The script `make.sh` runs a given module from beginning to end. More specifically, it:

* Loads local settings and paths from `local_env.sh`
* Loads shell commands from `/lib/shell/`
* Clears the `/output/` directory
* Populates the `/input/` directory
* Runs the scripts in `/source/` with a sequence of command-line calls 
* Logs everything in `/output/make.log`

The calls to the individual scripts are governed by a set of shell commands named `run_python`, 
`run_R`, etc. that are defined in `lib/shell/`. These are very simple wrappers that
issue the appropriate command line calls to run a given script. You could replace these 
with direct command-line calls -- for example, you could replace the line

```sh
run_python wrangle_data.py "${LOGFILE}" || exit 1
```

in `1_data/make.sh` with

```sh
python3 wrangle_data.py >> "${LOGFILE}" || exit 1
```

The advantages of using the wrapper commands include:

* They use executable names defined by `local_env.sh`, so that the code can work across machines with different local configurations
* They clean up LaTeX auxiliary files
* They copy LaTeX output files to the `output` directory, whereas `pdflatex` places output in the same directory as the code by default
* They copy default Stata logs into `/output/make.log`
* They handle differences in Stata command line syntax across operating systems
* They handle cases where scripts terminate with errors in a friendly way

## Inputs and outputs

Code in a module's `/source/` directory should only call inputs from the module's `/input/` directory, or, in the case of inputs that are produced within the module itself, from `/output/` or `/temp/` (a temporary directory that will be ignored by Git). **Code should never reference files elsewhere in the repository, or files external to the repository, directly**. 

The module's `input` directory should be populated by the module's `make.sh` script which calls `get_inputs.sh`. It should never be modified directly by the user.

All output should be placed the module's `/output/` directory. Files that cannot be committed to Git (e.g. because they are too large) should be placed in `/output_local/` instead, which is not committed to Git by default.

Benefits of following these rules include:

* The input-output structure of each module is transparent to the user
* Modules are self-contained and can be placed anywhere within the repository's directory structure
* `make.sh` can log the state of the inputs at the time when the module was run
* `make.sh` can guarantee that all contents of `/output/` were produced by a single run of the code
* If the location of an input file changes, this can be updated once in `get_inputs.sh` (for an input in the repository) or `local_env.sh` (for an external input); there is no need to change file paths in scripts individually.
* It is easy to produce a graph of the input-output flow of the repository as a whole

## External dependencies

In some cases, a repository may depend on data files or other inputs that are external to the repository. The most common case is data files that cannot be committed to Git (either because they are too large or because their license does not permit it). In this case, the local paths to these external dependencies should be defined as shell variables in `local_env.sh`. The `lib/shell/make_externals.sh` script should then be be run to create symlinks to the external resources within the root of the repo.

The comments in `local_env.sh` should provide detail on the nature of the external files, their provenance, and how a user can locate them. If the external files are raw data, they should be documented with a `README` just like the files in `0_raw`. If the external files are produced in a different repository, they should be called in a way that records the repository and revision that produced them.
