* Configure an isolated ado-path, then run the requested Stata script.

clear all
set more off

args repo_root target_do

if `"`repo_root'"' == "" | `"`target_do'"' == "" {
    display as error "init_stata.do requires the repository root and a target do-file."
    exit 198
}

capture confirm file `"`target_do'"'
if _rc {
    display as error `"Target do-file not found: `target_do'"'
    exit 601
}

local project_ado `"`repo_root'/lib/stata/ado"'
sysdir set PLUS `"`project_ado'"'

* Exclude the standard locations for nonofficial ado-files.
capture quietly adopath - SITE
capture quietly adopath - "."
capture quietly adopath - PERSONAL
capture quietly adopath - PLUS
capture quietly adopath - OLDPLACE
adopath + PLUS

* Refuse to run if profile.do or S_ADO added another custom location.
local remaining_adopath `"`c(adopath)'"'
while `"`remaining_adopath'"' != "" {
    gettoken ado_location remaining_adopath : remaining_adopath, ///
        parse(";") bind
    if `"`ado_location'"' != ";" & ///
            !inlist(`"`ado_location'"', "BASE", "UPDATES", "PLUS") {
        display as error `"Unexpected ado-path entry: `ado_location'"'
        display as error "Only official Stata ado-files and lib/stata/ado are allowed."
        exit 9
    }
}

display as text "Using isolated Stata ado-path:"
adopath

do `"`target_do'"'
