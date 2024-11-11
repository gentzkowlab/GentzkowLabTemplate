# =============================================================================
# Short description of script's purpose
# =============================================================================

using CSV, DataFrames, GLM, Plots, RegressionTables

# Off-screen plotting
ENV["GKSwstype"] = "100"

input_dir = "../../1_data/output"
output_dir = "../output"

# =============================================================================

function main()
    data = CSV.read("../input/mpg.csv", DataFrame)
    regression_table(data)
    city_figure(data)
    hwy_figure(data)
end

function regression_table(data)
    reg_cty = lm(@formula(displ ~ cty), data)
    reg_hwy = lm(@formula(displ ~ hwy), data)
    reg_hwy_cty = lm(@formula(displ ~ hwy + cty), data)

    display(coeftable(reg_cty))
    display(coeftable(reg_hwy))
    display(coeftable(reg_hwy_cty))

    regtable(
        reg_cty, reg_hwy, reg_hwy_cty;
        render = LatexTable(),
        file = joinpath(output_dir, "table_reg.tex")
    )
end

function city_figure(data)
    p = scatter(data.displ, data.cty, group=data.year,
                xlabel="Engine displacement (L)",
                ylabel="City fuel economy (mpg)",
                legend_title="Year")
    savefig(p, "../output/figure_city.png")
end

function hwy_figure(data)
    p = scatter(data.displ, data.hwy, group=data.year,
                xlabel="Engine displacement (L)",
                ylabel="Highway fuel economy (mpg)",
                legend_title="Year")
    savefig(p, "../output/figure_hwy.png")
end

# Execute
main()
