# =============================================================================
# Short description of script's purpose
# =============================================================================

using CSV, DataFrames

# =============================================================================

function main()
    mpg = CSV.read("../input/mpg.csv", DataFrame)
    mpg_clean = clean_data(mpg)
    CSV.write("../output/mpg.csv", mpg_clean)
end

function clean_data(mpg)
    # Some data wrangling steps here
    mpg_clean = mpg
    return mpg_clean
end

# Execute
main()
