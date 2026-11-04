// Immediate generator for RV32I.
// Extracts and sign-extends the immediate for each instruction format.
// imm_sel: 0=I, 1=S, 2=B, 3=U, 4=J
module immediate_gen (
    input  wire [31:0] instr,
    input  wire [2:0]  imm_sel,
    output reg  [31:0] imm
);
    localparam SEL_I = 3'd0;
    localparam SEL_S = 3'd1;
    localparam SEL_B = 3'd2;
    localparam SEL_U = 3'd3;
    localparam SEL_J = 3'd4;

    always @(*) begin
        case (imm_sel)
            SEL_I: imm = {{20{instr[31]}}, instr[31:20]};
            SEL_S: imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            SEL_B: imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
            SEL_U: imm = {instr[31:12], 12'd0};
            SEL_J: imm = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
            default: imm = 32'd0;
        endcase
    end
endmodule
