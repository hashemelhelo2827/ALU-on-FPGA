module multipling(input [3:0] a ,input b ,input [2:0]shift,output  [7:0] x);
    wire  [7:0] y;
    assign y = a << shift ;
    genvar i;   
    generate 
    for (i=0;i<8;i=i+1) begin:loop_block
         assign x[i] = y[i] & b; 
     end
    endgenerate
endmodule 

module multiply(input [3:0] a1 ,input [3:0] b1 ,output [7:0] xout);
    wire [7:0] x1, x2, x3, x4;
    wire [7:0] x1out, x2out;
    multipling m1 (.a(a1),.b(b1[0]),.shift(3'd0),.x(x1));
    multipling m2 (.a(a1),.b(b1[1]),.shift(3'd1),.x(x2));
    multipling m3 (.a(a1),.b(b1[2]),.shift(3'd2),.x(x3));
    multipling m4 (.a(a1),.b(b1[3]),.shift(3'd3),.x(x4));
    adder dr1( .a1(x1),.b1(x2),.cin1(0),.s1(x1out)); 
    adder dr2( .a1(x3),.b1(x4),.cin1(0),.s1(x2out)); 
    adder dr3( .a1(x1out),.b1(x2out),.cin1(0),.s1(xout));
endmodule