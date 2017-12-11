// EE 361 Hw 9
// Testbench for the following parts found in
// MIPS-Parts.V
// * 2:1 multiplexer
// * 4:1 multiplexer
// * Sign extender
// * ALU

module testbenchHw9MIPSPartsCombParts;

// Register variables to generate input signals
// to the circuits, and wire variables to output
// values.

wire [15:0] res2;
wire [15:0] res4;
reg [15:0] in0;
reg [15:0] in1;
reg [15:0] in2;
reg [15:0] in3;
reg sel2;
reg [1:0] sel4;
reg [6:0] sign_value;
wire [15:0] res_sign;
wire [15:0] res_alu;
reg [2:0] sel_alu;
wire zero_res;

// Instantiations of the four circuits

MUX2 mux_Circuit(
	res2,		// Output of multiplexer
	in0,		// Input 0
	in1,		// Input 1
	sel2		// 1-bit select
	);

MUX4 mux_Circuit(
	res4,		// 16 bit output
	in0,		// Input 0
	in1,		// Input 1
	in2,		// Input 2
	in3,		// Input 3
	sel4		// 2-bit select input
	);	

SignExt signext_Circuit(
	res_sign,	// 16 bit sign extended result
	sign_value		// 7 bit twos complement input
	);	

ALU alu_Circuit(
	res_alu,		// 16-bit output from the ALU
	zero_res,		// equals 1 if the result is 0, and 0 otherwise
	in0,			// data input
	in1,			// data input
	sel_alu			// 3-bit select
	);		
	
initial 
	begin
	in0 = 4;
	in1 = 3;
	in2 = 2;
	in3 = 1;
	sign_value = -2;
	sel2 = 0;
	sel4 = 0;
	sel_alu = 0;
	$display("\ninput[%b, %b, %b, %b]\n",in0,in1,in2,in3);
	$display("ALU = ADD");
	#4

	sel2 = 1;
	sel4 = 1;
	sel_alu = 1;
	sign_value = 2;
	$display("ALU = Subtract");
	#4
	sel4 = 2;
	sel_alu = 2;
	$display("ALU = SLT");
	#4
	sel4 = 3;
	sel_alu = 3;
	$display("ALU = OR");
	#4	
	sel_alu = 4;
	$display("ALU = AND");
	#4
	in1 = 7;
	sel_alu = 0;
	sel2 = 0;
	sel4 = 1;
	$display("\ninput[%b, %b, %b, %b]\n",in0,in1,in2,in3);
	$display("ALU = ADD");
	#4
	sel_alu = 1;
	$display("ALU = SUB");
	#4
	sel_alu = 2;
	$display("ALU = SLT");
	#4
	sel_alu = 3;
	$display("ALU = OR");
	#4
	sel_alu = 4;
	$display("ALU = AND");
	#4
	$finish;
	end
	
initial
	begin
	$display("Mux2(Select,Output),Mux4(Select,Output), ALU(Select,Output,zero)\n");
	$monitor("Mux2(%b,%b) Mux4(%b,%b) ALU(%b,%b,%b) SignExt=%b",
		sel2,res2,sel4,res4,sel_alu,res_alu,zero_res,res_sign);
	end

endmodule