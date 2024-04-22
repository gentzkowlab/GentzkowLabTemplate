# PowerPoint to PDF Conversion

## Summary

This extension includes the functionality to convert a PowerPoint (.pptx) into a PDF (.pdf) using Apple Script.

## How to Use

To enable this functionality, you must move the `powerpoint` module out of `extensions` so that it is in parallel with all other modules and rename it to `5_pptx`. You must then move any PowerPoint files that you would like to convert into PDF into the `5_pptx/source` directory. These files will be converted into PDFs and stored in `5_pptx/output`.

If you would like to toggle this functionality in `run_all.sh`, you need to uncomment related line `${SHELL} 5_pptx/make.sh`. 

## Potential Warning

This will only work on Mac OS. 
You may be asked to grant file access when running the program for the first time through a pop-up window.
You may recieve an error like this: `./5_pptx/make.sh: Permission denied`. To rectify this, you must execute `chmod +x make.sh` in your terminal. 
