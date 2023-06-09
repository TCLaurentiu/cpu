INP X
PSH X
MOV Y, #50
STR X, Y
read:POP X
CMP X, #0
BRZ sort
DEC X
PSH X
INP X
INC Y
STR X, Y
BRA read

sort:LDR X, #50
PSH X
MOV X, #50
OUTER_LOOP:PSH X
MOV Y, X
ADD Y, #1
PSH Y
INNER_LOOP:LDR X, X
LDR Y, Y
CMP Y, X
BRN swap
BRA after_swap
swap:

after_swap:POP Y
