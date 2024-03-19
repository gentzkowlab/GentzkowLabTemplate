#!/bin/bash   

unset run_python
run_python () {

    # get arguments
    program="$1"
    logfile="$2"

    # set python command if unset
    if [ -z "$pythonCmd" ]; then
        echo "No python command set. Using default: python"
        pythonCmd="python"
    fi

    # run program, add output to logfile
    echo "Executing: ${pythonCmd} ${program}"
    (
        ${pythonCmd} ${program} >> "${logfile}"

        # report on errors
        return_code=$?
        if [ $return_code -ne 0 ]; then
            # Log an error message if the command failed
            echo "Error: ${program} failed with exit code $return_code"
        fi
    )
}
