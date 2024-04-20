on run argv
    set pptFile to item 1 of argv
    set pdfPath to item 2 of argv
    
    tell application "Microsoft PowerPoint"
        open pptFile
        set exportPath to pdfPath as POSIX file
        save active presentation in exportPath as save as PDF
        close active presentation saving no
        quit
    end tell
end run








