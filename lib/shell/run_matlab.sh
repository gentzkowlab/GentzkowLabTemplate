#!/bin/bash

unset run_matlab
run_matlab () {

    # get arguments
    program="$1"
    logfile="$2"
    OUTPUT_DIR=$(dirname "$logfile")

    # set MATLAB command if unset
    if [ -z "$matlabCmd" ]; then
        echo -e "\nNo MATLAB command set. Using default: matlab -nodisplay -batch"
        matlabCmd="matlab -nodisplay -batch"
    fi

    # check if the command exists before running, log error if does not
    if ! command -v matlab &> /dev/null; then
        error_time=$(date '+%Y-%m-%d %H:%M:%S')
        echo -e "\033[0;31mProgram error\033[0m at ${error_time}: MATLAB not found. Make sure command line usage is properly set up."
        echo "Program Error at ${error_time}: MATLAB not found." >> "${logfile}"
        return 1  # exit early with an error code
    fi

    # capture the content of output folder before running the script
    files_before=$(ls -1 "$OUTPUT_DIR" | grep -v "make.log")

    # log start time for the script
    echo -e "\nScript ${program} in MATLAB started at $(date '+%Y-%m-%d %H:%M:%S')" | tee -a "${logfile}"

    # run MATLAB command and capture both stdout and stderr in the output variable
    output=$(${matlabCmd} "run('${program}'); exit;" 2>&1)
    return_code=$?  # capture the exit status

    # capture the content of output folder after running the script
    files_after=$(ls -1 "$OUTPUT_DIR" | grep -v "make.log")

    # determine the new files that were created
    created_files=$(comm -13 <(echo "$files_before") <(echo "$files_after"))

    # report on errors or success and display the output
    if [ $return_code -ne 0 ]; then
        error_time=$(date '+%Y-%m-%d %H:%M:%S')
        echo -e "\033[0;31mWarning\033[0m: ${program} failed at ${error_time}. Check log for details."  # display error warning in terminal
        echo "Error in ${program} at ${error_time}: $output" >> "${logfile}"  # log error output
        if [ -n "$created_files" ]; then
            echo -e "\033[0;31mWarning\033[0m: there was an error, but files were created. Check log." 
            echo -e "\nWarning: There was an error, but these files were created: $created_files" >> "${logfile}"  # log created files
        fi
        exit 1
    else
        echo "Script ${program} finished successfully at $(date '+%Y-%m-%d %H:%M:%S')" | tee -a "${logfile}"
        echo "Output: $output" >> "${logfile}"  # log output

        if [ -n "$created_files" ]; then
            echo -e "\nThe following files were created in ${program}:"  >> "${logfile}"
            echo "$created_files" >> "${logfile}"  # list files in output folder
        fi
    fi
}
