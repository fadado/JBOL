## Simplified grammar for path expressions

Very simplified grammar, not the actual grammar!

```yacc
PathExpr:
	('empty' | '.' | Route) ('|' PathExpr)*
Route:
	Step Step*
Step:
	'.' (name | string | Bracket) Bracket*
Bracket:
	Iterator | Slice | ASubscript | OSubscript
Iterator:
	'[' ']'
Slice:
	'[' index? ':' index? ']'
ASubscript:
	'[' index (',' index)* ']'
OSubscript:
	'[' string (',' string)* ']'
name:
	a JQ identifier: [A-Za-z_][A-Za-z_0-9]*
string:
	expression producing a JQ/JSON string
index:
	expression producing a JQ array index (JSON integer)
```

Array representation format:

* Array representation: `[number^string^object]`
* Number: array indices
* String: object keys
* Slice object: `{"start":number,"end":number}`

