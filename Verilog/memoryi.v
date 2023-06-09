module memoryi(
  input [15:0] address,
  output [15:0] read_data
);

reg [15:0] mem [2**16-1:0];

initial begin
  $readmemb("program.txt", mem, 0, 2**16 - 1);
end

assign read_data = mem[address];

endmodule
