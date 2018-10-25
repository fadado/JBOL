## Simplified grammar for path expressions

Very simplified grammar, not the actual grammar!

```yacc
PathExpr:
	('empty' | '.' | Step+) ('|' PathExpr)*
Step:
	'.' (name | string | Bracket) Bracket*
Bracket:
	Iterator | Slice | Subscript 
Iterator:
	'[' ']'
Slice:
	'[' position? ':' position? ']'
Subscript:
	'[' Keys | Positions ']'
Keys:
	string (',' string)*
Positions:
	position (',' position)*

name:     a JQ identifier
string:   a JQ/JSON string
position: a JQ array index (JSON integer)
```

Array representation format:

* Array representation: `[number^string^object]`
* Number: array indices 
* String: object keys
* Slice object: `{"start":number,"end":number}`

