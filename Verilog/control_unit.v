module control_unit(
           input clk, reset, start, // start triggers code execution
           input alu_done, // 1 when ALU is done executing its operation
           input [3:0] flags, // flags register
           input [15:0] instr, // instruction register
           output [5:0] alu_operation, // opcode of the instruction that ALU will execute
           output alu_start, // triggers ALU to compute stuff
           output [1:0] alu_op1_select, // what register goes into the first operand for ALU
           output [1:0] alu_op2_select, // what register goes into the second operand for ALU
           output store_registerX, store_registerY, // 1 if the register is updated
           output branch_enable, // 1 when branching
           output loadPC, // 1 if the PC is updated
           output [8:0] regI_short,
           output acc_store,
           output reg hlt,
           output flags_write_enable,
           output [9:0] offset_short,
           output input_read,
           output store_from_input,
           output output_write,
           output [1:0] output_reg_select,
           output memory_write,
           output [1:0] memory_address_select,
           output [1:0] memory_write_select,
           output mem_to_register,
           output stack_reg_select,
           output stack_push,
           output enable_sp,
           output stack_pop,
           output stack_push_pc,
           output stack_pop_pc,
           output load_pc_from_st
       );
reg [7:0] state_reg, state_nxt;
reg [3:0] flags_reg, flags_nxt;
reg [15:0] instr_reg, instr_nxt;
reg [5:0] alu_operation_reg, alu_operation_nxt;
reg [5:0] opcode_reg, opcode_nxt;
reg [1:0] alu_op1_select_reg, alu_op1_select_nxt;
reg [1:0] alu_op2_select_reg, alu_op2_select_nxt;
reg store_registerX_reg, store_registerX_nxt;
reg store_registerY_reg, store_registerY_nxt;
reg branch_enable_reg, branch_enable_nxt;
reg loadPC_reg, loadPC_nxt;
reg alu_start_reg, alu_start_nxt;
reg [8:0] regI_short_reg, regI_short_nxt;
reg acc_store_reg, acc_store_nxt;
reg flags_write_enable_reg, flags_write_enable_nxt;
reg [9:0] offset_short_reg, offset_short_nxt;
reg input_read_reg, input_read_nxt;
reg store_from_input_reg, store_from_input_nxt;
reg output_write_reg, output_write_nxt;
reg [1:0] output_reg_select_reg, output_reg_select_nxt;
reg memory_write_reg, memory_write_nxt;
reg [1:0] memory_address_select_reg, memory_address_select_nxt;
reg [1:0] memory_write_select_reg, memory_write_select_nxt;
reg mem_to_register_reg, mem_to_register_nxt;
reg [1:0] stack_reg_select_reg, stack_reg_select_nxt;
reg stack_push_reg, stack_push_nxt;
reg enable_sp_reg, enable_sp_nxt;
reg stack_pop_reg, stack_pop_nxt;
reg stack_push_pc_reg, stack_push_pc_nxt;
reg stack_pop_pc_reg, stack_pop_pc_nxt;
reg load_pc_from_st_reg, load_pc_from_st_nxt;

localparam IDLE = 0;
localparam FETCH = 1;
localparam DECODE = 2;
localparam ALU = 3;
localparam WB = 4;
localparam STALL = 5;
localparam INPUT_STALL = 6;
localparam OUTPUT_STALL = 7;
localparam STORE_STALL = 8;
localparam LOAD_STALL = 9;
localparam PUSH_STALL = 10;
localparam POP_STALL = 11;
localparam POP_UPDATE_SP = 12;
localparam JMP_STALL = 13;
localparam RET_STALL = 14;

