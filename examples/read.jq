#!/usr/local/bin/jq -cnRrf

include "fadado.github.io/prelude";

import "fadado.github.io/string/ascii" as ascii;
import "fadado.github.io/string" as str;

# sh continuation lines style
def read_sh:
    foreach inputs as $line (
        { continuing: false, logical_line: "" }
        ;
        if .continuing then 
            if $line[-1:] == "\\" then  # add more text to line
                .logical_line += $line[:-1]
            else                        # complete line
                .continuing = false  |
                .logical_line += $line
            end
        elif $line[-1:] == "\\" then    # start continuation line
            .continuing = true |
            .logical_line = $line[:-1]
        else                            # line complete
            .logical_line = $line
        end
        ;
        select(.continuing) | .logical_line
    )
;

def XXXread_sh:
    def init:
        { continuing: false, logical_line: "" }
    ;
    def update($line):
        if .continuing then 
            if $line[-1:] == "\\" then  # add more text to line
                .logical_line += $line[:-1]
            else                        # complete line
                .continuing = false  |
                .logical_line += $line
            end
        elif $line[-1:] == "\\" then    # start continuation line
            .continuing = true |
            .logical_line = $line[:-1]
        else                            # line complete
            .logical_line = $line
        end
    ;
    def extract:
        select(.continuing)
        |.logical_line
    ;
    foreach inputs as $line
        (init; update($line); extract)
;

# sh continuation lines style checking bad input
def read_sh_check:
    foreach (inputs, null) as $line (
        { continuing: false, logical_line: "" }
        ;
        if $line==null # EOF
        then .    # do nothing
        elif .continuing then 
            if $line[-1:] == "\\" then  # add more text to line
                .logical_line += $line[:-1]
            else                        # complete line
                .continuing = false |
                .logical_line += $line
            end
        elif $line[-1:] == "\\" then    # start continuation line
            .continuing = true |
            .logical_line = $line[:-1]
        else                            # line complete
            .logical_line = $line
        end
        ;
        if $line==null then  # EOF
            select(.continuing)
            | .logical_line # last line ended in \
        else
            select(.continuing|not)
            | .logical_line
        end
    )
;

# SMTP and HTTP continuation lines style
def read_headers:
    [range(3)] as [$init, $accum, $emit] |
    #
    foreach (inputs, null) as $line (
        { state: $init, logical_line: null, last_line: null }
        ;
        if $line==null then # EOF
            if   .state == $init  then . # do nothing
            elif .state == $accum then .state = $emit
            elif .state == $emit  then .logical_line = .last_line
            else                  error("unexpected state")
            end
        elif .state == $init then
            .state = $accum |
            .logical_line = $line
        elif .state == $accum then
            if $line[0:1]|ascii::isblank then
                .logical_line += " " + ($line|str::ltrim)
            else
                .state = $emit |
                .last_line = $line
            end
        elif .state == $emit then
            .state = $accum |
            .logical_line = .last_line |
            if $line[0:1]|ascii::isblank then
                .logical_line += " " + ($line|str::ltrim)
            else
                .state = $emit |
                .last_line = $line
            end
        else error("unexpected state")
        end
        ;
        select(.state == $emit)
        | .logical_line
    )
;

#
#read_sh
#read_sh_check
read_headers

# vim:ai:sw=4:ts=4:et:syntax=jq
