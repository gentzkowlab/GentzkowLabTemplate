% Short description of script's purpose

function main()
    mpg = readtable('../input/mpg.csv');
    mpg_clean = clean_mpg_data(mpg);
    writetable(mpg_clean, '../output/mpg.csv');
end

function mpg_clean = clean_mpg_data(mpg)
    % Data wrangling steps here
    mpg_clean = mpg;
end

% Execute
if ~isdeployed
    main();
end
