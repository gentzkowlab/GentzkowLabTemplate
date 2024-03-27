on run argv
    set pptFile to item 1 of argv
    set pdfPath to item 2 of argv
    
    try
        tell application "Microsoft PowerPoint"
            activate
            open pptFile
            save active presentation in pdfPath as save as PDF 
            close active presentation saving no
            quit
        end tell
    
    -- Display a success message
        display dialog "PDF saved successfully at " & pdfPath
    on error errMsg
        -- Display an error message if something goes wrong
        display dialog "Error: " & errMsg
    end try
end run




