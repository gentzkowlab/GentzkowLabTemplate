#!/bin/bash   

unset run_stata
run_stata() {
    # get arguments
    program="$1"
    logfile="$2"
    programname="${program%.*}"

    # set Stata command if unset
    if [ -z "$stataCmd" ]; then
        echo "No Stata command set. Using default: StataMP"
        stataCmd="StataMP"
    fi

    # run program, add output to logfile
    echo "Executing: ${stataCmd} ${program}"
    (
        ${stataCmd} -b -e do ${program} 1>> "${logfile}" 2>> "${logfile}"

        # report on errors
        if [ $? -ne 0 ]; then
            echo "Error: ${program} failed with exit code $return_code" | tee -a "${logfile}"
        fi
    )

    # add default log to log file and then delete default log
    cat "${programname}.log" >> "${logfile}"
    rm "${programname}.log"
}
