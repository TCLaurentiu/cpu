module alu(
           input clk, reset,
           input alu_start,
           input [15:0] op1, op2,
           input [5:0] alu_control,
           output reg [15:0] out,
           output reg [3:0] flags,
           output reg alu_done
       );

localparam ADDR = 6'b001011;
localparam ADDI = 6'b101011;
localparam SUBR = 6'b001100;
localparam SUBI = 6'b101100;
localparam LSRR = 6'b001101;
localparam LSRI = 6'b101101;
localparam LSLR = 6'b001110;
localparam LSLI = 6'b101110;
localparam RSRR = 6'b001111;
localparam RSRI = 6'b101111;
localparam RSLR = 6'b010000;
localparam RSLI = 6'b110000;
localparam MOVR = 6'b010001;
localparam MOVI = 6'b110001;
localparam MULR = 6'b010010;
localparam MULI = 6'b110010;
localparam DIVR = 6'b010011;
localparam DIVI = 6'b110011;
localparam MODR = 6'b010100;
localparam MODI = 6'b110100;
localparam ANDR = 6'b010101;
localparam ANDI = 6'b110101;
localparam ORRR = 6'b010110;
localparam ORRI = 6'b110110;
localparam XORR = 6'b010111;
localparam XORI = 6'b110111;
localparam NOT  = 6'b011000;
localparam CMPR = 6'b011001;
localparam CMPI = 6'b111001;
localparam TSTR = 6'b011010;
localparam TSTI = 6'b111010;
localparam INC  = 6'b011011;
localparam DEC  = 6'b011100;
localparam RTT = 6'b111100;
localparam LOG = 6'b111011;

localparam ZF = 3;
localparam NF = 2;
localparam CF = 1;
localparam VF = 0;


integer i;

// for 3rd root
reg [20:0] d;
reg [11:0] f;
reg [20:0] r;
reg [5:0] a;
reg b;

always @(*) begin
    alu_done = 0;
    if(alu_start == 1'b1) begin
        flags = 0;

        case(alu_control)

            RTT: begin
                a = 0;
                b = 0;
                d = {1'b0,1'b0,op1[15]};
                out = 0;

                for(i=1; i<=6; i = i + 1) begin
                    b = 1;
                    f = 3 * a * b * ( a + b ) + b;
                    if(f<=d)
                        r = d-f;
                    else begin
                        r = d;
                        b = 0;
                    end
                    out = {out[14:0],b};
                    a = 2*(a + b);
                    d = {r[17:0], op1[17 - 3 * i -: 3]};
                end
            end

            LOG: begin
                if(op1 == 0 || op1[15] == 1'b1) begin
                    $error("Logarithm of number <= 0");
                    $finish;
                end else begin
                    out = 0;
                    for(i = 0; 2**i <= op1; i = i + 1)
                        out = i;
                end
            end

            ADDI, ADDR:begin
                {flags[CF], out} = op1 + op2;
                if (op1[15] == op2[15] && out[15] != op1[15]) begin
                    flags[VF] = 1;
                end
            end

            SUBI, SUBR, CMPI, CMPR: begin
                out = op1 - op2;

                if((op1 > 0 && op2 > 0 && out < op1 && out < op2) || (op1 < 0 && op2 < 0 && out < op1 && out < op2)) begin
                    flags[CF] = 1;
                end

                if ((op1[15] == 0 && op2[15] == 1 && out[15] == 1) || (op1[15] == 1 && op2[15] == 0 && out[15] == 0)) begin
                    flags[VF] = 1;
                end
            end

            MODI, MODR: begin
                out = op1 % op2;
            end

            DIVI, DIVR: begin
                out = op1 / op2;
            end

            MULI, MULR: begin
                out = 0;
                for(i=0;i<op2;i = i + 1 ) begin
                    {flags[CF], out} = out + op1;
                end
                if(op1 == 1 || op2 == 1) begin
                    flags[VF] = 0;
                end else begin
                    if(op1 != out/op2) begin
                        flags[VF] = 1;
                    end
                end
            end

            ANDI, ANDR: begin
                out = op1 & op2;
            end

            ORRI, ORRR: begin
                out = op1 | op2;
            end

            XORI, XORR: begin
                out = op1 ^ op2;
            end

            NOT: begin
                out = ~op1;
            end

            DEC: begin
                out = op1 - 1;

                if(op1 > 0 && out < op1 && out < 1) begin
                    flags[CF] = 1;
                end

                if ((op1[15] == 0 && op2[15] == 1 && out[15] == 1) || (op1[15] == 1 && op2[15] == 0 && out[15] == 0)) begin
                    flags[VF] = 1;
                end
            end

            INC: begin
                {flags[CF], out} = op1 + 1;
                if (op1[15] == op2[15] && out[15] != op1[15]) begin
                    flags[VF] = 1;
                end
            end

            LSLI, LSLR: begin // logical shift left, inserts 0 to the right
                out = op1;
                for (i = 0; i < op2; i = i + 1) begin
                    flags[CF] = out[15];
                    out = {out[14:0], 1'b0};
                end
            end

            LSRI, LSRR: begin
                out = op1;
                for(i = 0;i<op2;i = i +1) begin
                    flags[CF] = out[0];
                    out = {1'b0, out[15:1]};
                end
            end

            RSLI, RSLR: begin
                out = op1;
                for (i = 0;i < op2;i = i + 1) begin
                    flags[CF] = out[15];
                    out = {out[14:0], out[15]};
                end
            end

            RSRI, RSRR: begin
                out = op1;
                for (i = 0;i<op2;i = i + 1) begin
                    flags[CF] = out[15];
                    out = {out[0], out[15:1]};
                end
                flags[CF] = out[0];
            end

            MOVI, MOVR: begin
                out = op2;
            end

            TSTI, TSTR: begin
                out = op1 & op2;
            end

        endcase

        flags[ZF] = (out == 0);
        flags[NF] = (out[15] == 1);
        alu_done = 1;
    end
end
endmodule
