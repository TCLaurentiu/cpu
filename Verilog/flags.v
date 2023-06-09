module flags(
  input clk, reset,
  input enable,
  output reg [3:0] out,
  input [3:0] in
  );
  
  always @(posedge clk, negedge reset) begin
    if(reset) out <= 0;
    else if(enable) out <= in;
  end
endmodule