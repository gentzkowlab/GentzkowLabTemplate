#!/bin/bash   

unset run_stata
run_stata() {
    trap - ERR # allow internal error handling

    # get arguments
    program="$1"
    logfile="$2"
    OUTPUT_DIR=$(dirname "$logfile")
    programname="${program%.*}"

    # set Stata command if unset
    if [ -z "$stataCmd" ]; then
        echo -e "\nNo Stata command set. Using default: StataMP"
        stataCmd="StataMP"
    fi

    # check if the command exists before running, log error if does not
    if ! command -v ${stataCmd} &> /dev/null; then
        error_time=$(date '+%Y-%m-%d %H:%M:%S')
        echo -e "\n\033[0;31mProgram error\033[0m at ${error_time}: ${stataCmd} not found. Make sure command line usage is properly set up." 
        echo "Program Error at ${error_time}: ${stataCmd} not found." >> "${logfile}"
        exit 1  # exit early with an error code
    fi
     
    # check if the target script exists
    if [ ! -f "${program}" ]; then
        error_time=$(date '+%Y-%m-%d %H:%M:%S')
        echo -e "\n\033[0;31mProgram error\033[0m at ${error_time}: script ${program} not found." 
        echo "Program Error at ${error_time}: script ${program} not found." >> "${logfile}"
        exit 1
    fi

    # capture the content of output folder before running the script
    files_before=$(find "$OUTPUT_DIR" -type f ! -name "make.log" -exec basename {} + | tr '\n' ' ')

    # log start time for the script
    start_time=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "\nScript ${program} in ${stataCmd} started at ${start_time}" | tee -a "${logfile}"

    # run command and capture both stdout and stderr in log file
    ${stataCmd} -e do "${program}" >> "${logfile}" 2>&1
   
   # parse the log file to check for Stata error codes like `r(error)`
    if egrep --before-context=1 --max-count=1 "^r\([0-9]+\);" "${programname}.log" > /dev/null 2>&1; then
        return_code=1  # set the return code to 1 if any errors were found
    fi

    # capture the content of output folder after running the script
    files_after=$(find "$OUTPUT_DIR" -type f -newermt "$start_time" ! -name "make.log" -exec basename {} + | tr '\n' ' ')

    # determine the new files that were created
    created_files=$(comm -13 <(echo "$files_before") <(echo "$files_after"))

    # report on errors or success and display the output
    if [ "${return_code:-0}" -ne 0 ]; then
        error_time=$(date '+%Y-%m-%d %H:%M:%S')
        echo -e "\033[0;31mWarning\033[0m: ${program} failed at ${error_time}. Check log for details." # display error warning in terminal
        echo "Error in ${program} at ${error_time}:" >> "${logfile}"  # log error output
        # add default log to log file and then delete default log
        cat "${programname}.log" >> "${logfile}"
        rm "${programname}.log"

        if [ -n "$created_files" ]; then
            echo -e "\033[0;31mWarning\033[0m: there was an error, but files were created. Check log." 
            echo -e "\nWarning: There was an error, but these files were created: $created_files" >> "${logfile}"  # log created files
        fi
        exit 1 
    else
        echo "Script ${program} finished successfully at $(date '+%Y-%m-%d %H:%M:%S')" | tee -a "${logfile}"
        echo "Output:" >> "${logfile}"  # log output

        # add default log to log file and then delete default log
        cat "${programname}.log" >> "${logfile}"
        rm "${programname}.log"
        
        if [ -n "$created_files" ]; then
        echo -e "\nThe following files were created in ${program}:"  >> "${logfile}" 
        echo "$created_files" >> "${logfile}" # list files in output folder
        fi
    fi

}
