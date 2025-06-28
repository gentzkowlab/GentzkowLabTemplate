#!/bin/bash
# lib/shell/run_pptx.sh

unset run_pptx
run_pptx () {
    trap - ERR   # allow internal error handling 

    # get arguments
    pptx_file="$1"          
    logfile="$2"       
    OUTPUT_DIR=$(dirname "$logfile")

    # check if the command exists before running, log error if does not
    if [ -z "$pptx_file" ] || [ -z "$logfile" ]; then
        echo "Usage: run_pptx <pptx_file> <logfile>"; exit 1
    fi
    if ! command -v osascript >/dev/null; then
        echo -e "\033[0;31mProgram error\033[0m: osascript not found (macOS only)." | tee -a "$logfile"
        exit 1
    fi

    # check if the target script exists
    if [ ! -f "$pptx_file" ]; then
        echo -e "\033[0;31mProgram error\033[0m: PPTX file $pptx_file not found." | tee -a "$logfile"
        exit 1
    fi

    # resolve to absolute path so AppleScript sees the full file name 
    pptx_file="$(cd "$(dirname -- "$pptx_file")" && pwd -P)/$(basename -- "$pptx_file")"

    # locate AppleScript code for conversion
    if [ -z "$REPO_ROOT" ]; then
        REPO_ROOT=$(git rev-parse --show-toplevel)
    fi
    scpt="${REPO_ROOT}/lib/applescript/run_pptx.scpt"
    if [ ! -f "$scpt" ]; then
        echo -e "\033[0;31mProgram error\033[0m: AppleScript $scpt not found." | tee -a "$logfile"
        exit 1
    fi

    # build output path 
    pdf_path="${OUTPUT_DIR}/$(basename "$pptx_file" .pptx).pdf"

    # capture the content of output folder before running the script
    files_before=$(find "$OUTPUT_DIR" -type f ! -name "make.log" -exec basename {} + | tr '\n' ' ')
    
    # log start time for the script
    start_time=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "\nConverting $(basename "$pptx_file") to PDF at $start_time" | tee -a "$logfile"

    # run command and capture both stdout and stderr in the output variable
    output=$(osascript "$scpt" "$pptx_file" "$pdf_path" 2>&1)
    return_code=$?

    # capture the content of output folder after running the script
    files_after=$(find "$OUTPUT_DIR" -type f -newermt "$start_time" ! -name "make.log" -exec basename {} + | tr '\n' ' ')

    # determine the new files that were created
    created_files=$(comm -13 <(echo "$files_before") <(echo "$files_after"))

    # report on errors or success and display the output
    if [ $return_code -ne 0 ]; then
        echo -e "\033[0;31mWarning\033[0m: PPTX conversion failed. See log." | tee -a "$logfile"
        echo "Error output: $output" >> "$logfile"
        exit 1
    else
        echo "PPTX converted successfully at $(date '+%Y-%m-%d %H:%M:%S')" | tee -a "$logfile"
        echo "$output" >> "$logfile"
        if [ -n "$created_files" ]; then
            echo -e "\nThe following files were created:" >> "$logfile"
            echo "$created_files" >> "$logfile"
        fi
    fi
}
