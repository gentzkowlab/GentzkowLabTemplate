#!/usr/bin/env Rscript

cat("R script starting...\n")
cat("This will produce some output...\n")
Sys.sleep(1)

cat("\nOutputting multiple lines to test real-time logging:\n")
for (i in 1:5) {
    cat(sprintf("  Line %d of output\n", i))
    Sys.sleep(0.5)
}

cat("\nNow encountering an error...\n")
Sys.sleep(1)

# Intentional error
stop("ERROR: Something went wrong in R!")
