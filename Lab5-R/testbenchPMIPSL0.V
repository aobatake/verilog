// EE 361L
// testbench for PMIPSL0
//  
// Note that the PMIPSL0.V file has an incomplete version of
// the computer.  In addition some of the signal values have
// be set to particular values.  For example, the inputs
// to the register file have been set to write the value "5"
// into register $3.  You need to replace this as you
// complete the computer design.
// 
module testbench;


wire [15:0] imemaddr; 	// Instruction memory addr
wire [15:0] dmemaddr;	// Data memory addr
wire [15:0] dmemwdata;	// Data memory write-data
wire dmemwrite;	// Data memory write enable
wire dmemread;	// Data memory read enable
wire [15:0] aluresult;	// Output from the ALU:  for debugging
wire [15:0] aluout;		// Output from the ALUOut register:  for debugging

reg  [16:0] imemrdata;	// Instruction memory read data
wire [15:0] dmemrdata;	// Data memory read data

reg  clock;
reg  reset;		// Reset

wire[15:0] probe1, probe2, probe3;

// Clock
initial clock=0;
always #1 clock=~clock;

// Test signals
// Insert instructions for testing
// You can modify it to test your computer.
// Here are other samples of instructions:
// beq $0,$0,[offset= -4] = {3'd2, 3'd0, 3'd0,7'b1111110}; Note the instruction
//      stores the constant value  -2 since the the offset is -4
// slt $4,$3,$0 = {3'd0, 3'd3, 3'd0, 3'd4, 4'd4}

initial
	begin
	imemrdata = {4'b0110, 3'b000, 3'b101,7'b0000011};  // addi $5,$0,3
	reset = 1;
	#2
	reset = 0;
	#10
	imemrdata={4'd7,3'd5,3'd6,7'd1};  //andi  $6,$5,1   # andi $5 and 1
	#10
	imemrdata ={4'd6, 3'd6, 3'd8, 7'd7};  // addi $5,$0,$7
	#15
	$stop;
	end
	
initial
	begin
	$display("IMem(PC,Instr),ALU(Result,Out),ALU(Clock,Reset), probe\n");
	$monitor("PC(%d,%d) ALU(%d,%d) [%b,%b], probe1(%b)",
		imemaddr,
		imemrdata,
		aluresult,
		dmemaddr,
		clock,
		reset,
		probe1);
	end

// Instantiation of processor

	
PMIPSL0 comp(
	imemaddr, 	// Instruction memory addr
	dmemaddr,	// Data memory addr
	dmemwdata,	// Data memory write-data
	dmemwrite,	// Data memory write enable
	dmemread,	// Data memory read enable
	aluresult,	// Output from the ALU:  for debugging
	clock,
	imemrdata,	// Instruction memory read data
	dmemrdata,	// Data memory read data
	reset,		// Reset
	probe1,
   probe2,
   probe3
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
		clock,		// clock
		dmemaddr,	// address
		dmemwdata,	// write data
		dmemwrite,	// write enable
		dmemread,	// read enable
		io_sw0,		// IO port connected to sliding switch 0
		io_sw1		// IO port connected to sliding switch 1
		);


endmodule