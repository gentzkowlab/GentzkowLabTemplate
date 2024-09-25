#!/bin/bash

unset run_lyx
run_lyx() {

    # Get arguments
    programname=$(basename "$1" .lyx)
    logfile="$2"

    # Set output directory
    if [ -n "$3" ]; then
        OUTPUT_DIR="$3"
    else
        OUTPUT_DIR="../output"
    fi
    
    # Cleanup function (not assuming same files as LaTeX, minimal cleanup for now)
    cleanup() {
        if [ -f "${programname}.pdf" ]; then
            mv "${programname}.pdf" "${OUTPUT_DIR}"
        fi
    }

    # Ensure cleanup is called on exit
    trap 'cleanup' EXIT

    # Check if lyx command exists
    if ! command -v lyx &> /dev/null; then
        error_time=$(date '+%Y-%m-%d %H:%M:%S')
        echo -e "\033[0;31mProgram error\033[0m at ${error_time}: LyX not found. Ensure LyX is installed."
        echo "Program Error at ${error_time}: LyX not found." >> "${logfile}"
        return 1
    fi

    # Find lyx command path
    lyx_path=$(which lyx)

    if [ -z "$lyx_path" ]; then
        echo -e "\033[0;31mProgram error\033[0m at ${error_time}: LyX not found. Please ensure it is installed and set up for command line usage"
        return 1
    fi

    # capture the content of output folder before running the script
    files_before=$(ls -1 "$OUTPUT_DIR" | grep -v "make.log")

    # log start time for the script
    echo -e "\nScript ${programname}.lyx in lyx -e pdf started at $(date '+%Y-%m-%d %H:%M:%S')" | tee -a "${logfile}"

    # run command and capture both stdout and stderr in the output variable
    # we run using the full path to prevent conversion issues during compilation
    output=$("$lyx_path" --export pdf2 "${programname}.lyx" > "$logfile" 2>&1)
    return_code=$?  # capture the exit status

    # perform cleanup
    cleanup

    # capture the content of output folder after running the script
    files_after=$(ls -1 "$OUTPUT_DIR" | grep -v "make.log")

    # determine the new files that were created
    created_files=$(comm -13 <(echo "$files_before") <(echo "$files_after"))

    # report on errors or success and display the output
    if [ $return_code -ne 0 ]; then
        error_time=$(date '+%Y-%m-%d %H:%M:%S')
        echo -e "\033[0;31mWarning\033[0m: ${programname}.lyx failed at ${error_time}. Check log for details."
        echo "Error in ${programname}.lyx at ${error_time}: $output" >> "${logfile}"
        if [ -n "$created_files" ]; then
            echo -e "\033[0;31mWarning\033[0m: there was an error, but files were created. Check log."
            echo -e "\nWarning: There was an error, but these files were created: $created_files" >> "${logfile}"
        fi
        exit 1
    else
        echo "Script ${programname}.lyx finished successfully at $(date '+%Y-%m-%d %H:%M:%S')" | tee -a "${logfile}"
        echo "Output: $output" >> "${logfile}"

        if [ -n "$created_files" ]; then
            echo -e "\nThe following files were created in ${programname}.lyx:" >> "${logfile}"
            echo "$created_files" >> "${logfile}"
        fi

        if [ ! -f "${OUTPUT_DIR}/${programname}.pdf" ]; then
            echo -e "\033[0;31mWarning\033[0m: No PDF file was created. Check output in log."
            echo -e "\nWarning: No PDF file was created. Check output above." >> "${logfile}"
        fi
    fi
}
