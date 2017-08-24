#!/usr/local/bin/jq -cnRrf

# Panintervalic dodecaphonic series
# https://en.wikipedia.org/wiki/Twelve-tone_technique

# Generates all panintervalic dodecaphonic series
def series($n):
    def _series($notes; $intervals):
        # . is the serie beeing constructed
        if $notes == []
        then .
        else
            $notes[] as $note | # foreach available note
            [$note - .[-1] | length] as $i | # compute interval to last note in serie
            select($intervals | contains($i) | not) | # retract if interval is in use
            .[length] = $note | # extend current serie with new note
            _series($notes-[$note]; $intervals+$i) # recurse with one note more added to the serie
        end
    ;
    #
    [range($n)] as $notes   | # set of available notes (not yet in use)
    [] as $intervals        | # set of intervals used (between notes in constructed serie)
    $notes[] as $note       | # for each note...
    [$note] as $serie       | # serie: a sequence of notes
    $serie | _series($notes - [$note]; $intervals)
;

def series: series(12);

series

# vim:ai:sw=4:ts=4:et:syntax=jq
