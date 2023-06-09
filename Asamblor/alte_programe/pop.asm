MOV X, #12
MOV Y, X
loop: CMP X, #0
BRZ end
PSH X
SUB X, #1
BRA loop
end: CMP Y, #1
BRZ fin
POP X
OUT X
SUB Y, #1
BRA end
fin: HLT