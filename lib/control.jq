########################################################################
# Control functions
########################################################################

# `iterate` returns an infinite stream of repeated applications of `f` to `.`:
#       x | iterate(f) = x, x|f, x|f|f...
def iterate(f):
    def R: ., (f | R);
    . | R
;

# 
# ⧮ ⧯ ⧰ ⧱ ⧲ ⧳
def stop:
    error("⧳")
;

def run(x):
    try x
    catch if . == "⧳" then empty else error end
;

#
# def throw, raise ???

# ???
# def when(filter; action): if filter?//null then action else . end;

# 
def when(cond; x):
    if cond then x else empty end
;

def unless(cond; x):
    if cond then empty else x end
;

# vim:ai:sw=4:ts=4:et:syntax=python
