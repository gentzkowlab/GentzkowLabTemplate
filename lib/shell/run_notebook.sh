#!/bin/bash

unset run_notebook
run_notebook () {
    trap - ERR  # allow internal error handling

    # get arguments
    program="$1"
    logfile="$2"
    OUTPUT_DIR=$(dirname "$logfile")

    programname=$(basename "$program" .ipynb)

    # set jupyter command if unset
    if [ -z "$jupyterCmd" ]; then
        echo -e "\nNo Jupyter command set. Using default: jupyter"
        jupyterCmd="jupyter"
    fi

    # check if the command exists before running, log error if it does not
    if ! command -v "${jupyterCmd}" &> /dev/null; then
        error_time=$(date '+%Y-%m-%d %H:%M:%S')
        echo -e "\n\033[0;31mProgram error\033[0m at ${error_time}: ${jupyterCmd} not found. Make sure command line usage is properly set up."
        echo "Program Error at ${error_time}: ${jupyterCmd} not found." >> "${logfile}"
        exit 1
    fi

    # check if the target notebook exists
    if [ ! -f "${program}" ]; then
        error_time=$(date '+%Y-%m-%d %H:%M:%S')
        echo -e "\n\033[0;31mProgram error\033[0m at ${error_time}: notebook ${program} not found."
        echo "Program Error at ${error_time}: notebook ${program} not found." >> "${logfile}"
        exit 1
    fi

    # capture the content of the output folder before running
    if [ -d "${OUTPUT_DIR}" ]; then
        files_before=$(find "${OUTPUT_DIR}" -type f ! -name "make.log" -exec basename {} + | sort)
    else
        mkdir -p "${OUTPUT_DIR}"
        files_before=""
    fi

    # log start time
    start_time=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "\nNotebook ${program} in ${jupyterCmd} started at ${start_time}" | tee -a "${logfile}"

    # execute notebook headlessly into OUTPUT_DIR as html
    ${jupyterCmd} nbconvert --to html --execute "${program}" \
    --ExecutePreprocessor.timeout=-1 \
    --ExecutePreprocessor.allow_errors=False \
    --output "${programname}" --output-dir "${OUTPUT_DIR}" >> "${logfile}" 2>&1
    rc=$?


    # capture the content of output folder after running
    if [ -d "${OUTPUT_DIR}" ]; then
        files_after=$(find "${OUTPUT_DIR}" -type f ! -name "make.log" -exec basename {} + | sort)
    else
        files_after=""
    fi

    # determine newly created files
    created_files=$(comm -13 <(echo "$files_before") <(echo "$files_after"))

    # report on errors or success and display the output
    if [ $rc -ne 0 ]; then
        error_time=$(date '+%Y-%m-%d %H:%M:%S')
        echo -e "\033[0;31mError\033[0m: ${program} failed at ${error_time}. Check log for details."
        echo "Error in ${program} at ${error_time}" >> "${logfile}"

        if [ -n "$created_files" ]; then
            echo -e "\033[0;31mWarning\033[0m: there was an error, but files were created. Check log."
            echo -e "\nWarning: There was an error, but these files were created: $created_files" >> "${logfile}"
        fi
        exit 1
    else
        echo "Notebook ${program} finished successfully at $(date '+%Y-%m-%d %H:%M:%S')" | tee -a "${logfile}"

        if [ -n "$created_files" ]; then
            echo -e "\nThe following files were created in ${program}:" >> "${logfile}"
            echo "$created_files" >> "${logfile}"
        fi
    fi
}
