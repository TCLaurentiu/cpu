module PC_register(input clk, reset, enable, increment, load, input [15:0] offset, in, output [15:0] out);
reg [15:0] PC_reg, PC_nxt;
always @(posedge clk) begin
    if(reset == 1'b1) begin
        PC_reg <= 0;
    end else if(enable) begin
        PC_reg <= PC_nxt;
    end
end

always @(*) begin
    if(load) begin
        PC_nxt = in;
    end else begin
        if(increment) begin
            PC_nxt = PC_reg + 1;
        end else begin
            PC_nxt = PC_reg + offset;
        end
    end
end

assign out = PC_reg;

endmodule
