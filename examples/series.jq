#!/usr/local/bin/jq -cnRrf

# Panintervalic dodecaphonic series
# https://en.wikipedia.org/wiki/Twelve-tone_technique

# Generates all panintervalic dodecaphonic series
def series($n):
    def _series($notes; $intervals):
        # . is the serie beeing constructed
        if $notes == []
        then .
        elif length==0 then
            $notes[] as $note # choose any note
            | [$note]|_series($notes-[$note]; [])
        else
            ($notes-.)[] as $note # choose notes not used
            | [$note-.[-1]|length] as $i
            | select($intervals|contains($i)|not) # interval is in use?
            | .[length]=$note
            | _series($notes-[$note]; $intervals+$i)
        end
    ;
    #
    [] as $serie |
    $serie|_series([range($n)]; null)
;

series(12)

# vim:ai:sw=4:ts=4:et:syntax=jq
