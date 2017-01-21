#!/usr/local/bin/jq -cnrf

import "fadado.github.io/generator/choice" as choice;

########################################################################
## subset

"subset/0\tP(S)\tS=>S\t2^n\t[1,2,3]|subset",
[([1,2,3]|choice::subset)],
#"subset_u/0\tP(S)\tS=>S\t2^n\t[1,2,3]|subset_u",
#[([1,2,3]|choice::subset_u)],
#"subset1_u/0\tCn,n-1\tS=>S\t(n|n-1)\t[1,2,3]|subset1_u",
#[([1,2,3]|choice::subset1_u)],
"subset/1\tCn,k\tS=>S\t(n|k)\tn!/(n-k)!k!\t[1,2,3]|subset(2)",
[([1,2,3]|choice::subset(2))],

########################################################################
# mulset

"",
"mulset/0\tCRn,0..8\tS=>M\t∞\t[1,2,3]|mulset",
[limit(20; [1,2,3]|choice::mulset)],
"mulset/1\tCRn,k\tS=>M\t(n+k-1|k)\t[1,2,3]|mulset(2)",
[([1,2,3]|choice::mulset(2))],

########################################################################
## subseq

"",
"subseq/0\tPn,0..n\tS=>T\tn!/(n-k)!\t[1,2,3]|subseq",
[([1,2,3]|choice::subseq)],
"subseq/1\tPn,k\tS=>T\tn!/(n-k)!\t[1,2,3]|subseq(2)",
[([1,2,3]|choice::subseq(2))],
#"permutation/0\tPn\tS=>T\tn!\t[1,2,3]|permutation",
#[([1,2,3]|choice::permutation)],

########################################################################
## mulseq

"",
"mulseq/0 \tS*\tS=>T\t∞\t[1,2,3]|mulseq",
[limit(20; [1,2,3]|choice::mulseq)],
"mulseq/1 \tPRn,k\tS=>T\tn^k\t[1,2,3]|mulseq(2)",
[([1,2,3]|choice::mulseq(2))],
#"product/0\tAxB\tS=>T\tn·m\t[[1,2,3],[1,2,3]]|product",
#[([[1,2,3],[1,2,3]]|choice::product)],

########################################################################
## Constricted permutations

"",
"derangement/0\t--\tT=>T\t!n\t[1,2,3]|derangement",
[([1,2,3]|choice::derangement)],

"",
"circle/0    \t--\tT=>T\t(n-1)!\t[1,2,3]|circle",
[([1,2,3]|choice::circle)],

"",
"arrangement/0\tn!/a!b!...\tM=>M\t(n-1)!\t[1,1,2]|arrangement",
[([1,1,2]|choice::arrangement)],

"",
"disposition/0\t--  \tM=>M\t(n-1)!\t[1,1,2]|disposition",
[([1,1,2]|choice::disposition)],

""
# vim:ai:sw=4:ts=4:et:syntax=jq
