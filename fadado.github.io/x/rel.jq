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
import "fadado.github.io/stream" as stream;

# very very experimental !!!!!!!!!!!!!!!!!!!!!!!!!

def concat(R;S): #:: a|(a->*b;a->*b) => *b
    R , S
;

def compose(R;S): #:: a|(a->*b;b->*c) => *c
    R | S
;

def union(R; S): #:: a|(a->*b;a->*b) => *b
    R , (S | reject(stream::member(.; R)))
;

def intersection(R; S): #:: a|(a->*b;a->*b) => *b
    R | select(stream::member(.; S))
;

def difference(R; S): #:: a|(a->*b;a->*b) => *b
    R | reject(stream::member(.; S))
;

def symmetric(R; S): #:: a|(a->*b;a->*b) => *b
    (R | reject(stream::member(.; S)))
    , (S | reject(stream::member(.; R)))
;

# vim:ai:sw=4:ts=4:et:syntax=jq
