module calcv2 (
    input  [9:0] SW,
    input        CLOCK_50, 
    input        KEY,
    output [9:0] LEDR,
    output [6:0] HEX0,
    output [6:0] HEX1,
    output [6:0] HEX2,
    output [6:0] HEX3,
    output [6:0] HEX4,
    output [6:0] HEX5
);

    reg [7:0] R0 = 8'b00000000;
    reg [7:0] R1 = 8'b00000000;
    reg [7:0] R2 = 8'b00000000;
    
    reg [7:0] operand_A; 
    reg [7:0] operand_B; 
    reg [8:0] alu_output;
    
    reg flag_carry;
    reg flag_zero;
    reg flag_sign;

    localparam ADD = 2'b00;
    localparam SUB = 2'b01;
    localparam MUL = 2'b10;
    localparam MOV = 2'b11;

    reg [19:0] sample_cnt;
    reg key_stable;       
    reg key_stable_prev;  

    always @(posedge CLOCK_50) begin
        if (sample_cnt < 500_000) begin
            sample_cnt <= sample_cnt + 1'b1;
        end else begin
            sample_cnt <= 20'd0;
            key_stable <= KEY;
        end
        key_stable_prev <= key_stable;
    end

    wire write_pulse = (key_stable_prev == 1'b1 && key_stable == 1'b0);
    
    
    wire [8:0] add_output;
    wire [8:0] sub_output;
    wire [8:0] multi_output;

    adder      d1 (.a1(operand_A), .b1(operand_B), .cin1(1'b0), .s1(add_output));
    subtractor s  (.as(operand_A), .bs(operand_B), .d(sub_output));
    multiply   m  (.am(operand_A), .bm(operand_B), .xout(multi_output));

   
    always @(*) begin
        case (SW[7:6])
            2'b00: operand_A = R0;         
            2'b01: operand_A = R1;           
            2'b10: operand_A = R2;           
            default: operand_A = {4'b0000, SW[3:0]}; 
        endcase

        
        case (SW[5:4])
            2'b00: operand_B = R0;
            2'b01: operand_B = R1;
            2'b10: operand_B = R2;
            default: operand_B = 8'b00000000; 
        endcase

        case (SW[9:8])
            ADD: alu_output = add_output;
            SUB: alu_output = sub_output;
            MUL: alu_output = multi_output; 
            MOV: alu_output = {1'b0, operand_A}; 
        endcase 
        
        flag_zero = (alu_output[7:0] == 8'b00000000) ? 1'b1 : 1'b0;
        flag_sign = alu_output[7]; 
        
        if (SW[9:8] == ADD)
            flag_carry = alu_output[8]; 
        else if (SW[9:8] == SUB)
            flag_carry = (operand_A < operand_B); 
        else
            flag_carry = 1'b0;
    end

   
    always @(posedge CLOCK_50) begin
        if (write_pulse) begin 
            case (SW[5:4])
                2'b00: R0 <= alu_output[7:0];
                2'b01: R1 <= alu_output[7:0];
                2'b10: R2 <= alu_output[7:0];
                default: begin end
            endcase
        end
    end

    assign LEDR[0] = flag_carry;
    assign LEDR[1] = flag_sign;
    assign LEDR[2] = flag_zero;
    assign LEDR[9:3] = 7'b0000000;

    hex_decoder hd0 (.in(alu_output[3:0]), .out(HEX0)); 
    hex_decoder hd1 (.in(alu_output[7:4]), .out(HEX1));
    reg [6:0] op_display;
    always @(*) begin
        case (SW[9:8])
            ADD: op_display = 7'b0001000; //A
            SUB: op_display = 7'b0010010; //S
            MUL: op_display = 7'b0101011; //N
            MOV: op_display = 7'b0000110; //E   
            default: op_display = 7'b1111111; 
        endcase
    end

    assign HEX2 = op_display;
    assign HEX3 = 7'b1111111;
    assign HEX4 = 7'b1111111; 
    assign HEX5 = 7'b1111111; 

endmodule
