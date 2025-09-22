# SaveData: Save and summarize data
# Arguments:
#   df: Data to be saved
#   key: Key variable(s) that uniquely identify rows
#   outfile: Path to save the data (supported formats: .csv, .dta, .RData, .RDS)
#   logfile: Path to log summary statistics (default: same directory as outfile)
#   appendlog: Append to existing log file (default: FALSE)
#   sortbykey: Sort data by key variables (default: TRUE)

# Required Packages
required_packages <- c("data.table", "digest", "dplyr", "hash", "haven", "stargazer")

# Check and prompt for installation if packages are missing
missing_packages <- required_packages[!required_packages %in% installed.packages()[, "Package"]]
if (length(missing_packages) > 0) {
  message("The following required packages are not installed: ", paste(missing_packages, collapse = ", "))
  install_choice <- readline(prompt = "Would you like to install all missing packages? (y/n): ")
  if (tolower(install_choice) == "y") {
    install.packages(missing_packages, dependencies = TRUE)
    lapply(required_packages, library, character.only = TRUE)
  } else {
    stop("Missing required packages. Exiting.")
  }
} else {
  lapply(required_packages, library, character.only = TRUE)
}

SaveData <- function(df, key, outfile, logfile = NULL, appendlog = FALSE, sortbykey = TRUE) {

  if (!is.data.table(df)) {
    setDT(df)
  }

  # map file extension to export function
  DataDictionary <- function() {
    h <- hash::hash()
    h[["csv"]]   <-   c("fwrite", "file = outfile")
    h[["dta"]]   <-   c("write_dta", "outfile")
    h[["RData"]] <-   c("save", "file = outfile")
    h[["RDS"]]   <-   c("saveRDS", "file = outfile")
    h[["Rds"]]   <-   c("saveRDS", "file = outfile")

    return(h)
  }

  CheckExtension <- function(outfile, h, logfile = NULL) {

    file <- basename(outfile)
    dir  <- dirname(outfile)
    extensions <- unlist(strsplit(file, "[.]"))
    
    if (length(extensions)  > 2) {
      stop("FileNameError: Cannot have '.' in filename.")
    } else if (length(extensions) == 2) {
      filetype = extensions[[2]]
    } else {
      filetype = "RDS"
      outfile = paste(outfile, ".RDS", sep="")
    }

    if (!any(filetype %in% hash::keys(h))) {
      stop("FileType Error: Incorrect format. Only .csv, .dta, .RData, and .RDS are allowed.")
    }

    if (is.null(logfile)) {
      logfile <- paste(dir, "/data_file_manifest.log", sep = "")
    }

    return(list("outfile" = outfile, "logfile" = logfile, "filetype" = filetype))
  }

  CheckColumnsNotList <- function(df) {
    column_types <- sapply(df, class)
    type_list_columns <-column_types[column_types=="list"]
    if (length(type_list_columns)>0) {
      stop(paste("TypeError: No column can contain entries of type list or vector. All columns should be in vector format. The following columns are of type list:",
                 paste(names(type_list_columns), collapse = ", ")))
    }
  }

  CheckKey <- function(df, key, colname_order = reordered_colnames) {

    missing_keys <- key[!key %in% colnames(df)]
    if (length(missing_keys) > 0) {
      stop(paste("KeyError: One or more key variables are not in df:",
                 paste(missing_keys, collapse = ", ")))
    }

    missings <- df[, lapply(.SD, function(x) sum(is.na(x))), .SDcols = key]

    if (sum(missings) > 0) {
      stop(paste("KeyError: There are rows with missing keys. Check the following keys:",
                 paste(key[which(missings > 0)], collapse = ", ")))
    }

    nunique <- data.table::uniqueN(df, key)

    if (nrow(df) != nunique) {

      stop("KeyError: Key variables do not uniquely identify observations.")

    } else {

      if (sortbykey) {
        data.table::setorderv(df, key)  # sort by key values
      }

      data.table::setcolorder(df, colname_order)
    }
  }


  WriteLog <- function(df, key, outfile, logfile = NULL, appendlog = TRUE) {

    reordered_colnames = names(df)

    if (logfile == FALSE) return(NULL)

    numeric_cols <- reordered_colnames[sapply(df, FUN = is.numeric)]
    non_numeric_cols <- base::setdiff(reordered_colnames, numeric_cols)

    numeric_sum <- df[, .(
      variable_name = numeric_cols,
      mean = sapply(.SD, function(x) round(mean(x, na.rm = TRUE), 3)),
      sd = sapply(.SD, function(x) round(sd(x, na.rm = TRUE), 3)),
      min = sapply(.SD, function(x) round(min(x, na.rm = TRUE), 3)),
      max = sapply(.SD, function(x) round(max(x, na.rm = TRUE), 3))
    ), .SDcols = numeric_cols]


    non_numeric_sum <- df[, .(
      variable_name = non_numeric_cols,
      uniqueN = sapply(.SD, function(x) uniqueN(x))
    ), .SDcols = non_numeric_cols]

    all_sum <- df[, .(
      variable_name = reordered_colnames,
      type = sapply(.SD, class),
      N = sapply(.SD, function(x) sum(!is.na(x)))
    )]

    sum <- all_sum |>
      merge.data.table(non_numeric_sum, by = "variable_name", all.x = TRUE) |>
      merge.data.table(numeric_sum, by = "variable_name", all.x = TRUE) |>
      arrange(match(variable_name, reordered_colnames))

    hash <- digest::digest(df, algo="md5")

    if (file.exists(logfile) & appendlog) cat('\n', file = logfile, append=T)

    cat("File: ", outfile, '\n', file = logfile, append=appendlog)
    cat("MD5:  ", hash, '\n',    file = logfile, append=T)
    cat("Key:  ", key, '\n',     file = logfile, append=T)

    s = capture.output(
      stargazer::stargazer(sum,
                           summary = F,
                           type = 'text',
                           digit.separate = 3,
                           digit.separator = ',',
                           rownames = F))
    cat(paste(s,"\n"), file = logfile, append=T)

  }

  WriteData <- function(df, outfile, filetype, h) {
    if (filetype == "RData") {
      do.call(h[[filetype]][1], list("df", file = eval(parse(text=h[[filetype]][2]))))
    } else {
      do.call(h[[filetype]][1], list(df, eval(parse(text=h[[filetype]][2]))))
    }
    print(paste0("File '", outfile, "' saved successfully."))

  }

  h <- DataDictionary()
  files <- CheckExtension(outfile, h, logfile)
  CheckColumnsNotList(df)
  reordered_colnames <- c(key, setdiff(colnames(df), key))
  CheckKey(df, key, colname_order = reordered_colnames)
  WriteLog(df, key, files$outfile, files$logfile, appendlog)
  WriteData(df, files$outfile, files$filetype, h)

}