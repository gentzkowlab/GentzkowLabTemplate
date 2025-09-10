#!/bin/bash

unset run_rmd
run_rmd () {
    trap - ERR  # Allow internal error handling

    # Get arguments
    program="$1"    
    logfile="$2"   
    OUTPUT_DIR=$(dirname "$logfile")/../output  

    programname=$(basename "$1" .Rmd)

    # Set R command if unset
    if [ -z "$rCmd" ]; then
        echo -e "\nNo R command set. Using default: Rscript"
        rCmd="Rscript"
    fi

    # Check if the R command exists before running, log error if it does not
    if ! command -v "${rCmd}" &> /dev/null; then
        error_time=$(date '+%Y-%m-%d %H:%M:%S')
        echo -e "\n\033[0;31mProgram error\033[0m at ${error_time}: ${rCmd} not found. Make sure command line usage is properly set up." 
        echo "Program Error at ${error_time}: ${rCmd} not found." >> "${logfile}"
        exit 1  # Exit early with an error code
    fi

    # Check if the target .Rmd script exists
    if [ ! -f "${program}" ]; then
        error_time=$(date '+%Y-%m-%d %H:%M:%S')
        echo -e "\n\033[0;31mProgram error\033[0m at ${error_time}: script ${program} not found." 
        echo "Program Error at ${error_time}: script ${program} not found." >> "${logfile}"
        exit 1
    fi

    # Check and install rmarkdown
    echo "Checking if 'rmarkdown' package is installed..." >> "${logfile}" 
    if ! ${rCmd} -e "suppressPackageStartupMessages(library(rmarkdown))" &> /dev/null; then
        echo -e "\n \033[0;31mWarning\033[0m: The 'rmarkdown' package is not installed."
        echo -e "Would you like to install 'rmarkdown' globally? (y/n): " 
        read -r install_choice

        if [[ "$install_choice" == "y" ]]; then
            echo "Installing 'rmarkdown' package globally..."
            ${rCmd} -e "install.packages('rmarkdown', repos='http://cran.rstudio.com/')" >> "${logfile}"
            if [ $? -ne 0 ]; then
                echo -e "\n\033[0;31mError\033[0m: Failed to install 'rmarkdown'. Please check your R setup or install the package manually." | tee -a "${logfile}"
                exit 1
            else
                echo "'rmarkdown' installed successfully." | tee -a "${logfile}"
            fi
        else
            echo -e "\n\033[0;33mNotice\033[0m: 'rmarkdown' package is required. Please install it within your R environment and rerun the script." | tee -a "${logfile}"
            exit 1
        fi
    else
        echo "'rmarkdown' package is already installed." >> "${logfile}" 
    fi
    
    # Capture the content of the output folder before running the script
    if [ -d "${OUTPUT_DIR}" ]; then
        files_before=$(find "${OUTPUT_DIR}" -type f ! -name "make.log" -exec basename {} + | sort)
    else
        mkdir -p "${OUTPUT_DIR}"
        files_before=""
    fi

    # Log start time for the script
    start_time=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "\nRendering ${program} started at ${start_time}" | tee -a "${logfile}"

    # Run the R Markdown rendering command and capture both stdout and stderr
    output=$(${rCmd} -e "rmarkdown::render('${program}', output_dir='${OUTPUT_DIR}', clean=TRUE)" 2>&1)
    return_code=$?  # Capture the exit status 

    # Capture the content of the output folder after running the script
    if [ -d "${OUTPUT_DIR}" ]; then
        files_after=$(find "${OUTPUT_DIR}" -type f ! -name "make.log" -exec basename {} + | sort)
    else
        files_after=""
    fi

    # Determine the new files that were created
    created_files=$(comm -13 <(echo "$files_before") <(echo "$files_after"))

    # Clean up 
    rm -f "${programname}.log" 

    # Report on errors or success and display the output
    if [ $return_code -ne 0 ]; then
        error_time=$(date '+%Y-%m-%d %H:%M:%S')
        echo -e "\033[0;31mWarning\033[0m: Rendering ${program} failed at ${error_time}. Check log for details." # Display error warning in terminal
        echo "Error in rendering ${program} at ${error_time}: $output" >> "${logfile}"  # Log error output
        if [ -n "$created_files" ]; then
            echo -e "\033[0;31mWarning\033[0m: An error occurred, but files were created. Check log." 
            echo -e "\nWarning: An error occurred, but these files were created: $created_files" >> "${logfile}"  # Log created files
        fi
        exit 1 
    else
        echo "Rendering ${program} finished successfully at $(date '+%Y-%m-%d %H:%M:%S')" | tee -a "${logfile}"
        echo "Output: $output" >> "${logfile}"  # Log output
        
        if [ -n "$created_files" ]; then
            echo -e "\nThe following files were created during rendering:" >> "${logfile}" 
            echo "$created_files" >> "${logfile}"  # List files in output folder
        else
            echo -e "\nNo new files were created during rendering." >> "${logfile}" 
        fi
    fi
}
