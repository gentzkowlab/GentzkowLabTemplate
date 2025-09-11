#!/bin/bash

unset run_latex
unset cleanup
run_latex() {
   trap - ERR # allow internal error handling
   
    # Get arguments
    programname=$(basename "$1" .tex)
    logfile="$2"

    # Set output directory
    # (If no third argument is provided, use the default)
    if [ -n "$3" ]; then
        OUTPUT_DIR="$3"
    else
        OUTPUT_DIR="../output"
    fi
    
    # Clean up
    cleanup() {
        if [ -f "${programname}.pdf" ]; then
        mv "${programname}.pdf" "${OUTPUT_DIR}"
        fi
        rm -f "${programname}.aux" \
              "${programname}.bbl" \
              "${programname}.blg" \
              "${programname}.log" \
              "${programname}.out" \
              "${programname}.fdb_latexmk" \
              "${programname}.fls" \
              "${programname}.synctex.gz" \
              "${programname}.nav" \
              "${programname}.snm" \
              "${programname}.toc"
    }

    # Ensure cleanup is called on exit
    trap 'cleanup' EXIT

    # Check if latexmk command exists
    if ! command -v latexmk &> /dev/null; then
        error_time=$(date '+%Y-%m-%d %H:%M:%S')
        echo -e "\n\033[0;31mProgram error\033[0m at ${error_time}: latexmk not found. Ensure LaTeX is installed." 
        echo "Program Error at ${error_time}: latexmk not found." >> "${logfile}"
        exit 1
    fi
 
    # check if the target script exists
    if [ ! -f "${programname}.tex" ]; then
        error_time=$(date '+%Y-%m-%d %H:%M:%S')
        echo -e "\n\033[0;31mProgram error\033[0m at ${error_time}: script ${programname}.tex not found." 
        echo "Program Error at ${error_time}: script ${programname}.tex not found." >> "${logfile}"
        exit 1
    fi
    
    # capture the content of output folder before running the script
    files_before=$(find "$OUTPUT_DIR" -type f ! -name "make.log" -exec basename {} + | tr '\n' ' ')

    # log start time for the script
    start_time=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "\nScript ${programname}.tex in latexmk -pdf -bibtex started at ${start_time}" | tee -a "${logfile}"

    # run command and capture both stdout and stderr in the output variable
    output=$(latexmk -interaction=nonstopmode -f "${programname}.tex" -pdf -bibtex 2>&1)
    return_code=$? # capture the exit status 

    # perform cleanup
    cleanup

    # capture the content of output folder after running the script
     files_after=$(find "$OUTPUT_DIR" -type f -newermt "$start_time" ! -name "make.log" -exec basename {} + | tr '\n' ' ')
    
    # determine the new files that were created
    created_files=$(comm -13 <(echo "$files_before") <(echo "$files_after"))

    # report on errors or success and display the output
    if [ $return_code -ne 0 ]; then
        error_time=$(date '+%Y-%m-%d %H:%M:%S')
        echo -e "\033[0;31mWarning\033[0m: ${programname}.tex failed at ${error_time}. Check log for details." # display error warning in terminal
        echo "Error in ${programname}.tex at ${error_time}: $output" >> "${logfile}"  # log error output
        if [ -n "$created_files" ]; then
            echo -e "\033[0;31mWarning\033[0m: there was an error, but files were created. Check log." 
            echo -e "\nWarning: There was an error, but these files were created: $created_files" >> "${logfile}"  # log created files
        fi
        exit 1 
    else
        echo "Script ${programname}.tex finished successfully at $(date '+%Y-%m-%d %H:%M:%S')" | tee -a "${logfile}"
        echo "Output: $output" >> "${logfile}"  # log output
        
        if [ -n "$created_files" ]; then
        echo -e "\nThe following files were created in ${programname}.tex:"  >> "${logfile}" 
        echo "$created_files" >> "${logfile}" # list files in output folder
        fi

        if [ ! -f "${OUTPUT_DIR}/${programname}.pdf" ]; then
            echo -e "\033[0;31mWarning\033[0m: No PDF file was created. Check output in log." 
            echo -e "\nWarning: No PDF file was created. Check output above." >> "${logfile}"  # log warning
        fi
    fi

}

