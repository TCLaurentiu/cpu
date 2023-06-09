module register #(parameter INIT_VALUE = 0) 
                (input clk, reset, enable, input [15:0] in, output reg [15:0] out);
always @(posedge clk) begin
    if(reset == 1'b1) begin
        out <= INIT_VALUE;
    end else if(enable) begin
        out <= in;
    end
end
endmodule
