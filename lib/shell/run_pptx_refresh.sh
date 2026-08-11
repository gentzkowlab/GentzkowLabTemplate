#!/bin/bash
# lib/shell/run_pptx_refresh.sh

unset run_pptx_refresh
run_pptx_refresh() {
    trap - ERR  # allow internal error handling

    local pptx_file="${1:-}"
    local logfile="${2:-}"

    if [ -z "${pptx_file}" ] || [ -z "${logfile}" ]; then
        echo "Usage: run_pptx_refresh <pptx_file> <logfile>"
        return 1
    fi

    local output_parent
    output_parent="$(dirname -- "${logfile}")"
    if [ ! -d "${output_parent}" ]; then
        echo "Program error: log directory ${output_parent} not found."
        return 1
    fi

    local module_dir
    module_dir="$(cd "${output_parent}/.." && pwd -P)" || return 1

    local source_path
    if [[ "${pptx_file}" = /* ]]; then
        source_path="${pptx_file}"
    else
        source_path="${module_dir}/source/${pptx_file}"
    fi

    local input_dir="${module_dir}/input"
    local output_dir="${module_dir}/output/pptx-refresh"
    local python_cmd="${pythonCmd:-python3}"

    if ! command -v "${python_cmd}" >/dev/null 2>&1; then
        echo -e "\033[0;31mProgram error\033[0m: ${python_cmd} not found. Set pythonCmd in local_env.sh." | tee -a "${logfile}"
        return 1
    fi
    if ! "${python_cmd}" -c 'import pptx_refresh' >/dev/null 2>&1; then
        echo -e "\033[0;31mProgram error\033[0m: pptx-refresh is not installed for ${python_cmd}. Run setup.sh." | tee -a "${logfile}"
        return 1
    fi
    if [ ! -f "${source_path}" ]; then
        echo -e "\033[0;31mProgram error\033[0m: PPTX file ${source_path} not found." | tee -a "${logfile}"
        return 1
    fi
    if [ ! -d "${input_dir}" ]; then
        echo -e "\033[0;31mProgram error\033[0m: input directory ${input_dir} not found." | tee -a "${logfile}"
        return 1
    fi

    source_path="$(cd "$(dirname -- "${source_path}")" && pwd -P)/$(basename -- "${source_path}")"

    local start_time
    start_time="$(date '+%Y-%m-%d %H:%M:%S')"
    echo -e "\nRefreshing $(basename -- "${source_path}") at ${start_time}" | tee -a "${logfile}"

    "${python_cmd}" -m pptx_refresh build "${source_path}" \
        --input-dir "${input_dir}" \
        --output-dir "${output_dir}" 2>&1 | tee -a "${logfile}"
    local return_code=${PIPESTATUS[0]}

    if [ "${return_code}" -ne 0 ] && [ "${return_code}" -ne 2 ]; then
        echo -e "\033[0;31mWarning\033[0m: PPTX refresh failed. Check ${logfile}." | tee -a "${logfile}"
        return 1
    fi

    local filename
    filename="$(basename -- "${source_path}")"
    local expected_pptx="${output_dir}/${filename%.*}_updated.pptx"
    if [ ! -f "${expected_pptx}" ]; then
        echo -e "\033[0;31mWarning\033[0m: pptx-refresh reported publication, but ${expected_pptx} was not created." | tee -a "${logfile}"
        return 1
    fi

    if [ "${return_code}" -eq 2 ]; then
        echo -e "\033[0;33mReview recommended\033[0m: PPTX refresh published ${expected_pptx}. Review the report before use." | tee -a "${logfile}"
    else
        echo "PPTX refresh published ${expected_pptx}." | tee -a "${logfile}"
    fi
}
