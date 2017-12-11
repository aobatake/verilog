// EE 361L
// testbench for LEGLiteP0
//  
// This testbench will input instructions into the CPU.
//    So no instruction memory is instantiated.
//    You can modify this testbench to check whether 
//    particular instructions are executed properly.
// 
module testbench;

wire [15:0] imemaddr; 	// Instruction memory addr
wire [15:0] dmemaddr;	// Data memory addr
wire [15:0] dmemwdata;	// Data memory write-data
wire dmemwrite;	// Data memory write enable
wire dmemread;	// Data memory read enable
wire [15:0] aluresult;	// Output from the ALU:  for debugging
wire [15:0] aluout; // Output from the ALUOut register:  for debugging

reg  [15:0] imemrdata;	// Instruction memory read data
wire [15:0] dmemrdata;	// Data memory read data

reg  clock;
reg  reset;		// Reset

// Clock
initial clock=0;
always #1 clock=~clock;

// Test signals
// Insert instructions for testing
// You can modify it to test your computer, i.e.,
//   input other instructions
// Here are other samples of instructions:

initial
	begin
	imemrdata = {3'd6,7'd3,3'd7,3'd1};  // ADDI X1,XZR,#3
	reset = 1;
	#2
	reset = 0;
	#10
	imemrdata = {3'd6,7'd5,3'd7,3'd3};  // ADDI X3,XZR,#5
     #10
      imemrdata = {3'd6,7'd4,3'd3,3'd1};  // ADDI X1,X3,#4
	#10
	imemrdata ={3'd0,3'd7,4'd0,3'd3,3'd4};  // ADD X4,X3,XZR
	#10
	$stop;
	end
	
initial
	begin
	$display("IMem(PC,Instr),ALU(Result,Out), ALU(Clock,Reset)\n");
	$monitor("PC(%d,%d) ALU(%d,%d) [%b,%b] ",
		imemaddr,
		imemrdata,
		aluresult,
		dmemaddr,
		clock,
		reset);
	end

// Instantiation of processor

	
LEGLiteP0 cpu(
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

// Instantiation of Data Memory

wire io_sw0;
wire io_sw1;
wire [6:0] io_display;

assign io_sw0 = 0;
assign io_sw1 = 1;

DMemory_IO datamemdevice(
		dmemrdata,	// read data
		io_display,	// IO port connected to 7 segment display
		clock,	// clock
		dmemaddr,	// address
		dmemwdata,	// write data
		dmemwrite,	// write enable
		dmemread,	// read enable
		io_sw0, // IO port connected to sliding switch 0
		io_sw1  // IO port connected to sliding switch 1
		);

endmodule