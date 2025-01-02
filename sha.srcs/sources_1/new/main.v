`include "message_scheduler.v"
`include "compressor.v"
module main (
     input wire clk ,
     input wire start , reset_n ,
     input wire [16 * 32 - 1 : 0] in ,
     output reg [8*32 -1 : 0]out 
);
reg [3:0]round_nm_reg , round_nm_new ;
reg [1:0]round_ctrl_reg , round_ctrl_new ;
reg round_nm_rst , round_nm_inc ;
parameter [1:0]CTRL_IDLE = 2'b00 , CTRL_INIT = 2'b01 , CTRL_MAIN = 2'b10 , CTRL_FINAL = 2'b11 ;
reg [31:0]a_reg , b_reg , c_reg , d_reg , e_reg , f_reg , g_reg , h_reg ;
reg [31:0]a_new , b_new , c_new , d_new , e_new , f_new , g_new , h_new ;
wire [31:0]a_wire , b_wire , c_wire , d_wire , e_wire , f_wire , g_wire , h_wire ;

wire [31:0]H0_0 = 32'h6A09E667 ;
wire [31:0]H1_0 = 32'hBB67AE85 ;
wire [31:0]H2_0 = 32'h3C6EF372 ;
wire [31:0]H3_0 = 32'hA54FF53A ;
wire [31:0]H4_0 = 32'h510E527F ;
wire [31:0]H5_0 = 32'h9B05688C ;
wire [31:0]H6_0 = 32'h1F83D9AB ;
wire [31:0]H7_0 = 32'h5BE0CD19 ;

reg [31:0]H0 , H1 , H2 , H3 , H4 , H5 , H6 , H7  ; 


wire [64 * 32 - 1 : 0]W ;
message_scheduler ms_inst(in , W) ;
compressor c_inst(a_reg , b_reg , c_reg , d_reg , e_reg , f_reg , g_reg , h_reg ,
                    round_nm_reg - 4'd2 , W , 
                    a_wire , b_wire , c_wire , d_wire , e_wire , f_wire , g_wire , h_wire ) ;
always @(posedge clk ) begin
     if(~reset_n)begin
          round_nm_reg <= 0 ;
          round_ctrl_reg <=CTRL_IDLE ;
     end
     else begin
          round_nm_reg <= round_nm_new ;
          round_ctrl_reg <= round_ctrl_new ;
          a_reg <= a_new ; 
          b_reg <= b_new ;
          c_reg <= c_new ;
          d_reg <= d_new ;
          e_reg <= e_new ;
          f_reg <= f_new ;
          g_reg <= g_new ;
          h_reg <= h_new ;
     end
end

always @ * begin
     round_nm_new = 0 ;
     if(round_nm_rst )begin
          round_nm_new = 1 ;
     end
     else if(round_nm_inc )begin
          round_nm_new = round_nm_reg + 1 ;
     end
end

always @ * begin
     round_nm_rst = 0 ;
     round_nm_inc = 0 ;
     case(round_ctrl_reg)
     CTRL_IDLE :begin
          if(start)begin
               round_nm_rst = 1 ;
               round_ctrl_new = CTRL_INIT ;
          end
     end
     CTRL_INIT : begin
          a_new = H0_0 ; 
          b_new = H1_0 ;
          c_new = H2_0 ;
          d_new = H3_0 ;
          e_new = H4_0 ;
          f_new = H5_0 ;
          g_new = H6_0 ;
          h_new = H7_0 ;
          round_nm_inc = 1 ;
          round_ctrl_new = CTRL_MAIN ;
     end
     CTRL_MAIN : begin
          a_new = a_wire ; 
          b_new = b_wire ;
          c_new = c_wire ;
          d_new = d_wire ;
          e_new = e_wire ;
          f_new = f_wire ;
          g_new = g_wire ;
          h_new = h_wire ;
          round_nm_inc = 1 ;
          round_ctrl_new = (round_nm_reg==9) ? CTRL_FINAL : CTRL_MAIN ;

     end
     CTRL_FINAL : begin
          H0 = a_reg + H0_0 ;
          H1 = b_reg + H1_0 ;
          H2 = c_reg + H2_0 ;
          H3 = d_reg + H3_0 ;
          H4 = e_reg + H4_0 ;
          H5 = f_reg + H5_0 ;
          H6 = g_reg + H6_0 ;
          H7 = h_reg + H7_0 ;
          out = {H0 , H1 , H2 , H3 , H4 , H5 , H6 , H7} ;
          round_nm_rst = 1 ;
          round_ctrl_new = CTRL_IDLE ;
     end
     endcase
end
     
endmodule