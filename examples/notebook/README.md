This directory has example scripts that illustrate how to use the GentzkowLabTemplate with Jupyter Notebooks.

See the Examples section of the [template instructions](https://github.com/gentzkow/GentzkowLabTemplate/wiki#examples) for the general procedure for using example scripts.

### List of files

* `my_report.ipynb` is an example Jupyter notebook that creates a data visualization report.

### Steps to set up the Jupyter Notebook example for creating a report

1. Place `my_report.ipynb` in `1_data/source/`
2. Replace these lines in `1_data/make.sh`
  
    ```
    #source "${REPO_ROOT}/lib/shell/run_xxx.sh"
    ```
    ```
    # run_xxx my_script.xx "${LOGFILE}" || exit 1
    ```

    with

    ```
    source "${REPO_ROOT}/lib/shell/run_notebook.sh"
    ```
    ```
    run_notebook my_report.ipynb "${LOGFILE}" || exit 1
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

### Notes

* The notebook will be executed and converted to PDF format. If PDF conversion fails, it will fall back to HTML format. For PDF conversion to succeed, you need to have either Chromium (for webpdf) or LaTeX installed. 
* Make sure you have Jupyter installed and properly configured for command-line usage.

