#!/bin/bash

# Check if local_env.sh exists
if [ ! -f "../local_env.sh" ]; then
    echo "We cannot find 'local_env.sh'. Please run 'bash setup.sh' to set up the environment."
    exit 1
fi

# Add other checks as needed

