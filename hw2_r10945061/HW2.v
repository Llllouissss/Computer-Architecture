module ALU(
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
    input  [1:0]  mode; // mode: 0: mulu, 1: divu, 2: shift, 3: avg
    output        ready;
    input  [31:0] in_A, in_B;
    output [63:0] out;

    // Definition of states
    parameter IDLE  = 3'd0;
    parameter MUL   = 3'd1;
    parameter DIV   = 3'd2;
    parameter SHIFT = 3'd3;
    parameter AVG   = 3'd4;
    parameter OUT   = 3'd5;

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
    assign ready = ready_r ;


    // Combinational always block
    // Todo 1: Next-state logic of state machine
    always @(*) begin
        case(state)
            IDLE: begin
                //counter = 0;
                //counter_nxt = 0;
                //div_check = 0;
                //alu_out = 0;
                out_w = 0;
                ready_w = 1;
                if(!valid)begin
                   state_nxt = IDLE;
                 end else begin
                    case(mode)
                        2'b00: 
                            state_nxt = MUL;
                        2'b01:
                            state_nxt = DIV;
                        2'b10:
                            state_nxt = SHIFT;
                        2'b11:
                            state_nxt = AVG;
                    endcase
                end
            end
            MUL : begin
                if(counter == 5'd31) begin
                    ready_w = 1;
                    state_nxt = OUT;
                    out_w = shreg_nxt;
                end else begin
                    ready_w = 0;
                    state_nxt = MUL;
                    out_w = 0;
                end
            end
            DIV : begin
                if(counter == 5'd31) begin
                    ready_w = 1;
                    state_nxt = OUT;
                    out_w = shreg_nxt;
                end else begin
                    ready_w = 0;
                    state_nxt = DIV;
                    out_w = 0;
                end
            end
            SHIFT : begin
                ready_w = 1;
                out_w = shreg_nxt;
                state_nxt = OUT;
            end
            AVG : begin 
                ready_w = 1;
                out_w = shreg_nxt;
                state_nxt = OUT;
            end 
            OUT : begin
                ready_w = 0;
                state_nxt = IDLE;
                out_w = 0;
            end
            default : begin
                ready_w = 0;
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
            AVG: begin
                alu_out = alu_in + shreg[31:0];
                div_check = 0;
            end
            default: begin
                alu_out = alu_in;
                div_check = 0;
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
            SHIFT: begin
                shreg_nxt = shreg >> alu_out[2:0];
            end
            AVG: begin
                shreg_nxt = alu_out[32:1];
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
            //shreg_nxt   <= 0;
            counter     <= 0;
            //counter_nxt <= 0;
            //out_w       <= 0;
            out_r       <= 0;
        end 
        else begin
            alu_in      <= alu_in_nxt;
            counter     <= counter_nxt;
            state       <= state_nxt;
            shreg       <= shreg_nxt;
            ready_r     <= ready_w;
            out_r       <= out_w;
           // out_w       <= 0;
            //counter_nxt <= 0;
            //shreg_nxt   <= 0;
        end
    end

endmodule