always @(posedge clk) begin
    if(reset == 1'b1) begin
        state_reg <= IDLE;
        instr_reg <= 0;
        opcode_reg <= 0;
        branch_enable_reg <= 0;
        flags_reg <= 0;
        alu_operation_reg <= 0;
        alu_op1_select_reg <= 0;
        alu_op2_select_reg <= 0;
        store_registerX_reg <= 0;
        store_registerY_reg <= 0;
        loadPC_reg <= 0;
        alu_start_reg <= 0;
        regI_short_reg <= 0;
        acc_store_reg <= 0;
        flags_write_enable_reg <= 0;
        offset_short_reg <= 0;
        input_read_reg <= 0;
        store_from_input_reg <= 0;
        output_write_reg <= 0;
        output_reg_select_reg <= 0;
        memory_write_reg <= 0;
        memory_address_select_reg <= 0;
        memory_write_select_reg <= 0;
        mem_to_register_reg <= 0;
        stack_reg_select_reg <= 0;
        stack_push_reg <= 0;
        enable_sp_reg <= 0;
        stack_pop_reg <= 0;
        stack_push_pc_reg <= 0;
        stack_pop_pc_reg <= 0;
        load_pc_from_st_reg <= 0;
    end else begin
        state_reg <= state_nxt;
        instr_reg <= instr_nxt;
        opcode_reg <= opcode_nxt;
        branch_enable_reg <= branch_enable_nxt;
        flags_reg <= flags_nxt;
        alu_operation_reg <= alu_operation_nxt;
        alu_op1_select_reg <= alu_op1_select_nxt;
        alu_op2_select_reg <= alu_op2_select_nxt;
        store_registerX_reg <= store_registerX_nxt;
        store_registerY_reg <= store_registerY_nxt;
        loadPC_reg <= loadPC_nxt;
        alu_start_reg <= alu_start_nxt;
        regI_short_reg <= regI_short_nxt;
        acc_store_reg <= acc_store_nxt;
        flags_write_enable_reg <= flags_write_enable_nxt;
        offset_short_reg <= offset_short_nxt;
        input_read_reg <= input_read_nxt;
        store_from_input_reg <= store_from_input_nxt;
        output_write_reg <= output_write_nxt;
        output_reg_select_reg <= output_reg_select_nxt;
        memory_write_reg <= memory_write_nxt;
        memory_address_select_reg <= memory_address_select_nxt;
        memory_write_select_reg <= memory_write_select_nxt;
        mem_to_register_reg <= mem_to_register_nxt;
        stack_reg_select_reg <= stack_reg_select_nxt;
        stack_push_reg <= stack_push_nxt;
        enable_sp_reg <= enable_sp_nxt;
        stack_pop_reg <= stack_pop_nxt;
        stack_push_pc_reg <= stack_push_pc_nxt;
        stack_pop_pc_reg <= stack_pop_pc_nxt;
        load_pc_from_st_reg <= load_pc_from_st_nxt;
    end
end

localparam ZF = 3;
localparam NF = 2;
localparam CF = 1;
localparam VF = 0;

localparam SEL_X = 0;
localparam SEL_Y = 1;
localparam SEL_A = 2;
localparam SEL_I = 3;

localparam BRZ = 6'b000000;
localparam BRN = 6'b000001;
localparam BRC = 6'b000010;
localparam BRO = 6'b000011;
localparam BRA = 6'b000100;
localparam JMP = 6'b000101;
localparam RET = 6'b000110;
localparam HLT = 6'b011101;
localparam FIRST_ALU = 6'b001011;
localparam LAST_ALU  = 6'b011100;
localparam CMP = 5'b11001;
localparam TST = 5'b11010;

localparam INP = 6'b011110;
localparam OUT = 6'b011111;

localparam STR = 5'b01001;
localparam LDR = 5'b01010;

localparam PSH = 6'b000111;
localparam POP = 6'b001000;

localparam RTT = 6'b111100;
localparam LOG = 6'b111011;

always @(*) begin
    branch_enable_nxt = 0;
    store_registerX_nxt = 0;
    store_registerY_nxt = 0;
    alu_start_nxt = 0;
    loadPC_nxt = 0;
    acc_store_nxt = 0;
    regI_short_nxt = 0;
    flags_write_enable_nxt = 0;
    offset_short_nxt = 0;
    input_read_nxt = 0;
    store_from_input_nxt = 0;
    output_write_nxt = 0;
    memory_write_nxt = 0;
    mem_to_register_nxt = 0;
    stack_push_nxt = 0;
    enable_sp_nxt = 0;
    stack_pop_nxt = 0;
    stack_push_pc_nxt = 0;
    stack_pop_pc_nxt = 0;
    load_pc_from_st_nxt = 0;

    case(state_reg)
        IDLE:begin
            if(start) begin
                state_nxt = FETCH;
            end
        end

        FETCH:begin
            if(instr == 16'hFFFF) begin
                hlt = 1;
            end
            instr_nxt = instr;
            opcode_nxt = instr[15:10];
            state_nxt = DECODE;
        end

        DECODE:begin
            if(opcode_reg == RTT || opcode_reg == LOG || (FIRST_ALU <= {1'b0, opcode_reg[4:0]} && {1'b0, opcode_reg[4:0]} <= LAST_ALU)) begin
                alu_op1_select_nxt = instr_reg[9] ? SEL_Y : SEL_X;
                if(instr_reg[15] == 1'b0) begin
                    alu_op2_select_nxt = instr_reg[8] ? SEL_Y : SEL_X;
                end else begin
                    alu_op2_select_nxt = SEL_I;
                    regI_short_nxt = instr_reg[8:0];
                end
                loadPC_nxt = 1;
                state_nxt = ALU;
            end else begin
                case(opcode_reg)
                    BRZ, BRN, BRC, BRO, BRA: begin
                        offset_short_nxt = instr_reg[9:0];
                        loadPC_nxt = 1;
                        state_nxt = STALL;
                    end
                    HLT: begin
                        hlt = 1;
                    end
                    INP: begin
                        input_read_nxt = 1;
                        state_nxt = INPUT_STALL;
                        loadPC_nxt = 1;
                    end
                    OUT: begin
                        output_write_reg = 1;
                        output_reg_select_reg = instr_reg[9] ? SEL_Y : SEL_X;
                        loadPC_nxt = 1;
                        state_nxt = OUTPUT_STALL;
                    end
                    PSH: begin
                        stack_reg_select_nxt = instr_reg[9] ? SEL_Y : SEL_X;
                        memory_write_nxt = 1;
                        state_nxt = PUSH_STALL;
                        stack_push_nxt = 1;
                        loadPC_nxt = 1;
                    end
                    POP: begin
                        stack_pop_nxt = 1;
                        loadPC_nxt = 1;
                        state_nxt = POP_STALL;
                        store_registerX_nxt = ~(instr_reg[9]);
                        store_registerY_nxt = instr_reg[9];
                    end
                endcase
                case(opcode_reg)
                    BRZ: begin
                        if(flags[ZF]) begin
                            branch_enable_nxt = 1;
                        end
                    end
                    BRN: begin
                        if(flags[NF]) begin
                            branch_enable_nxt = 1;
                        end
                    end
                    BRC: begin
                        if(flags[CF]) begin
                            branch_enable_nxt = 1;
                        end
                    end
                    BRO: begin
                        if(flags[VF]) begin
                            branch_enable_nxt = 1;
                        end
                    end
                    BRA: begin
                        branch_enable_nxt = 1;
                    end
                    JMP: begin
                        offset_short_nxt = instr_reg[9:0];
                        branch_enable_nxt = 1;
                        loadPC_nxt = 1;
                        stack_push_pc_nxt = 1;
                        memory_write_nxt = 1;
                        state_nxt = JMP_STALL;
                        stack_push_nxt = 1;
                    end
                    RET: begin
                        stack_pop_nxt = 1;
                        state_nxt = RET_STALL;
                        stack_pop_pc_nxt = 1;
                        load_pc_from_st_nxt = 1;
                        loadPC_nxt = 1;
                    end
                endcase
                case(opcode_reg[4:0])
                    STR: begin
                        if(opcode_reg[5] == 1'b1) begin
                            regI_short_nxt = instr_reg[8:0];
                            memory_address_select_nxt = SEL_I;
                        end else begin
                            memory_address_select_nxt = instr_reg[8] ? SEL_Y : SEL_X;
                        end
                        memory_write_select_nxt = instr_reg[9] ? SEL_Y : SEL_X;
                        state_nxt = STORE_STALL;
                        loadPC_nxt = 1;
                    end
                    LDR: begin
                        if(opcode_reg[5] == 1'b1) begin
                            regI_short_nxt = instr_reg[8:0];
                            memory_address_select_nxt = SEL_I;
                        end else begin
                            memory_address_select_nxt = instr_reg[8] ? SEL_Y : SEL_X;
                        end
                        state_nxt = LOAD_STALL;
                        loadPC_nxt = 1;
                    end
                endcase
            end
        end

        ALU:begin
            alu_operation_nxt = opcode_reg;
            if(alu_done) begin
                acc_store_nxt = 1;
                state_nxt = WB;

                flags_write_enable_nxt = 1;
            end else begin
                alu_start_nxt = 1;
                state_nxt = ALU;
            end
        end

        WB:begin
            if(opcode_reg[4:0] == CMP || opcode_reg[4:0] == TST) begin
                store_registerX_nxt = 0;
                store_registerY_nxt = 0;
            end else begin
                store_registerX_nxt = ~(instr_reg[9]);
                store_registerY_nxt = instr_reg[9];
            end
            state_nxt = STALL;
        end

        INPUT_STALL:begin
            store_from_input_nxt = 1;
            store_registerX_nxt = ~(instr_reg[9]);
            store_registerY_nxt = instr_reg[9];
            state_nxt = STALL;
        end

        OUTPUT_STALL:begin
            state_nxt = STALL;
        end

        STORE_STALL:begin
            memory_write_nxt = 1;
            state_nxt = STALL;
        end

        LOAD_STALL:begin
            mem_to_register_nxt = 1;
            store_registerX_nxt = ~(instr_reg[9]);
            store_registerY_nxt = instr_reg[9];
            state_nxt = STALL;
        end

        PUSH_STALL: begin
            state_nxt = STALL;
            enable_sp_nxt = 1;
        end

        POP_STALL: begin
            enable_sp_nxt = 1;
            state_nxt = STALL;
        end

        JMP_STALL: begin
            enable_sp_nxt = 1;
            state_nxt = STALL;
        end

        RET_STALL: begin
            enable_sp_nxt = 1;
            state_nxt = STALL;
        end

        STALL:begin
            state_nxt = FETCH;
        end

    endcase
end

assign alu_operation = alu_operation_reg;
assign alu_op1_select = alu_op1_select_reg;
assign alu_op2_select = alu_op2_select_reg;
assign store_registerX = store_registerX_reg;
assign store_registerY = store_registerY_reg;
assign alu_start = alu_start_reg;
assign branch_enable = branch_enable_reg;
assign loadPC = loadPC_reg;
assign acc_store = acc_store_reg;
assign regI_short = regI_short_reg;
assign flags_write_enable = flags_write_enable_reg;
assign offset_short = offset_short_reg;
assign input_read = input_read_reg;
assign store_from_input = store_from_input_reg;
assign output_write = output_write_reg;
assign output_reg_select = output_reg_select_reg;
assign memory_write = memory_write_reg;
assign memory_address_select = memory_address_select_reg;
assign memory_write_select = memory_write_select_reg;
assign mem_to_register = mem_to_register_reg;
assign stack_reg_select = stack_reg_select_reg;
assign stack_push = stack_push_reg;
assign enable_sp = enable_sp_reg;
assign stack_pop = stack_pop_reg;
assign stack_push_pc = stack_push_pc_reg;
assign stack_pop_pc = stack_pop_pc_reg;
assign load_pc_from_st = load_pc_from_st_reg;

endmodule
