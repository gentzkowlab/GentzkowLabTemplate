#!/bin/bash

# Trap to handle shell script errors 
trap 'error_handler' ERR
error_handler() {
    error_time=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "\n\033[0;31mWarning\033[0m: setup.sh failed at ${error_time}. Check above for details." # display warning in terminal
    exit 1 # early exit with error code
}

REPO_ROOT="$(git rev-parse --show-toplevel)"

# Check if local_env.sh exists
echo "Checking if local_env.sh exists..."
echo "It is required to run the module correctly according to your local setup."
if [ ! -f "${REPO_ROOT}/local_env.sh" ]; then
    echo "The file local_env.sh was not found at the root of the repository."
    echo -e "\n\033[0;34mPlease choose:\033[0m Would you like to create local_env.sh from /lib/setup/local_env_template.sh? (y/n): "
    read -r local_env_confirm
    if [[ "$local_env_confirm" != "y" ]]; then
        echo -e "\nOK. Please create local_env.sh and re-run this script."
        exit 1
    fi

    cp "${REPO_ROOT}/lib/setup/local_env_template.sh" "${REPO_ROOT}/local_env.sh"
    echo "local_env.sh has been created from the template."
    echo "Please edit it to reflect your local executables and external file paths."
    echo -e "Press \033[0;34mEnter\033[0m to continue after editing or re-run setup.sh once you've done so."
    read
    else
        echo -e "\033[0;34mNote:\033[0m: local_env.sh already exists."
fi

# Optionally install pptx-refresh into the Python
# interpreter configured in local_env.sh
source "${REPO_ROOT}/local_env.sh"
PYTHON_SETUP_CMD="${pythonCmd:-python3}"
INSTALL_PPTX_REFRESH="${installPptxRefresh:-false}"

if [ "${INSTALL_PPTX_REFRESH}" != "true" ] && [ "${INSTALL_PPTX_REFRESH}" != "false" ]; then
    echo -e "\033[0;31mProgram error\033[0m: installPptxRefresh must be \"true\" or \"false\" in local_env.sh."
    exit 1
fi

if [ "${INSTALL_PPTX_REFRESH}" = "false" ]; then
    echo -e "\nSkipping optional pptx-refresh installation. Set installPptxRefresh=\"true\" in local_env.sh to enable it."
fi

if [ "${INSTALL_PPTX_REFRESH}" = "true" ]; then
    echo -e "\nSetting up pptx-refresh with ${PYTHON_SETUP_CMD}..."
    if ! command -v "${PYTHON_SETUP_CMD}" >/dev/null 2>&1; then
        echo -e "\033[0;31mProgram error\033[0m: ${PYTHON_SETUP_CMD} not found."
        echo "Set pythonCmd in local_env.sh to Python 3.10 or newer, then re-run setup.sh."
        exit 1
    fi

    if ! "${PYTHON_SETUP_CMD}" -c 'import sys; raise SystemExit(sys.version_info < (3, 10))'; then
        echo -e "\033[0;31mProgram error\033[0m: Python 3.10 or newer is required."
        exit 1
    fi

    if ! "${PYTHON_SETUP_CMD}" -m pip --version >/dev/null 2>&1; then
        echo -e "\033[0;31mProgram error\033[0m: pip is unavailable for ${PYTHON_SETUP_CMD}."
        exit 1
    fi

    "${PYTHON_SETUP_CMD}" -m pip install --disable-pip-version-check \
        "pptx-refresh==0.1.1"
    "${PYTHON_SETUP_CMD}" -m pip check

    "${PYTHON_SETUP_CMD}" -m pptx_refresh --version
    echo "pptx-refresh is ready."
fi

# Run get_inputs.sh scripts
echo -e "\nNow, we will loop through the repository and run scripts to add input files to each module."
echo -e "\033[0;34mPlease choose:\033[0m Would you like to run all get_inputs.sh scripts in the repository? (y/n): "
read -r get_inputs_confirm
if [[ "$get_inputs_confirm" == "y" ]]; then
    # Find all get_inputs.sh scripts
    find "$REPO_ROOT" -type f -name 'get_inputs.sh' -print0 |
    sort -z |
    while IFS= read -r -d '' get_inputs_script; do
        module_dir=$(dirname "$get_inputs_script")
        module_name=$(basename "$module_dir")
        echo -e "\nProcessing module \033[35m${module_name}\033[0m"
        (
            cd "$module_dir" 
            ${SHELL} "$get_inputs_script"
        )
    done
    echo -e "\nAll get_inputs.sh scripts have been run."

    else
        echo -e "\nOK. Skipping get_inputs.sh scripts."
fi

# Optional: Create external symlinks
echo -e "\nNow, we will create links to external files, if there are any."
source "${REPO_ROOT}/lib/shell/make_externals.sh"

# Setup Completed
echo -e "\nSetup complete."

# Check setup
source "${REPO_ROOT}/lib/shell/check_setup.sh"
