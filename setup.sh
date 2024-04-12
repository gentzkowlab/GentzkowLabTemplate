#!/bin/bash   

# Create local_env.sh if it does not exist. This is a configuration file
# that contains paths, executable names, and other settings specific to 
# a user's local machine. It file is ignored by Git so changes only affect
# the local copy of the repository.
if [ -f "local_env.sh" ]; then
    echo "Note: File local_env.sh already exists"
else
    cp lib/setup/local_env_template.sh local_env.sh
fi

# # Check if the operating system is Windows
# if [[ "$(uname -a)" == *Microsoft* ]] || [[ "$(uname -a)" == *microsoft* ]]; then
#     echo "Detected Windows environment. Attempting to convert line endings..."

#     # Attempt to convert line endings using dos2unix
#     if find ./ -type f -exec dos2unix {} +; then
#         echo "Successfully converted line endings to Unix format."
#     else
#         echo "Failed to convert line endings. Please ensure dos2unix is installed."
#         echo "If dos2unix is not installed, you can install it using:"
#         echo "sudo apt-get update"
#         echo "sudo apt-get install dos2unix"
#     fi
# fi
