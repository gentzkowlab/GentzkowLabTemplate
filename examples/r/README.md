This directory has example scripts that illustrate how to use the GentzkowLabTemplate with R.

See the Examples section of the [template instructions](https://github.com/gentzkow/GentzkowLabTemplate/wiki#examples) for the general procedure for using example scripts.

### List of files

* `wrangle_data.r` is an example script to save cleaned data.
* `analyze_data.r` is an example script to create a regression table and plots.

### Steps to set up the R example for cleaning data

1. Place `wrangle_data.r` in `1_data/source/`
2. Replace these lines in `1_data/make.sh`
  
    ```
    #source "${REPO_ROOT}/lib/shell/run_xxx.sh"
    ```
    ```
    # run_xxx my_script.xx "${LOGFILE}" || exit 1
    ```

    with

    ```
    source "${REPO_ROOT}/lib/shell/run_R.sh"
    ```
    ```
    run_R wrangle_data.r "${LOGFILE}" || exit 1
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

### Steps to set up the R example for analyzing data

1. Place `analyze_data.r` in `2_analysis/source/`
2. Replace these lines in `2_analysis/make.sh`
    ```
    #source "${REPO_ROOT}/lib/shell/run_xxx.sh"
    ```
    ```
    # run_xxx my_script.xx "${LOGFILE}" || exit 1
    ```

    with

    ```
    source "${REPO_ROOT}/lib/shell/run_R.sh"
    ```
    ```
    run_R analyze_data.r "${LOGFILE}" || exit 1
    ```

3. The example script `analyze_data.r` requires that the cleaned input file -- `mpg.Rdata` -- be placed in `/2_analysis/input/`. Once you have set up `wrangle_data.r` following the steps above, this file will be created in `1_data/output`. You can then have them copied to `/2_analysis/input` by replacing this line in `2_analysis/get_inputs.sh`

    ```
    # /path/to/your/input/file.csv (replace with your actual input paths)
    ```

    with
  
    ```
    ../1_data/output/*
    ```

4. Run `2_analysis/make.sh`