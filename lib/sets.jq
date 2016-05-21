########################################################################
#  Objects as sets
########################################################################

# Set construction from strings and arrays
def cset(s):
    reduce (s/"")[] as $c ({}; . += {($c): true})
;

def set(a):
    reduce a[] as $x ({}; . += {($x|tostring): true})
;

# Equivalent to `with_entries` without constructing intermediate lists
def mapobj(f):
    reduce (keys_unsorted[] as $k
            | {key: $k, value: .[$k]}
            | f
            | {(.key): .value}
           ) as $x
    ({}; . + $x)
;

# Common sets operations
def intersection(s):
    mapobj(select(.key as $key | s | has($key)))
;

def difference(s):
    mapobj(select(.key as $key | s | has($key) | not))
;

def subset(s):
    . == intersection(s)
;

# vim:ai:sw=4:ts=4:et:syntax=python
