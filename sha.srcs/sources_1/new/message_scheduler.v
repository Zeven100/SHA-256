
module message_scheduler (
     input wire [32*16 - 1:0] in, 
     output wire [32*64 - 1:0] out 
);
parameter w = 32;


reg [32*64 - 1:0] W;
assign out = W;

integer i;

always @(*) begin
    for (i = 0; i < 16; i = i + 1) begin
        W[(63-i)*32 +: 32] = in[(15-i)*32 +: 32];
    end

    for (i = 16; i < 64; i = i + 1) begin
        W[(63-i)*32 +: 32] = rho1(W[(63-(i-2))*32 +: 32]) +
                             W[(63-(i-7))*32 +: 32] +
                             rho0(W[(63-(i-15))*32 +: 32]) +
                             W[(63-(i-16))*32 +: 32];
    end
end


function [31:0] rho0(input [31:0] x);
     begin
          rho0 = ROTR(x, 7) ^ ROTR(x, 18) ^ SHR(x, 3);
     end
endfunction

function [31:0] rho1(input [31:0] x);
     begin
          rho1 = ROTR(x, 17) ^ ROTR(x, 19) ^ SHR(x, 10);
     end
endfunction

function [31:0] ROTR(input [31:0] x, input [4:0] n);
     ROTR = (x >> n) | (x << (w - n));
endfunction

function [31:0] SHR(input [31:0] x, input [4:0] n);
     SHR = x >> n;
endfunction

endmodule
