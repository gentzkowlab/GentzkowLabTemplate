#!/bin/bash

unset run_latex
run_latex() {

    # Get arguments
    programname=$(basename "$1" .tex)
    outputdir="$2"
    logfile="$3"

    echo "Executing: latexmk ${programname}.tex -pdf -bibtex"
    (latexmk "${programname}.tex" -pdf -bibtex >> "${logfile}" 2>&1)

    # Clean up
    mv "${programname}.pdf" "${outputdir}"
    rm -f "${programname}.aux"
    rm -f "${programname}.bbl"
    rm -f "${programname}.blg"
    rm -f "${programname}.log" 
    rm -f "${programname}.out"
    rm -f "${programname}.fdb_latexmk" 
    rm -f "${programname}.fls" 
    rm -f "${programname}.synctex.gz"
}

