Download the icarusverilog compiler from https://bleyer.org/icarus/
To compile the project, run iverilog cpu.v
To run the project, place your binary instructions in program.txt, and run vvp a.out
Other Verilog IDEs/Compilers can be used as well
You can open the cpu.vcd file to view waveforms
The input folder contains the input.txt file where the INP instruction reads from. 
16 bit binary values must be placed in this file with a newline between them. At most 2^16 values
The output folder contains the final values of the data memory, flag register and X Y registers.
It also contains the output.txt file to which the OUT instruction writes.