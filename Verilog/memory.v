module memory(
  input clk,
  input write_enable,
  input [15:0] write_data,
  input [15:0] address,
  output [15:0] read_data
);

reg [15:0] mem [2**16-1:0];

always @(posedge clk) begin
  if(write_enable) begin mem[address] = write_data;
    $writememb("output/data.txt", mem, 0, 2**16 - 1);
  end
end

assign read_data = mem[address];

endmodule
