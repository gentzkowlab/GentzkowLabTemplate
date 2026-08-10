#!/bin/bash

unset run_pptx_refresh
run_pptx_refresh () {
    trap - ERR # allow internal error handling

    pptx_file="${1:-}"
    logfile="${2:-}"

    if [ -z "$pptx_file" ] || [ -z "$logfile" ]; then
        echo "Usage: run_pptx_refresh <pptx_file> <logfile>"
        return 1
    fi

    OUTPUT_DIR="$(cd "$(dirname "$logfile")" && pwd -P)"
    MODULE_DIR="$(cd "${OUTPUT_DIR}/.." && pwd -P)"
    INPUT_DIR="${MODULE_DIR}/input"
    PUBLISH_DIR="${OUTPUT_DIR}/pptx-refresh"

    if [ -z "$pptxRefreshCmd" ]; then
        echo -e "\nNo pptx-refresh command set. Using default: pptx-refresh"
        pptxRefreshCmd="pptx-refresh"
    fi

    if ! command -v "$pptxRefreshCmd" > /dev/null 2>&1; then
        error_time=$(date '+%Y-%m-%d %H:%M:%S')
        echo -e "\n\033[0;31mProgram error\033[0m at ${error_time}: ${pptxRefreshCmd} not found. Make sure pptxRefreshCmd is configured in local_env.sh."
        echo "Program Error at ${error_time}: ${pptxRefreshCmd} not found." >> "$logfile"
        return 1
    fi

    if [ ! -f "$pptx_file" ]; then
        error_time=$(date '+%Y-%m-%d %H:%M:%S')
        echo -e "\n\033[0;31mProgram error\033[0m at ${error_time}: presentation ${pptx_file} not found."
        echo "Program Error at ${error_time}: presentation ${pptx_file} not found." >> "$logfile"
        return 1
    fi

    if [ ! -d "$INPUT_DIR" ]; then
        error_time=$(date '+%Y-%m-%d %H:%M:%S')
        echo -e "\n\033[0;31mProgram error\033[0m at ${error_time}: input directory ${INPUT_DIR} not found."
        echo "Program Error at ${error_time}: input directory ${INPUT_DIR} not found." >> "$logfile"
        return 1
    fi

    pptx_file="$(cd "$(dirname -- "$pptx_file")" && pwd -P)/$(basename -- "$pptx_file")"
    presentation_name=$(basename "$pptx_file")
    presentation_stem="${presentation_name%.*}"
    expected_pptx="${PUBLISH_DIR}/${presentation_stem}_updated.pptx"
    expected_pdf="${PUBLISH_DIR}/${presentation_stem}_updated.pdf"
    expected_report="${PUBLISH_DIR}/report/report.json"

    start_time=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "\nRefreshing ${presentation_name} at ${start_time}" | tee -a "$logfile"

    "$pptxRefreshCmd" build "$pptx_file" \
        --input-dir "$INPUT_DIR" \
        --output-dir "$PUBLISH_DIR" \
        >> "$logfile" 2>&1
    return_code=$?

    if [ "$return_code" -ne 0 ] && [ "$return_code" -ne 2 ]; then
        error_time=$(date '+%Y-%m-%d %H:%M:%S')
        echo -e "\033[0;31mWarning\033[0m: ${presentation_name} refresh failed at ${error_time}. Check ${logfile}."
        echo "Error refreshing ${presentation_name} at ${error_time}." >> "$logfile"
        return 1
    fi

    if [ ! -f "$expected_pptx" ] || [ ! -f "$expected_pdf" ] || [ ! -f "$expected_report" ]; then
        error_time=$(date '+%Y-%m-%d %H:%M:%S')
        echo -e "\033[0;31mWarning\033[0m: ${presentation_name} refresh did not publish a complete bundle at ${error_time}. Check ${logfile}."
        echo "Incomplete pptx-refresh bundle at ${PUBLISH_DIR}." >> "$logfile"
        return 1
    fi

    if [ "$return_code" -eq 2 ]; then
        echo -e "\033[0;33mReview recommended\033[0m: ${presentation_name} was published with review items."
        echo "pptx-refresh published with review items." >> "$logfile"
    fi

    echo "Presentation ${presentation_name} refreshed successfully at $(date '+%Y-%m-%d %H:%M:%S')" | tee -a "$logfile"
    echo "Published bundle: ${PUBLISH_DIR}" >> "$logfile"
    return 0
}
