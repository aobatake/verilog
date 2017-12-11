

// LEGLiteP0
//
// This is empty, so you have to fill it up with parts
// and the controller such as
// * registers between pipeline stages, e.g., IF/ID register
// * ALU
// * multiplexers
// * register file
// * Instruction memory
// * controller
//
// Note that you can get most of these parts from Parts.V
// Remember that RegFile is synchronized with negative clock
//    edge, e.g., always @(negedge clock)
//
// In the code below, comments show where to put each stage
//    and the registers between stages.


module LEGLiteP0(
	imemaddr, 	// Instruction memory addr
	dmemaddr,	// Data memory addr
	dmemwdata,	// Data memory write-data
	dmemwrite,	// Data memory write enable
	dmemread,	// Data memory read enable
	aluresult,	// Output from the ALU:  for debugging
	clock,
	imemrdata,	// Instruction memory read data
	dmemrdata,	// Data memory read data
	reset		// Reset
	);

output [15:0] imemaddr;
output [15:0] dmemaddr;
output [15:0] dmemwdata;
output dmemwrite;	
output dmemread;	
output [15:0] aluresult;	
input clock;
input [16:0] imemrdata;	
input [15:0] dmemrdata;
input reset; 

//------- IF stage ----------------


//------- IF/ID register ----------
// To implement this register, you must declare
// register variables, e.g.,
// reg IFIDinstr[15:0];
// reg IFIDpc[15:0];
// always @(posedge clock)
//    begin
//    IFIDinstr[15:0] <= InstructionMemory[pc];
//    IFIDpc <= pc;
//    end


//------- ID stage ----------------


//------- ID/EX register ----------


//------- EX stage ----------------


//------- EX/MEM register ----------


//------- MEM Stage ----------------


//------- MEM/WB pipeline register ----


//------- WB Stage ------------------
	
endmodule
