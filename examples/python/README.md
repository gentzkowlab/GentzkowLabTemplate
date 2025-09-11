This directory has example scripts that illustrate how to use the GentzkowLabTemplate with Python.

See the Examples section of the [template instructions](https://github.com/gentzkow/GentzkowLabTemplate/wiki#examples) for the general procedure for using example scripts.

### List of files

* `wrangle_data.py` is an example script to save cleaned data.
* `analyze_data.py` is an example script to create a regression table and plots.

### Steps to set up the Python example for cleaning data

1. Place `wrangle_data.py` in `1_data/source/`
2. Replace these lines in `1_data/make.sh`
  
    ```
    #source "${REPO_ROOT}/lib/shell/run_xxx.sh"
    ```
    ```
    # run_xxx my_script.xx "${LOGFILE}" || exit 1
    ```

    with

    ```
    source "${REPO_ROOT}/lib/shell/run_python.sh"
    ```
    ```
    run_python wrangle_data.py "${LOGFILE}" || exit 1
    ```
3. Replace this line in `1_data/get_inputs.sh`
    ```
    # /path/to/your/input/file.csv (replace with your actual input paths)
    ```

    with
  
    ```
    ../examples/inputs_for_examples/mpg.csv 
    ```

4. Run `1_data/make.sh`

### Steps to set up the Python example for analyzing data

1. Place `analyze_data.py` in `2_analysis/source/`
2. Replace these lines in `2_analysis/make.sh`
    ```
    #source "${REPO_ROOT}/lib/shell/run_xxx.sh"
    ```
    ```
    # run_xxx my_script.xx "${LOGFILE}" || exit 1
    ```

    with

    ```
    source "${REPO_ROOT}/lib/shell/run_python.sh"
    ```
    ```
    run_python analyze_data.py "${LOGFILE}" || exit 1
    ```

3. The example script `analyze_data.py` requires that the cleaned input file -- `mpg.csv` -- be placed in `/2_analysis/input/`. Once you have set up `wrangle_data.py` following the steps above, this file will be created in `1_data/output`. You can then have them copied to `/2_analysis/input` by replacing this line in `2_analysis/get_inputs.sh`

    ```
    # /path/to/your/input/file.csv (replace with your actual input paths)
    ```

    with
  
    ```
    ../1_data/output/*
    ```

4. Run `2_analysis/make.sh`