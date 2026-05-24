module subtractor(
input   [3:0] as,
 input  [3:0] bs, 
 output [4:0] d);
  wire [3:0]bs_complement=~bs;
 adder d1 (.a1(as), .b1(bs_complement),.cin1(1) ,.s1(d));
 endmodule 