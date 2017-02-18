#!/usr/local/bin/jq -cnRrf

# sh continuation lines style
def read_sh:
    foreach inputs as $line (
        { continuing: false, logical_line: "" }
        ;
        if .continuing then 
            if $line[-1:] == "\\" then  # add more text to line
                .logical_line += $line[:-1]
            else                        # complete line
                .continuing = false
                | .logical_line += $line
            end
        elif $line[-1:] == "\\" then    # start continuation line
            .continuing = true
            | .logical_line = $line[:-1]
        else                            # line complete
            .logical_line = $line
        end
        ;
        if .continuing then empty
        else .logical_line end
    )
;

# sh continuation lines style checking bad input
def read_sh_eof:
    def EOF: null;
    def eof($x): $x==null;
    #
    foreach (inputs, EOF) as $line (
        { continuing: false, logical_line: "" }
        ;
        if eof($line)
            then .    # do nothing
        elif .continuing then 
            if $line[-1:] == "\\" then  # add more text to line
                .logical_line += $line[:-1]
            else                        # complete line
                .continuing = false
                | .logical_line += $line
            end
        elif $line[-1:] == "\\" then    # start continuation line
            .continuing = true
            | .logical_line = $line[:-1]
        else                            # line complete
            .logical_line = $line
        end
        ;
        if eof($line) then 
            if .continuing
            then .logical_line  # last line ended in \
            else empty end
        else
            if .continuing then empty
            else .logical_line end
        end
    )
;

#
#read_sh
read_sh_eof

# vim:ai:sw=4:ts=4:et:syntax=jq
