The directory `/examples/` contains example scripts that illustrate how to use the template with tools such as R, Python, Stata, Julia, Matlab, LaTeX, and Lyx. The `README.md` files in these directories provide additional detail on how to use the respective tool with the template and requirements for running the example scripts.

The general steps to set up the template to run the example scripts are:

1. Make sure the appropriate software (e.g., Python, R) is installed along with any required libraries/packages
2. Locate the [module(s)](#modules) where you will place the script(s)
3. Copy the script(s) to the module(s)' `source` directory
4. Update the module(s)' `make.sh` script(s) as follows
    * Uncomment the line beginning `#source "${REPO_ROOT}/...` that loads the relevant `run_XXX` shell command
    * Uncomment the line beginning `# run_...` to execute the relevant `run_XXX` shell command, and replace the placeholder script name with the name of your script(s)
5.  Update the module(s)' `get_inputs.sh` script(s) to create links for any needed inputs in the `/input/` directory
5. Run the module's `make.sh` script to confirm that the example script executes correctly

The `local_env.sh` settings file at the top level of the repository (created when you run `setup.sh` if it didn't exist before) defines the name of executables for software tools like Python and R. If the name of your local executable is different from the default name you can change it in this file. All such tools you intend to use must be callable from the command line (i.e., must be added to the appropriate system path). In this file, you can also list paths to any external input paths.