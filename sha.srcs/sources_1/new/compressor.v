`include "k_constants.v"

module compressor (
     input wire [31:0] a, b, c, d, 
     input wire [31:0] e, f, g, h,
     input wire [3:0] r, 
     input wire [32 * 64 - 1 : 0] W,
     output wire [31:0] ao, bo, co, do, 
     output wire [31:0] eo, fo, go, ho
);

parameter w = 32;

wire [5:0] local_round [7:0];
wire [31:0] kcOut [7:0];
wire [31:0] T1 [7:0], T2 [7:0];
wire [31:0] a_reg [7:0], b_reg [7:0], c_reg [7:0], d_reg [7:0];
wire [31:0] e_reg [7:0], f_reg [7:0], g_reg [7:0], h_reg [7:0];


assign ao = a_reg[7];
assign bo = b_reg[7];
assign co = c_reg[7];
assign do = d_reg[7];
assign eo = e_reg[7];
assign fo = f_reg[7];
assign go = g_reg[7];
assign ho = h_reg[7];


genvar i;
generate
    for (i = 0; i < 8; i = i + 1) begin : round_gen
        assign local_round[i] = r * 8 + i;
        k_constants kc_inst(
            .round(local_round[i]),
            .K(kcOut[i])
        );

        assign T1[i] = (i == 0) 
            ? (h + sig1(e) + Ch(e, f, g) + kcOut[i] + W[(64 - local_round[i])*32 - 1 -: 32] )
            : (h_reg[i-1] + sig1(e_reg[i-1]) + Ch(e_reg[i-1], f_reg[i-1], g_reg[i-1]) + kcOut[i] + W[(64 - local_round[i])*32 - 1 -: 32]);

        assign T2[i] = (i == 0)
            ? sig0(a) + Maj(a, b, c)
            : sig0(a_reg[i-1]) + Maj(a_reg[i-1], b_reg[i-1], c_reg[i-1]);

        assign h_reg[i] = (i == 0) ? g : g_reg[i-1];
        assign g_reg[i] = (i == 0) ? f : f_reg[i-1];
        assign f_reg[i] = (i == 0) ? e : e_reg[i-1];
        assign e_reg[i] = (i == 0) ? d + T1[i] : d_reg[i-1] + T1[i];
        assign d_reg[i] = (i == 0) ? c : c_reg[i-1];
        assign c_reg[i] = (i == 0) ? b : b_reg[i-1];
        assign b_reg[i] = (i == 0) ? a : a_reg[i-1];
        assign a_reg[i] = T1[i] + T2[i];
    end
endgenerate


function [31:0] Maj(input [31:0] x, input [31:0] y, input [31:0] z);
    Maj = (x & y) ^ (x & z) ^ (y & z);
endfunction

function [31:0] Ch(input [31:0] x, input [31:0] y, input [31:0] z);
    Ch = (x & y) ^ (~x & z);
endfunction

function [31:0] sig0(input [31:0] x);
    sig0 = ROTR(x, 2) ^ ROTR(x, 13) ^ ROTR(x, 22);
endfunction

function [31:0] sig1(input [31:0] x);
    sig1 = ROTR(x, 6) ^ ROTR(x, 11) ^ ROTR(x, 25);
endfunction

function [31:0] ROTR(input [31:0] x, input [4:0] n);
    ROTR = (x >> n) | (x << (w - n));
endfunction

function [31:0] SHR(input [31:0] x, input [4:0] n);
    SHR = x >> n;
endfunction

endmodule
