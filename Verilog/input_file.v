module input_file(input clk, reset, read, output reg [15:0] data);

reg [15:0] address;

reg [15:0] memory [2**16 - 1:0];

initial begin
    $readmemb("input/input.txt", memory, 0, 2**16 - 1);
end

always @(posedge clk) begin
    if(reset) begin
        address = 0;
    end else begin
        if(read) begin
            data = memory[address];
            address = address + 1;
        end
    end
end

endmodule