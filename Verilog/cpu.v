`timescale 1ns/1ns
`include "control_unit.v"
`include "alu.v"
`include "sign_extend_unit.v"
`include "flags.v"
`include "register.v"
`include "memory.v"
`include "memoryi.v"
`include "PC.v"
`include "input_file.v"
`include "output_file.v"

module cpu_tb();

reg clk, reset, start;
wire hlt;

initial begin
    $dumpfile("cpu.vcd");
    $dumpvars(0, cpu_tb);
    clk = 0;
    reset = 1;
    clk = 1;
    #10 reset = 0;
    start = 1;
end

always begin
    #10 clk = ~clk;
    if(hlt) $finish;
end

cpu cp(.clk(clk), .reset(reset), .start(start), .hlt(hlt));

endmodule

    module cpu(input clk, input reset, input start, output hlt);
wire [15:0] instr;

reg [15:0] registers [1:0];
reg flags_memory [3:0];

wire [15:0] out_PC;
wire loadPC;

wire store_registerX, store_registerY;
reg [15:0] regX_in, regY_in, regA_in;
wire [15:0] regI_in;
wire [15:0] regX_out, regY_out, regA_out, regI_out;

wire acc_store, imm_store;
wire [15:0] acc_value;

wire alu_done;
wire [5:0] alu_operation;
wire pc_increment;
wire alu_start;
wire [1:0] alu_op1_select, alu_op2_select;
wire [8:0] regI_short;
wire branch_enable;
wire [9:0] offset_short;
wire [15:0] offset_long;

wire [3:0] flags_in;
wire [3:0] flags_out;

wire flags_write_enable;

wire [15:0] mem_data_read;

reg [15:0] in_PC_reg, in_PC_nxt;

wire input_read, store_from_input;
wire [15:0] input_data;

wire output_write;
reg [15:0] output_data;

wire save_output;
wire [1:0] output_reg_select;

wire [1:0] memory_address_select;
wire memory_write;
wire [1:0] memory_data_write_select;

reg [15:0] memory_data_write;
reg [15:0] memory_address;

wire mem_to_register;

wire enable_sp;
reg [15:0] SP_in;
wire [15:0] SP_out;

wire stack_push_pc;
wire stack_pop, load_pc_from_st;

input_file ip(.clk(clk), .reset(reset), .read(input_read), .data(input_data));
output_file of(.clk(clk), .reset(reset), .write(output_write), .data(output_data), .hlt(hlt));

PC_register PC(.clk(clk), .reset(reset), .increment(~branch_enable), .load(load_pc_from_st), .in(mem_data_read), .offset(offset_long), .enable(loadPC), .out(out_PC));
register REGISTER_X(.clk(clk), .reset(reset), .enable(store_registerX), .in(regX_in), .out(regX_out));
register REGISTER_Y(.clk(clk), .reset(reset), .enable(store_registerY), .in(regY_in), .out(regY_out));
register REGISTER_A(.clk(clk), .reset(reset), .enable(acc_store), .in(acc_value), .out(regA_out));
register REGISTER_I(.clk(clk), .reset(reset), .enable(1'b1), .in(regI_in), .out(regI_out));

register #(.INIT_VALUE(16'hFFFF)) SP(.clk(clk), .reset(reset), .enable(enable_sp), .in(SP_in), .out(SP_out));

memoryi INSTR(.address(out_PC), .read_data(instr));

control_unit CU(.clk(clk), .reset(reset), .start(start), .alu_done(alu_done), .input_read(input_read),
                .flags(flags_out), .instr(instr), .alu_operation(alu_operation),
                .alu_start(alu_start), .acc_store(acc_store), .offset_short(offset_short),
                .alu_op1_select(alu_op1_select), .alu_op2_select(alu_op2_select),
                .store_registerX(store_registerX), .store_registerY(store_registerY),
                .regI_short(regI_short), .branch_enable(branch_enable), .loadPC(loadPC), .hlt(hlt), .flags_write_enable(flags_write_enable),
                .store_from_input(store_from_input), .output_write(output_write), .output_reg_select(output_reg_select),
                .memory_write(memory_write), .memory_address_select(memory_address_select),
                .memory_write_select(memory_data_write_select), .mem_to_register(mem_to_register),
                .stack_push(stack_push), .stack_reg_select(stack_reg_select),
                .enable_sp(enable_sp), .stack_pop(stack_pop), .stack_push_pc(stack_push_pc),
                .load_pc_from_st(load_pc_from_st)
               );

alu ALU(.clk(clk), .reset(reset), .alu_start(alu_start), .op1(operand1), .op2(operand2), .alu_control(alu_operation), .out(acc_value), .flags(flags_in), .alu_done(alu_done));
flags FLAG_REGISTER(.enable(flags_write_enable), .in(flags_in), .out(flags_out), .clk(clk), .reset(reset));
sign_extend_unit #(.SHORT_SIZE(9), .LONG_SIZE(16)) EXTEND_9_16(.short_operand(regI_short), .long_operand(regI_in));
sign_extend_unit #(.SHORT_SIZE(10), .LONG_SIZE(16)) EXTEND_10_16(.short_operand(offset_short), .long_operand(offset_long));

memory DATA(.clk(clk), .write_enable(memory_write), .write_data(memory_data_write), .address(memory_address), .read_data(mem_data_read));

reg [15:0] operand1, operand2;
always@(*) begin

    if(stack_push) begin
        memory_address = SP_out;
        if(stack_push_pc) begin
            memory_data_write = out_PC + 1;
        end else begin
            case(stack_reg_select)
                2'b00: memory_data_write = regX_out;
                2'b01: memory_data_write = regY_out;
                2'b10: memory_data_write = regA_out;
                2'b11: memory_data_write = regI_out;
            endcase
        end
        SP_in = SP_out - 1;
    end

    if(stack_pop) begin
        memory_address = SP_out + 1; // to do
        regX_in = mem_data_read;
        regY_in = mem_data_read;
        SP_in = SP_out + 1; // to do
    end

    if(!stack_push && !stack_pop) begin // to do 
        case(memory_address_select)
            2'b00: memory_address = regX_out;
            2'b01: memory_address = regY_out;
            2'b10: memory_address = regA_out;
            2'b11: memory_address = regI_out;
        endcase

        case(memory_data_write_select)
            2'b00: memory_data_write = regX_out;
            2'b01: memory_data_write = regY_out;
            2'b10: memory_data_write = regA_out;
            2'b11: memory_data_write = regI_out;
        endcase
    end

    case(alu_op1_select)
        2'b00: operand1 = regX_out;
        2'b01: operand1 = regY_out;
        2'b10: operand1 = regA_out;
        2'b11: operand1 = regI_out;
    endcase
    case(alu_op2_select)
        2'b00: operand2 = regX_out;
        2'b01: operand2 = regY_out;
        2'b10: operand2 = regA_out;
        2'b11: operand2 = regI_out;
    endcase
    case(output_reg_select) // to do
        2'b00: output_data = regX_out;
        2'b01: output_data = regY_out;
        2'b10: output_data = regA_out;
        2'b11: output_data = regI_out;
    endcase
    if(!stack_pop) begin
        if(mem_to_register) begin
            regX_in = mem_data_read;
        end else begin
            regX_in = store_from_input ? input_data : regA_out;
        end
        if(mem_to_register) begin
            regY_in = mem_data_read;
        end else begin
            regY_in = store_from_input ? input_data : regA_out;
        end
    end
end


always @(*) begin
    if(hlt) begin
        registers[0] <= regX_out;
        registers[1] <= regY_out;
        flags_memory[3] <= flags_out[0];
        flags_memory[2] <= flags_out[1];
        flags_memory[1] <= flags_out[2];
        flags_memory[0] <= flags_out[3];
        $writememb("output/flags.txt", flags_memory, 0, 3);
        $writememb("output/registers.txt", registers, 0, 1);
    end
end

endmodule
