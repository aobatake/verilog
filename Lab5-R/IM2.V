// Program or Instuction Memory
// Program 2 which tests memory and IO
//

module IM(idata,iaddr);

output [16:0] idata;
input  [15:0] iaddr;

reg    [16:0] idata;

always @(iaddr[5:1])
  case(iaddr[5:1])

	0: idata={4'd6,3'd0,3'd2,7'd1};       //addi $2,$0,1    # Load $2=1, used for and
	1: idata={4'd6,3'd0,3'd3,7'b1110000}; //addi $3,$0,fff0 # $3=fff0, addr to sw0/display
	2: idata={4'd6,3'd0,3'd4,7'd16};      //addi $4,$0,16   # $4 = 16, addr to data memory
	3: idata={4'd6,3'd0,3'd5,7'b1111110}; //addi $5,$0,1111110 # 1111110 displays "0"
	4: idata={4'd4,3'd4,3'd5,7'd6};       //sw   $5,6($4)   # Memory[$4+6] = "0"
	5: idata={4'd6,3'd0,3'd5,7'b0110000}; //addi $5,$0,0110000 #0110000 displays "1"
	6: idata={4'd4,3'd4,3'd5,7'd8};       //sw   $5,8($4)   # Memory[$4+8] = "1"
	                                //Loop:
	7: idata={4'd3,3'd3,3'd5,7'd0};       //lw   $5,0($3)   # $5 = IO[fff0], sw0
	8: idata={4'd7,3'd5,3'd5,7'd1};  //andi  $5,$5,1   # andi $5 and 1
	9: idata={4'd5,3'd5,3'd0,7'd2};       //beq  $5,$0,LoadValue0 # offset = 2
	10: idata={4'd3,3'd4,3'd5,7'd8};      //lw   $5,8($4)   # $5 = "1"
	11: idata={4'd8,13'd13};              //j    Skip2      # jump to 13
		                            //LoadValue0:
	12: idata={4'd3,3'd4,3'd5,7'd6};      //lw   $5,6($4)   # $5 = "0"
	                                //Skip2:
	13: idata={4'd4,3'd3,3'd5,7'd10};     //sw   $5,10($3)  # IO[fffa] = display
	14: idata={4'd8,13'd7};               //j    Loop       # jump 7
    default: idata=0;
  endcase
  
endmodule