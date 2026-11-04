// Control unit for RV32I (subset: ADD SUB AND OR XOR ADDI LW SW BEQ BNE JAL).
// Decodes opcode, funct3, funct7 into datapath control signals.
module control_unit (
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,
    output reg        reg_write,   // write result to rd
    output reg        alu_src,     // 0: rs2 as ALU b, 1: immediate
    output reg  [3:0] alu_op,      // matches alu.v localparams
    output reg        mem_read,
    output reg        mem_write,
    output reg  [1:0] wb_sel,      // 0: ALU result, 1: memory data, 2: PC+4
    output reg        branch,      // BEQ / BNE
    output reg        branch_ne,   // 1 for BNE, 0 for BEQ
    output reg        jump,        // JAL
    output reg  [2:0] imm_sel      // matches immediate_gen.v
);
    localparam OP_R      = 7'b0110011;
    localparam OP_I      = 7'b0010011;
    localparam OP_LOAD   = 7'b0000011;
    localparam OP_STORE  = 7'b0100011;
    localparam OP_BRANCH = 7'b1100011;
    localparam OP_JAL    = 7'b1101111;

    localparam ALU_ADD = 4'd0;
    localparam ALU_SUB = 4'd1;
    localparam ALU_AND = 4'd2;
    localparam ALU_OR  = 4'd3;
    localparam ALU_XOR = 4'd4;
    localparam ALU_SLT = 4'd5;
    localparam ALU_SLL = 4'd7;
    localparam ALU_SRL = 4'd8;
    localparam ALU_SRA = 4'd9;

    // Chooses the ALU operation for R-type and I-type arithmetic.
    // SUB and SRA use funct7[5]; ADDI has no SUB form, so only R-type checks it.
    reg [3:0] arith_op;
    always @(*) begin
        case (funct3)
            3'b000: arith_op = (opcode == OP_R && funct7[5]) ? ALU_SUB : ALU_ADD;
            3'b001: arith_op = ALU_SLL;
            3'b010: arith_op = ALU_SLT;
            3'b100: arith_op = ALU_XOR;
            3'b101: arith_op = funct7[5] ? ALU_SRA : ALU_SRL;
            3'b110: arith_op = ALU_OR;
            3'b111: arith_op = ALU_AND;
            default: arith_op = ALU_ADD;
        endcase
    end

    always @(*) begin
        // Defaults: no side effects
        reg_write = 1'b0;
        alu_src   = 1'b0;
        alu_op    = ALU_ADD;
        mem_read  = 1'b0;
        mem_write = 1'b0;
        wb_sel    = 2'd0;
        branch    = 1'b0;
        branch_ne = 1'b0;
        jump      = 1'b0;
        imm_sel   = 3'd0;

        case (opcode)
            OP_R: begin
                reg_write = 1'b1;
                alu_op    = arith_op;
            end
            OP_I: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                alu_op    = arith_op;
                imm_sel   = 3'd0;   // I-type
            end
            OP_LOAD: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                alu_op    = ALU_ADD; // address = rs1 + imm
                mem_read  = 1'b1;
                wb_sel    = 2'd1;
                imm_sel   = 3'd0;
            end
            OP_STORE: begin
                alu_src   = 1'b1;
                alu_op    = ALU_ADD; // address = rs1 + imm
                mem_write = 1'b1;
                imm_sel   = 3'd1;   // S-type
            end
            OP_BRANCH: begin
                branch    = 1'b1;
                branch_ne = funct3[0]; // BEQ=000, BNE=001
                imm_sel   = 3'd2;      // B-type
            end
            OP_JAL: begin
                reg_write = 1'b1;
                wb_sel    = 2'd2;   // rd = PC+4
                jump      = 1'b1;
                imm_sel   = 3'd4;   // J-type
            end
            default: ;
        endcase
    end
endmodule
