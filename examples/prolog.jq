#!/usr/local/bin/jq -cnRrf

include "fadado.github.io/prelude";
import "fadado.github.io/set" as set;

def query(generator):
    isdot(generator)
;

# Database

def biblical_family:
    {
        father: {
            terach: set::set(["abraham","nachor","haran"]),
            abraham: set::set(["isaac"]),
            haran: set::set(["lot","milcah","yiscah"])
        },
        mother: {
            sarah: set::set(["isaac"])
        },
        male: set::set(["terach","abraham","nachor","haran","isaac","lot"]),
        female: set::set(["sarah","milcah","yiscah"])
    }
;

# Facts

def father($x):
    (.father[$x] | keys_unsorted)[]
;

def father($x; $y):
    select(.father[$x][$y])
;

def mother($x):
    (.mother[$x] | keys_unsorted)[]
;

def mother($x; $y):
    select(.mother[$x][$y])
;

def male($x):
    select(.male[$x])
;

def female($x):
    select(.female[$x])
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
