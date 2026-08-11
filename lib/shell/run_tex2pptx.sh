#!/bin/bash
# lib/shell/run_tex2pptx.sh

unset run_tex2pptx
run_tex2pptx() {
    trap - ERR  # allow internal error handling

    local tex_file="${1:-}"
    local logfile="${2:-}"

    if [ -z "${tex_file}" ] || [ -z "${logfile}" ]; then
        echo "Usage: run_tex2pptx <tex_file> <logfile>"
        return 1
    fi

    local output_dir
    output_dir="$(dirname -- "${logfile}")"
    if [ ! -d "${output_dir}" ]; then
        echo "Program error: output directory ${output_dir} not found."
        return 1
    fi

    local module_dir
    module_dir="$(cd "${output_dir}/.." && pwd -P)" || return 1

    local source_path
    if [[ "${tex_file}" = /* ]]; then
        source_path="${tex_file}"
    else
        source_path="${module_dir}/source/${tex_file}"
    fi

    local python_cmd="${pythonCmd:-python3}"

    if ! command -v "${python_cmd}" >/dev/null 2>&1; then
        echo -e "\033[0;31mProgram error\033[0m: ${python_cmd} not found. Set pythonCmd in local_env.sh." | tee -a "${logfile}"
        return 1
    fi
    if ! "${python_cmd}" -c 'import tex2pptx' >/dev/null 2>&1; then
        echo -e "\033[0;31mProgram error\033[0m: tex2pptx is not installed for ${python_cmd}. Run setup.sh." | tee -a "${logfile}"
        return 1
    fi
    if [ ! -f "${source_path}" ]; then
        echo -e "\033[0;31mProgram error\033[0m: TeX file ${source_path} not found." | tee -a "${logfile}"
        return 1
    fi

    source_path="$(cd "$(dirname -- "${source_path}")" && pwd -P)/$(basename -- "${source_path}")"

    local start_time
    start_time="$(date '+%Y-%m-%d %H:%M:%S')"
    echo -e "\nConverting $(basename -- "${source_path}") to PowerPoint at ${start_time}" | tee -a "${logfile}"

    "${python_cmd}" -m tex2pptx convert "${source_path}" \
        --to "${output_dir}" 2>&1 | tee -a "${logfile}"
    local return_code=${PIPESTATUS[0]}

    if [ "${return_code}" -ne 0 ]; then
        echo -e "\033[0;31mWarning\033[0m: TeX-to-PowerPoint conversion failed. Check ${logfile}." | tee -a "${logfile}"
        return 1
    fi

    local source_name
    source_name="$(basename -- "${source_path}")"
    local report_dir="${output_dir}/${source_name%.*}-report"
    local report_json="${report_dir}/conversion-report.json"
    if [ ! -f "${report_json}" ]; then
        echo -e "\033[0;31mWarning\033[0m: tex2pptx reported success, but ${report_json} was not created." | tee -a "${logfile}"
        return 1
    fi

    local presentation_name
    presentation_name="$("${python_cmd}" -c '
import json
import pathlib
import sys

payload = json.loads(pathlib.Path(sys.argv[1]).read_text(encoding="utf-8"))
name = payload.get("output")
if (
    not isinstance(name, str)
    or pathlib.Path(name).name != name
    or pathlib.Path(name).suffix.lower() != ".pptx"
):
    raise SystemExit(1)
print(name)
' "${report_json}")" || {
        echo -e "\033[0;31mWarning\033[0m: ${report_json} does not name a published PowerPoint file." | tee -a "${logfile}"
        return 1
    }

    local expected_pptx="${output_dir}/${presentation_name}"
    if [ ! -f "${expected_pptx}" ]; then
        echo -e "\033[0;31mWarning\033[0m: tex2pptx reported publication, but ${expected_pptx} was not created." | tee -a "${logfile}"
        return 1
    fi

    local presentation_stem="${presentation_name%.*}"
    local required_output
    for required_output in \
        "${output_dir}/${presentation_stem}-from-latex.pdf" \
        "${output_dir}/${presentation_stem}-from-powerpoint.pdf" \
        "${report_dir}/conversion-report.html"; do
        if [ ! -f "${required_output}" ]; then
            echo -e "\033[0;31mWarning\033[0m: tex2pptx reported publication, but ${required_output} was not created." | tee -a "${logfile}"
            return 1
        fi
    done

    local publication_quality
    publication_quality="$("${python_cmd}" -c '
import json
import pathlib
import sys

payload = json.loads(pathlib.Path(sys.argv[1]).read_text(encoding="utf-8"))
print(payload.get("metrics", {}).get("publication_quality", "unknown"))
' "${report_json}")" || publication_quality="unknown"

    if [ "${publication_quality}" = "review-required" ]; then
        echo -e "\033[0;33mReview recommended\033[0m: tex2pptx published ${expected_pptx}. Review both PDFs and ${report_dir}/conversion-report.html." | tee -a "${logfile}"
    else
        echo "tex2pptx published ${expected_pptx}." | tee -a "${logfile}"
    fi
}
