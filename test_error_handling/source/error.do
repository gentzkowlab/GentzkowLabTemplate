* Stata script with intentional error

display "Stata script starting..."
display "This will produce some output..."

display ""
display "Outputting multiple lines to test real-time logging:"
forvalues i = 1/5 {
    display "  Line `i' of output"
}

display ""
display "Now encountering an error..."

* Intentional error - invalid command
this_command_does_not_exist

display "This line should never be reached"
