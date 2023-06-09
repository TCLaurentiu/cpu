module output_file(input clk, reset, write, hlt, input [15:0] data);

reg [15:0] address;

reg [15:0] memory [2**16 - 1:0];

always @(posedge clk) begin
    if(reset) begin
        address = 0;
    end else begin
        if(write) begin
            memory[address] = data;
            $writememb("output/output.txt", memory, 0, address);
            address = address + 1;
        end
    end
end

endmodule
