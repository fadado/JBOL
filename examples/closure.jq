#!/usr/local/bin/jq -cnRrf

# 1 FIF-
def recurse(f):   def r: . , (f | r); r;

# 2 FIFI
def iterate(f):   def r: .[] , (map(f) | select(length>0) | r); [.]|r;

# 3 -I-I
def reiterate(f): def r: . , (r | f); r;

#1: Louis | William | Charles | Philip | Elizabeth II | George VI | Elizabeth | Diana | Chaterine
#2: Louis | William | Chaterine | Charles | Diana | Philip | Elizabeth II | George VI | Elizabeth
#3: Louis | William | Chaterine | Charles | Diana | Philip | Elizabeth II | George VI | Elizabeth...

def family_tree:
{
    "Queen Elizabeth II": ["King George VI", "Queen Elizabeth"],
    "Princess Margaret":  ["King George VI", "Queen Elizabeth"],
    "Charles, Prince of Wales":  ["Prince Philip", "Queen Elizabeth II"],
    "Anne, Princess Royal":  ["Prince Philip", "Queen Elizabeth II"],
    "Prince Andrew":  ["Prince Philip", "Queen Elizabeth II"],
    "Prince Edward":  ["Prince Philip", "Queen Elizabeth II"],
    "Prince William":  ["Charles, Prince of Wales", "Diana"],
    "Prince Harry":  ["Charles, Prince of Wales", "Diana"],
    "Prince George":  ["Prince William", "Chaterine"],
    "Princess Charlotte":  ["Prince William", "Chaterine"],
    "Prince Louis":  ["Prince William", "Chaterine"]
};

def parents:
    . as $member
    | family_tree as $F
    | $F[$member][]?
;

def ancestors1($member): $member | recurse(parents);
def ancestors2($member): $member | iterate(parents);
def ancestors3($member): $member | reiterate(parents);

#
ancestors1("Prince Louis"),
"="*72,
ancestors2("Prince Louis"),
"="*72,
ancestors3("Prince Louis")

# vim:ai:sw=4:ts=4:et:syntax=jq
