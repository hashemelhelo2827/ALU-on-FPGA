 module adding (input a , b , cin,output s ,c);
assign s = a^b^cin;
assign c = (a & b) | (a & cin) | (b & cin); 
endmodule

module adder(
input   [7:0] a1,
 input  [7:0] b1,
  input  cin1 ,
 output [8:0] s1
 );
wire [6:0] carry ;
 genvar i;
 generate 
 for (i = 0 ; i <8 ; i =i+1) begin : loop_block
  if (i==0) begin : stage0
   adding f1 (
	.a(a1[i]) ,
	.b(b1[i]) ,
	.cin(cin1),
	.s(s1[i]) ,
	.c(carry[i])
	);
	end
	else if (i < 7) begin : stage_mid
	 adding f1 (
	.a(a1[i]) ,
	.b(b1[i]) ,
	.cin(carry[i-1]),
	.s(s1[i]) ,
	.c(carry[i])
	);
	end
	else begin : stage_last
 adding f1 (
	.a(a1[i]) ,
	.b(b1[i]) ,
	.cin(carry[i-1]),
	.s(s1[i]) ,
	.c(s1[i+1])
	);	 
	end
	end 
  endgenerate 
  endmodule