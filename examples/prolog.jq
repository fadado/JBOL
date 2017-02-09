#!/usr/local/bin/jq -cnRrf

def set($elements):
    reduce $elements[] as $element
        ({}; . += {($element|tostring):true})
;

def query(generator):
    (label $exit | generator | 1 , break $exit)//0
    | .==1  # computation generates results
;

# Database

def biblical_family:
    {
        father: {
            terach: set(["abraham","nachor","haran"]),
            abraham: set(["isaac"]),
            haran: set(["lot","milcah","yiscah"])
        },
        mother: {
            sarah: set(["isaac"])
        },
        male: set(["terach","abraham","nachor","haran","isaac","lot"]),
        female: set(["sarah","milcah","yiscah"])
    }
;

# Facts

def father($x):
    (.father[$x] | keys_unsorted)[]
;

def father($x; $y):
    if .father[$x][$y] then . else empty end
;

def mother($x):
    (.mother[$x] | keys_unsorted)[]
;

def mother($x; $y):
    if .mother[$x][$y] then . else empty end
;

def male($x):
    if .male[$x] then . else empty end
;

def female($x):
    if .female[$x] then . else empty end
;

# Rules

def parent($x):
    father($x) , mother($x)
;

def parent($x; $y):
    father($x; $y) , mother($x; $y)
;

def son($x; $y):
    parent($y; $x) | male($x)
;

def daughter($x; $y):
    parent($y; $x) | female($x)
;

def grandfather($x; $z):
    father($x) as $y | father($y; $z)
;

def grandmother($x; $z):
    mother($x) as $y | mother($y; $z)
;

def grandparent($x; $y):
    parent($x) as $z | parent($z; $y)
;

# A query

biblical_family |
query(grandparent("terach"; "isaac"))

# vim:ai:sw=4:ts=4:et:syntax=jq
