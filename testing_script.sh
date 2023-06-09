#/bin/sh
python Asamblor/assembler.py test.asm
cat test.txt > Verilog/program.txt
cat input.txt > Verilog/input/input.txt
cd Verilog
iverilog cpu.v
vvp a.out
echo "Registers:"
cat output/registers.txt
echo "Output:"
cat output/output.txt
echo "Flags:"
cat output/flags.txt
read wai