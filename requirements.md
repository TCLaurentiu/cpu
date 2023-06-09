## Registers
16 bit Accumulator

16-bit general purpose registers X and Y

Flag Register:Zero, Negative, Carry, Overflow

16-bit stack pointer

16-bit Program Counter

## Instructions:
6-bit opcode

1-bit register

9-bit immediate

### Branch Instructions

| Instruction | ASM format | Binary format | Explanation |
| - | - | - | - |
| BRZ | BRZ {label_name} | 000000 {10 bit unsigned offset} | Jumps to label_name if Z flag is set |
| | BRZ #{offset} | 000000 {10 bit unsigned offset} | Jumps to PC + offset if Z flag is set |
| BRN | BRN {label_name} | 000001 {10 bit unsigned offset} | Jumps to label_name if N flag is set |
| | BRN #{offset} | 000001 {10 bit unsigned offset} | Jumps to PC + offset if N flag is set |
| BRC | BRC {label_name} | 000010 {10 bit unsigned offset} | Jumps to label_name if C flag is set |
| | BRC #{offset} | 000010 {10 bit unsigned offset} | Jumps to PC + offset if C flag is set |
| BRO | BRO {label_name} | 000011 {10 bit unsigned offset} | Jumps to label_name if O flag is set |
| | BRO #{offset} | 000011 {10 bit unsigned offset} | Jumps to PC + offset if O flag is set |
| BRA | BRA {label_name} | 000100 {10 bit unsigned offset} | Jumps to label_name | 
| | BRA #{offset} | 000100 {10 bit unsigned offset} | Jumps to PC + offset |
| JMP | JMP {label_name} | 000101 {10 bit unsigned offset} | Jumps to label_name and pushes PC to stack |
| | JMP #{offset} | 000101 {10 bit unsigned offset} | Jumps to PC + offset and pushes PC to stack |
| RET | RET | 000110 0000000000 | Pops from stack into PC |

## Memory / stack
| Instruction | ASM format | Binary format | Explanation |
| - | - | - | - |
| PSH | PSH R1 | 000111 BR 000000000 | Pushes register X or register Y on the stack |
| POP | POP R1 | 001000 BR 000000000 | Pops from stack into registers X or Y |
| STR | STR R1 R2 | 001001 BR1 BR2 00000000 | Saves R1 in memory at position specified by R2 |
| | STR R1 #immediate | 101001 BR {unsigned of immediate} | Saves R1 in memory at position given by immediate |
| LDR | LDR R1 R2 | 001010 BR1 BR2 00000000 | Loads in R1 from memory at address R2 |
| | LDR R1 #immediate | 101010 BR {unsigned immediate} | Loads in R1 from memory at address #immediate |

## ALU
| Instruction | ASM format | Binary format | Explanation |
| - | - | - | - |
| ADD | ADD R1 R2 | 001011 BR1 BR2 | R1 = R1 + R2 |
| | ADD R1 #immediate | 101011 BR1 {signed immediate} | R1 = R1 + immediate |
| SUB | SUB R1 R2 | 001100 BR1 BR2 | R1 = R1 - R2 |
| | SUB R1 #immediate | 101100 BR1 {signed immediate} | R1 = R1 - immediate |
| LSR | LSR R1 R2 | 001101 BR1 BR2 | Shift R1 to the right R2 times, inserting a 0 to the left |
| | LSR R1 #immediate | 101101 BR1 {signed immediate} | Shift R1 to the right #immediate times, inserting a 0 to the left |
| LSL | LSL R1 R2 | 001110 BR1 BR2 | Shift R1 to the left R2 times, inserting a 0 to the right |
| | LSL R1 R2 | 101110 BR1 {signed immediate} | Shift R1 to the left #immediate times, inserting a 0 to the right |
| RSR | RSR R1 R2 | 001111 BR1 BR2 | Rotate R1 to the right R2 times, inserting the left most bit to the right |
| | RSR R1 #immediate | 101111 BR1 {signed immediate} | Rotate R1 to the right #immediate times, inserting the left most bit to the right |
| RSL | RSL R1 R2 | 010000 BR1 BR2 | Rotate R1 to the left R2 times, inserting the right most bit to the left |
| | RSL R1 #immediate | 110000 BR1 {signed immediate} | Rotate R1 to the left #immediate times, inserting the right most bit to the left |
| MOV | MOV R1 R2 | 010001 BR1 BR2 | R1 <= R2 |
| | MOV R1 #immediate | 110001 BR1 {signed immediate} | R1 <= #immediate |
| MUL | MUL R1 R2 | 010010 BR1 BR2 | R1 = R1 * R2 |
| | MUL R1 #immediate | 110010 BR1 {signed immediate} | R1 <= R1 * #immediate |
| DIV | DIV R1 R2 | 010011 BR1 BR2 | R1 <= int(R1 / R2) |
| | DIV R1 #immediate | 110011 BR1 #immediate | R1 <= int(R1 / #immediate) |
| MOD | MOD R1 R2 | 010100 BR1 BR2 | R1 <= R1 mod R2 |
| | MOD R1 #immediate | 110100 BR1 {signed immediate} | R1 <= R1 mod #immediate |
| AND | AND R1 R2 | 010101 BR1 BR2 | bitwise AND: R1 = R1 and R2 |
| | AND R1 #immediate | 110101 BR1 {signed immediate} | bitwise AND: R1 = R1 and #immediate |
| OR | OR R1 R2 | 010110 BR1 BR2 | bitwise OR: R1 = R1 or R2 |
| | OR R1 #immediate | 110110 BR1 {signed immediate} | bitwise OR: R1 = R1 or #immediate |
| XOR | XOR R1 R2 | 010111 BR1 BR2 | bitwise OR: R1 = R1 xor R2 |
| | XOR R1 #immediate | 010111 BR1 {signed immediate} | bitwise OR: R1 = R1 xor #immediate |
| NOT | NOT R1 | 011000 BR1 | bitwise negation: R1 = ~R1 |
| CMP | CMP R1 R2 | 011001 BR1 BR2 | computes R1 - R2 and sets the Z and N flags accordingly |
| | CMP R1 #immediate | 11001 BR1 #immediate | computes R1 - #immediate and sets the Z and N flags accordingly |
| TST | TST R1 R2 | 011010 BR1 BR2 | bitwise AND between R1 and R2, without modifying the 2 registers, setting flags accordingly |
| | TST R1 #immediate | 111010 BR1 {signed immediate} | bitwise AND between R1 and #immediate, without modifying R1, setting flags accordingly |
| INC | INC R1 | 011011 BR1 000000000 | Increments R1 |
| DEC | DEC R1 | 011100 BR1 000000000 | Decrements R1 |

## Others
| Instruction | ASM format | Binary format | Explanation |
| - | - | - | - |
| HLT | HLT | 011101 0000000000 | Stops execution |
| INP | INP R | 011110 BR 000000000 | Reads input from input file into R |
| OUT | OUT R | 011111 BR 000000000 | Writes R to output file |