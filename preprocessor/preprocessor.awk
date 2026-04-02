# HTML preprocessor
# Written by mebibytedraco (https://github.com/mebibytedraco)

function printErrorLine(line, lineNum, filename) {
    print filename ":" lineNum ":" > err
    print line > err
}

function processFile(filename, defines,
        printAtEnd, line, dir, lineNum) {
    lineNum = 1
    readError = 0
    while ((readError = getline line < filename) > 0) {
        printAtEnd = 1
        # Loop until there are no more directives on this line
        while (line ~ /%\[.*\]%/) {
            # Line contains a preprocessing directive, so extract the first
            # directive
            dir["index"] = match(line, /%\[.*\]%/)
            dir["str"] = substr(line, dir["index"], RLENGTH)
            # Extract the directive name
            tempIndex = match(dir["str"], /[[:alnum:]_]+/)
            dir["name"] = substr(dir["str"], tempIndex, RLENGTH)
            # Extract any arguments
            dir["args"] = substr(dir["str"], tempIndex + RLENGTH)
            sub(/^[[:space:]]*/, "", dir["args"])
            sub(/[[:space:]]*\]%/, "", dir["args"])
            # Check which directive has been used
            if (dir["name"] == "INCLUDE") {
                # If invalid arguments were provided, print error and exit
                if (dir["args"] !~ /^".*"$/) {
                    print "error: invalid arguments to INCLUDE" > err
                    printErrorLine(line, lineNum, filename)
                    exit 1
                }
                # Get name of file to include
                tempIndex = match(dir["args"], /"[^"]*"/)
                dir["filename"] = substr(dir["args"], tempIndex + 1,
                       length(dir["args"]) - 2);
                # Process the included file using a recursive call
                if (processFile(dir["filename"], defines)) {
                    # Handle the error if the file couldn't be opened
                    errStr = "error: couldn't read file \""
                    errStr = errStr dir["filename"] "\""
                    print errStr > err
                    printErrorLine(line, lineNum, filename)
                    exit 1
                }
                #print "--- INCLUDED " dir["filename"] " ---" > err
                # Clear the line to prevent any further processing, and
                # prevent the line from being printed
                line = ""
                printAtEnd = 0
            } else {
                # Print an error and terminate
                print "error: invalid directive \"" dir["name"] "\"" > err
                printErrorLine(line, lineNum, filename)
                exit 1
            }
            # Substitute a new value for the directive
            sub(/%\[.*\]%/, dir["sub"], line)
        }
        if (printAtEnd) {
            print line
        }
        lineNum++
    }
    return readError
}

BEGIN {
    err = "/dev/stderr"
    processFile("/dev/stdin")
    exit 0
}
