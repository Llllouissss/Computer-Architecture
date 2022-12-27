// Your code
module CHIP(clk,
            rst_n,
            // For mem_D
            mem_wen_D,
            mem_addr_D,
            mem_wdata_D,
            mem_rdata_D,
            // For mem_I
            mem_addr_I,
            mem_rdata_I
    );
    //==== I/O Declaration ========================
    input         clk, rst_n ;
    // For mem_D
    output        mem_wen_D  ;
    output [31:0] mem_addr_D ;
    output [31:0] mem_wdata_D;
    input  [31:0] mem_rdata_D;
    // For mem_I
    output [31:0] mem_addr_I ;
    input  [31:0] mem_rdata_I;

    //==== Reg/Wire Declaration ===================
    //---------------------------------------//
    // Do not modify this part!!!            //
    // Exception: You may change wire to reg //
    reg   [31:0] PC          ;              //
    reg   [31:0] PC_nxt      ;              // 
    reg          regWrite     = 0;              //
    wire  [ 4:0] rs1, rs2, rd;              //
    wire   [31:0] rs1_data    ;              //
    wire   [31:0] rs2_data    ;              //
    wire   [31:0] rd_data     ;              //
    //-----------------alu_mode----------------------//
    

    // Todo: other wire/reg

    reg     [2:0]             state,state_nxt ;
    reg     [31:0]        mem_wen_D_w,mem_wen_D_r;
    reg     [31:0] mem_wdata_D_r,mem_wdata_D_w;
    reg     [31:0]  mem_addr_I_r,mem_addr_I_w ; 
    wire    [9:0]                mode          ;
    wire    [31:0]            imm_auipc        ;
    wire    [31:0]            imm_jal          ;
    wire    [11:0]            imm_jalr_lw_i    ;
    wire    [12:0]            imm_b            ;
    wire    [11:0]            imm_sw           ;
    wire     [4:0]             shamt           ;
    reg     [1:0]                memtoreg         ;
    wire     [3:0]             alu_mode         ;
    wire                        branch           ;
    wire     [31:0]             jump_add;
    wire     [31:0] ls_add;
    wire     [31:0]     alu_out;
    // wire    mul_reg;
    // reg     mul_reg_r,mul_reg_w;
    // wire      [31:0]         mem_data_offset;
    // wire  [31:0]             mem_text_offset;
    // wire     [31:0]          mem_stack_offset;
    // Definition of states
    parameter     IDLE  = 3'd0;
    parameter      IF   = 3'd1;
    parameter      ID   = 3'd2;
    parameter      EX   = 3'd3;
    parameter      ME   = 3'd4;
    parameter      WB   = 3'd5;
    wire   [9:0] aupic;
    wire   [9:0] jal;
    wire   [9:0] jalr;
    assign aupic   = {mem_rdata_I[14:12],7'b0010111};
    assign jal     = {mem_rdata_I[14:12],7'b1101111};
    assign jalr    = {3'b0,7'b1100111};
    parameter beq     = 10'b0001100011;
    parameter lw      = 10'b0100000011;
    parameter sw      = 10'b0100100011;
    parameter addi    = 10'b0000010011;
    parameter slti    = 10'b0100010011;
    parameter add     = 10'b0000110011;
    parameter op_xor  = 10'b1000110011;
    parameter bge     = 10'b1011100011;
    parameter srai    = 10'b1010010011;
    parameter slli    = 10'b0010010011;
    parameter div     = 10'b1000110011;



    // parameter alu_aupic   = 0;
    // parameter alu_jal     = 1;
    // parameter alu_jalr    = 2;
    // parameter alu_beq     = 3;
    // parameter alu_lw      = 4;
    // parameter alu_sw      = 5;
    // parameter alu_addi    = 6;
    // parameter alu_slti    = 7;
    // parameter alu_add     = 8;
    // parameter alu_xor     = 9;
    // parameter alu_bge     = 10;
    // parameter alu_srai    = 11;
    // parameter alu_slli    = 12;
    // parameter alu_mul     = 13;
    // parameter alu_div     = 14;  

    //==== Submodule Connection ===================
    //---------------------------------------//
    // Do not modify this part!!!            //
    reg_file reg0(                           //
        .clk(clk),                           //
        .rst_n(rst_n),                       //
        .wen(regWrite),                      //
        .a1(rs1),                            //
        .a2(rs2),                            //
        .aw(rd),                             //
        .d(rd_data),                         //
        .q1(rs1_data),                       //
        .q2(rs2_data));                      //
    //---------------------------------------//
    
    // wire [31:0]
    wire  ready;
    // reg   vaild;
    //Todo: other submodules
//     mulDiv muldiv0(
//     .clk(clk),
//     .rst_n(rst_n),
//     .valid(valid),
//     .ready(ready),
//     .mode(mul_mode),
//     .in_A(rs1_data),
//     .in_B(rs2_data),
//     .out(mul_out)
// );
    which_mode which_mode0(
    .mode(mode),
    .alu_mode(alu_mode),
    .mem_rdata_I(mem_rdata_I)
    );

    alu alu0(
    .clk(clk),
    .rst_n(rst_n),
    .alu_mode(alu_mode),
    .in_A(rs1_data),
    .in_B(rs2_data),
    .imm_auipc(imm_auipc),
    .imm_b(imm_b),
    .imm_jal(imm_jal),
    .imm_jalr_lw_i(imm_jalr_lw_i),
    .imm_sw(imm_sw), 
    .shamt(shamt),
    .PC(PC),
    .out(alu_out),
    .out_branch(branch),
    .j_add(jump_add),
    .ls_add(ls_add),
    .mem_rdata_I(mem_rdata_I),
    .state(state),
    .alu_ready(ready)
);
    //==== Combinational Part =====================
    // Todo: any combinational/sequential circuit
    always@(*)begin
        case(state)
            IDLE:begin
                state_nxt = IF;
                PC_nxt = PC;
            end
            IF:begin
                state_nxt = ID;
            end
            ID:begin
                state_nxt = (mem_rdata_I==0)? IDLE:EX;
            end
            EX:begin
                state_nxt = ME;
            end
            ME:begin
                state_nxt = WB;
            end
            WB:begin
                state_nxt = IDLE;
                if(branch)begin
                    PC_nxt = jump_add;
                end else if(ready == 0)begin
                    PC_nxt= PC;
                end else begin
                    PC_nxt = PC + 4;
                end
            end
        endcase
    end

    always@(*)begin
        case(state)
            IF:begin
                mem_addr_I_w = PC;
                mem_wen_D_w = 0;
                regWrite = 0;
            end
            ID:begin
            end
            // EX:begin
            //     case(mode)
            //         mul:mul_reg_w = 1;
            //         div:mul_reg_w = 1;
            //         default: mul_reg_w = 0;
            //     endcase
            // end
            EX:begin
                case(mode)
                    add: begin 
                        if(mem_rdata_I[25] == 1)begin
                        end
                    end
                    lw: begin
                        mem_wen_D_w = 0;
                    end
                    sw:begin
                        mem_wen_D_w = 1;
                    end
                endcase
            end
            WB:begin
                regWrite = 1;
                mem_wen_D_w = mem_wen_D;
                case(mode)
                    lw: memtoreg = 1;
                    default: memtoreg = 0;
                endcase  
            end
        endcase
    end

    //==== Sequential Part ========================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            PC <= 32'h00400000; // Do not modify this value!!!
            state  <= IDLE;
            mem_wen_D_r <= 0;
            mem_addr_I_r <= 0;

        end
        else begin
            PC <= PC_nxt;
            state <= state_nxt;
            mem_wen_D_r <= mem_wen_D_w;
            mem_addr_I_r <= mem_addr_I_w; 
        end
    end


    //assign mul_reg = mul_reg_r;
    assign mem_addr_I = mem_addr_I_r;
    assign mem_addr_D  = ls_add;
    assign mem_wdata_D =  rs2_data;
    assign mem_wen_D = mem_wen_D_r;
    assign rd  = mem_rdata_I[11:7] ;
    assign rs1 = mem_rdata_I[19:15];
    assign rs2 = mem_rdata_I[24:20]; 
    assign imm_auipc = mem_rdata_I[31:12];
    assign imm_jal = {12'b0,mem_rdata_I[31],mem_rdata_I[19:12],mem_rdata_I[20],mem_rdata_I[30:21]};
    assign imm_jalr_lw_i = mem_rdata_I[31:20];
    assign imm_b = {1'b0,mem_rdata_I[31],mem_rdata_I[7],mem_rdata_I[30:25],mem_rdata_I[11:8]};
    assign imm_sw = {mem_rdata_I[31:25],mem_rdata_I[11:7]};
    assign mode = {mem_rdata_I[14:12],mem_rdata_I[6:0]};
    assign shamt = mem_rdata_I[24:20];
    assign rd_data = (memtoreg)?mem_rdata_D : alu_out;
endmodule

module which_mode(mode,alu_mode,mem_rdata_I);
    input [9:0] mode;
    input [31:0] mem_rdata_I;
    output reg [3:0] alu_mode;

    wire   [9:0] aupic;
    wire   [9:0] jal;
    wire   [9:0] jalr;
    assign aupic   = {mem_rdata_I[14:12],7'b0010111};
    assign jal     = {mem_rdata_I[14:12],7'b1101111};
    assign jalr    = {3'b0,7'b1100111};
    parameter beq     = 10'b0001100011;
    parameter lw      = 10'b0100000011;
    parameter sw      = 10'b0100100011;
    parameter addi    = 10'b0000010011;
    parameter slti    = 10'b0100010011;
    parameter add     = 10'b0000110011;
    parameter op_xor  = 10'b1000110011;
    parameter bge     = 10'b1011100011;
    parameter srai    = 10'b1010010011;
    parameter slli    = 10'b0010010011;

    parameter alu_aupic   = 0;
    parameter alu_jal     = 1;
    parameter alu_jalr    = 2;
    parameter alu_beq     = 3;
    parameter alu_lw      = 4;
    parameter alu_sw      = 5;
    parameter alu_addi    = 6;
    parameter alu_slti    = 7;
    parameter alu_add     = 8;
    parameter alu_sub     = 9;
    parameter alu_xor     = 10;
    parameter alu_bge     = 11;
    parameter alu_srai    = 12;
    parameter alu_slli    = 13;
    parameter alu_mul     = 14;
    parameter alu_div     = 15;

    always@(*)begin
        case(mode)
            aupic: alu_mode = alu_aupic;
            jal: alu_mode = alu_jal;
            jalr: alu_mode = alu_jalr;
            beq: alu_mode = alu_beq;
            lw: alu_mode = alu_lw;
            sw: alu_mode = alu_sw;
            addi: alu_mode = alu_addi;
            slti: alu_mode = alu_slti;
            add:begin
                if(mem_rdata_I[25] == 1)begin
                    alu_mode = alu_mul;
                end
                else if(mem_rdata_I[30] == 1)begin
                    alu_mode = alu_sub;
                end
                else begin
                    alu_mode = alu_add;
                end
            end
            op_xor: begin
                if(mem_rdata_I[25] == 1)begin
                alu_mode = alu_div;
                end else
                alu_mode = alu_xor;
            end
            bge: alu_mode = alu_bge;
            srai: alu_mode = alu_srai;
            slli: alu_mode = alu_slli;
        endcase
    end
endmodule
module alu(clk, rst_n,alu_mode,in_A, in_B,imm_auipc,imm_b,imm_jal,imm_jalr_lw_i,imm_sw ,shamt,PC,out,out_branch,j_add,ls_add,mem_rdata_I,state,alu_ready);
    input         clk, rst_n;
    input  [3:0]  alu_mode; 
    input  [31:0] in_A, in_B;
    input    [31:0]            imm_auipc        ;
    input    [31:0]            imm_jal          ;
    input    [11:0]            imm_jalr_lw_i    ;
    input    [12:0]            imm_b            ;
    input    [11:0]            imm_sw           ;
    input    [31:0]            PC               ;
    input    [4:0]             shamt            ;
    input    [2:0]             state;
    input    [31:0]             mem_rdata_I;
    output           out_branch           ;
    output [31:0] j_add;
    output [31:0] ls_add;
    output [31:0]  out;
    output      alu_ready;
    reg    [31:0]   out_w,out_r;
    reg    [31:0]   j_add_w,j_add_r;
    reg    [31:0]   branch_r,branch_w;
    reg    [31:0]   ls_add_r,ls_add_w;
    wire   [1:0]  mul_mode;
    reg    [1:0]  mode_mul;
    parameter     IDLE  = 3'd0;
    parameter      IF   = 3'd1;
    parameter      ID   = 3'd2;
    parameter      EX   = 3'd3;
    parameter      ME   = 3'd4;
    parameter      WB   = 3'd5;
    parameter alu_aupic   = 0;
    parameter alu_jal     = 1;
    parameter alu_jalr    = 2;
    parameter alu_beq     = 3;
    parameter alu_lw      = 4;
    parameter alu_sw      = 5;
    parameter alu_addi    = 6;
    parameter alu_slti    = 7;
    parameter alu_add     = 8;
    parameter alu_sub     = 9;
    parameter alu_xor     = 10;
    parameter alu_bge     = 11;
    parameter alu_srai    = 12;
    parameter alu_slli    = 13;
    parameter alu_mul     = 14;
    parameter alu_div     = 15;
    reg [19:0] jal_reg;
    reg [11:0] jalr_reg;
    wire ready;
    wire [63:0]muldiv_result;
    reg valid;
    assign mul_mode = mode_mul;


    mulDiv mulDiv0(
        .clk(clk),
        .rst_n(rst_n),
        .valid(valid),
        .ready(ready),
        .mode(mul_mode),
        .in_A(in_A),
        .in_B(in_B),
        .out(muldiv_result)
        );
    
    always @(*) begin
        case(alu_mode)
            alu_mul:begin
                mode_mul=0;
                valid=1'd1;
            end
            alu_div:begin
                mode_mul=1'd1;
                valid=1'd1;
            end
            default:begin
                mode_mul=0;
                valid=0;
            end
        endcase
    end

    always@(*) begin
        ls_add_w = 0;
        j_add_w = 0;
        branch_w = 0;
            case(state)
            EX:begin
            case(alu_mode) 
                alu_add: begin
                    out_w = in_A + in_B;
                end
                alu_sub: begin
                    out_w = in_A - in_B;
                end
                alu_aupic: begin
                    out_w = PC + (imm_auipc << 12);
                end
                alu_jal: begin
                    out_w = PC + 4;
                    branch_w = 1;
                    jal_reg = (~imm_jal)+1; 
                    if(imm_jal[19] == 1)begin
                        j_add_w = PC - (jal_reg<<1);
                    end else begin
                        j_add_w = PC + (imm_jal<<1);
                    end
                end
                alu_jalr: begin
                    out_w = PC + 4;
                    branch_w = 1;
                    jalr_reg = (~imm_jalr_lw_i)+1;
                    if(imm_jalr_lw_i[11])begin
                        j_add_w = in_A - jalr_reg;
                    end else begin
                        j_add_w = in_A + imm_jalr_lw_i;
                    end
                end
                alu_beq: begin
                    if(in_A == in_B)begin
                    j_add_w = (PC + (imm_b<<1));
                    end else begin
                    j_add_w = (PC+4);
                    end
                    branch_w = 1;
                end
                alu_lw:begin
                    ls_add_w = in_A + {20'b0,imm_jalr_lw_i};
                end
                alu_sw:begin
                    ls_add_w = in_A + {20'b0,imm_sw};
                end
                alu_addi:begin 
                    jalr_reg = (~imm_jalr_lw_i)+1;
                    if(imm_jalr_lw_i[11] == 0) begin
                        out_w = in_A + imm_jalr_lw_i;
                    end
                    else begin
                        out_w = in_A - jalr_reg;
                    end
                end
                alu_slti:begin
                    if(in_A[31] == 0 & imm_jalr_lw_i[11] == 0)begin
                        out_w = (in_A < imm_jalr_lw_i)? 1:0;
                    end
                    else if(in_A[31] == 1 & imm_jalr_lw_i[11] == 0)begin
                        out_w = 1;
                    end
                    else if(in_A[31] == 0 & imm_jalr_lw_i[11] == 1)begin
                        out_w = 0;
                    end
                    else begin
                        out_w = ((~in_A + 1) <(~imm_jalr_lw_i + 1))?1:0;
                    end
                end
                alu_xor:begin
                    out_w = (in_A^in_B);
                end
                alu_bge:begin
                    if(in_A > in_B)begin
                    j_add_w = (PC + (imm_b<<1));
                    end else begin
                    j_add_w = (PC+4);
                    end
                    branch_w = 1;
                end
                alu_srai:begin
                    out_w = in_A >> shamt;
                end
                alu_slli:begin
                    out_w = in_A << shamt;
                end
                alu_mul:begin
                    out_w = muldiv_result[31:0];
                end
                alu_div:begin
                    out_w = muldiv_result[31:0];
                end
            endcase
            end
            default: begin
                out_w = out;
                j_add_w = j_add;
                branch_w = out_branch;
                ls_add_w = ls_add;
                case(alu_mode)
                alu_mul:begin
                    out_w = muldiv_result[31:0];
                end
                alu_div:begin
                    out_w = muldiv_result[31:0];
                end
                default: begin
                    out_w = out;
                end
            endcase
            end
            endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            out_r <= 0;
            j_add_r <= 0;
            branch_r <= 0;
            ls_add_r <= 0;
        end
        else begin
            out_r <= out_w;
            j_add_r <= j_add_w;
            branch_r <= branch_w;
            ls_add_r <= ls_add_w;
        end
    end
    assign alu_ready = ((alu_mode == alu_mul)||(alu_mode == alu_div))? ready: 1;
    assign out = out_r;
    assign j_add = j_add_r;
    assign out_branch = branch_r;
    assign ls_add = ls_add_r;
endmodule
module reg_file(clk, rst_n, wen, a1, a2, aw, d, q1, q2);

    parameter BITS = 32;
    parameter word_depth = 32;
    parameter addr_width = 5; // 2^addr_width >= word_depth

    input clk, rst_n, wen; // wen: 0:read | 1:write
    input [BITS-1:0] d;
    input [addr_width-1:0] a1, a2, aw;

    output [BITS-1:0] q1, q2;

    reg [BITS-1:0] mem [0:word_depth-1];
    reg [BITS-1:0] mem_nxt [0:word_depth-1];

    integer i;

    assign q1 = mem[a1];
    assign q2 = mem[a2];

    always @(*) begin
        for (i=0; i<word_depth; i=i+1)
            mem_nxt[i] = (wen && (aw == i)) ? d : mem[i];
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mem[0] <= 0; // zero: hard-wired zero
            for (i=1; i<word_depth; i=i+1) begin
                case(i)
                    32'd2: mem[i] <= 32'h7fffeffc; // sp: stack pointer
                    32'd3: mem[i] <= 32'h10008000; // gp: global pointer
                    default: mem[i] <= 32'h0;
                endcase
            end
        end
        else begin
            mem[0] <= 0;
            for (i=1; i<word_depth; i=i+1)
                mem[i] <= mem_nxt[i];
        end
    end
endmodule

module llDiv(
    clk,
    rst_n,
    valid,
    ready,
    mode,
    in_A,
    in_B,
    out
);

    // Definition of ports
    input         clk, rst_n;
    input         valid;
    input    mode; // mode: 0: mulu, 1: divu, 2: shift, 3: avg
    output        ready;
    input  [31:0] in_A, in_B;
    output [63:0] out;

    // Definition of states
    parameter IDLE  = 3'd0;
    parameter MUL   = 3'd1;
    parameter DIV   = 3'd2;
    parameter OUT   = 3'd3;

    // Todo: Wire and reg if needed
    reg  [ 2:0] state, state_nxt;
    reg  [ 4:0] counter, counter_nxt;
    reg  [63:0] shreg, shreg_nxt, out_w, out_r;
    reg  [31:0] alu_in, alu_in_nxt, shreg_tmp;
    reg  [32:0] alu_out;
    reg         ready_w, ready_r, div_check;

    // Todo: Instatiate any primitives if needed

    // Todo 5: Wire assignments
    assign out = out_r;
    assign ready =  (state == OUT) ? 1 : 0;


    // Combinational always block
    // Todo 1: Next-state logic of state machine
    always @(*) begin
        case(state)
            IDLE: begin
                out_w = 0;
                if(!valid)begin
                   state_nxt = IDLE;
                 end else begin
                    case(mode)
                        2'b00: 
                            state_nxt = MUL;
                        2'b01:
                            state_nxt = DIV;
                    endcase
                end
            end
            MUL : begin
                if(counter == 31) begin
        
                    state_nxt = OUT;
                    out_w = shreg_nxt;
                end else begin
                    state_nxt = MUL;
                    out_w = 0;
                end
            end
            DIV : begin
                if(counter == 31) begin
                    state_nxt = OUT;
                    out_w = shreg_nxt;
                end else begin
                    state_nxt = DIV;
                    out_w = 0;
                end
            end
            OUT : begin
                state_nxt = IDLE;
                out_w = 0;
            end
            default : begin
                state_nxt = IDLE;
                out_w = 0;
            end  
        endcase
    end

    // Todo 2: Counter
    always @(*) begin
        case(state)
            IDLE: begin
                counter_nxt = 0;
            end
            MUL: begin
                counter_nxt = counter + 1;
            end
            DIV: begin
                counter_nxt = counter + 1;
            end
            default: begin
                counter_nxt = counter;
            end
        endcase

    end

    // ALU input
    always @(*) begin
        case(state)
            IDLE: begin
                if (valid) alu_in_nxt = in_B;
                else       alu_in_nxt = 0;
            end
            OUT : alu_in_nxt = 0;
            default: alu_in_nxt = alu_in;
        endcase
    end

    // Todo 3: ALU output
    always@(*) begin
        case(state)
            IDLE: begin
                alu_out = 0;
                div_check = 0;
            end
            MUL: begin
                if(shreg[0])begin
                    alu_out = alu_in + shreg[63:32];
                    div_check = 0;
                end else begin
                    alu_out = shreg[63:32];
                    div_check = 0;
                end                
            end
            DIV: begin
                if(shreg[62:31] > alu_in)begin
                    alu_out = shreg[62:31] - alu_in;
                    div_check = 1;
                end else begin
                    alu_out = shreg[62:31];
                    div_check = 0;
                end
            end
        endcase
    end

    // Todo 4: Shift register
    always@(*) begin
        case(state)
            IDLE: begin
                shreg_nxt = {32'b0, in_A};
            end
            MUL: begin
                shreg_nxt = {alu_out, shreg[31:1]};
            end 
            DIV: begin
                shreg_tmp = shreg[31:0] << 1;
                shreg_nxt = {alu_out[31:0], shreg_tmp} + div_check;
            end
            default: begin
                shreg_nxt = 0;
            end
        endcase
    end

    // Todo: Sequential always block
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state       <= IDLE;
            shreg       <= 0;
            counter     <= 0;
            out_r       <= 0;
        end 
        else begin
            alu_in      <= alu_in_nxt;
            counter     <= counter_nxt;
            state       <= state_nxt;
            shreg       <= shreg_nxt;
            out_r       <= out_w;
        end
    end

endmodule
