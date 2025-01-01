`timescale 1ns/1ps
`include "main.v"
module tb ();
reg clk , reset_n , start ;
reg [16*32 - 1 : 0] in ;
wire [32 * 8 -1 : 0] out ;

main DUT(clk , start , reset_n , in , out) ;
initial begin
     clk = 0;
     forever #5 clk = ~clk; 
end
initial begin
     reset_n = 0;
     start = 0 ; 
     in = 512'h61626380000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000018 ;

     #10 reset_n = 1 ;
     #2 start = 1 ;
     #110 
     $stop ;
end
initial begin
     $dumpfile("tb.vcd") ;
     $dumpvars(0, tb) ;
end



endmodule