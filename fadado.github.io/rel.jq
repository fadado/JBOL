module {
    name: "rel",
    description: "Relational programming",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

include "fadado.github.io/prelude";
import "fadado.github.io/generator/stream" as stream;

def member($e; s): #:: a|(b;a->*b) => boolean
    stream::any(s; . == $e)
;

def product(R;S): #:: a|(a->*b;b->*c) => *c
    R | S
;

def union(R; S): #:: a|(a->*b;a->*b) => *b
    R , (S | reject(member(.; R)))
;

def intersection(R; S): #:: a|(a->*b;a->*b) => *b
    R | select(member(.; S))
;

def difference(R; S): #:: a|(a->*b;a->*b) => *b
    R | reject(member(.; S))
;

def symmetric(R; S): #:: a|(a->*b;a->*b) => *b
    (R | reject(member(.; S)))
    , (S | reject(member(.; R)))
;

# vim:ai:sw=4:ts=4:et:syntax=jq
