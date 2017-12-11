// EE 361L
// testbench for PMIPSL0 Subproject 2
//
// It runs the program IM2.V from Homework 10.  Recall that the
// program will check switch 0.  Then depending if its 0 or 1,
// it sets the 7-segment display to "0" or "1".
// 
module testbench;

wire [15:0] imemaddr; 	// Instruction memory addr
wire [15:0] dmemaddr;	// Data memory addr
wire [15:0] dmemwdata;	// Data memory write-data
wire dmemwrite;	// Data memory write enable
wire dmemread;	// Data memory read enable
wire [15:0] aluresult;	// Output from the ALU:  for debugging
wire [15:0] aluout;		// Output from the ALUOut register:  for debugging

wire [16:0] imemrdata;	// Instruction memory read data
wire [15:0] dmemrdata;	// Data memory read data


reg io_sw0;
reg io_sw1;
wire [6:0] io_display;


reg  clock;
reg  reset;		// Reset

// debug probes
wire [15:0] probe1, probe2, probe3;

// Clock
initial clock=0;
always #1 clock=~clock;


initial 
	begin
	$display("\nIO[display,switch0,switch1]\n");
	$display("IMEM[PC,Instr]\n");
	$display("DMEM[address, rdata, wdata]\n");
	$display("ALU[result]\n");
	$display("Signals[clock,reset,time]");
	reset=1;
	io_sw0=1;
	io_sw1=0;
	#2
	reset=0;
	#100
	io_sw0=0;
	io_sw1=0;
	#200
	$finish;
	end


initial
	$monitor("IO[%b,%b,%b] IMEM[%d,%b] DMEM[%d,%d,%d] ALU[%d] Signals[%b,%b,%0d] Probes[%d,%d,%d]",
		io_display,
		io_sw0,
		io_sw1,
		
		imemaddr,
		imemrdata,
		
		dmemaddr,
		dmemrdata,
		dmemwdata,
		
		aluresult,
		
		clock,
		reset,
		$time,
      
      probe1,
      probe2,
      probe3
		);


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

// Instantiation of Instruction Memory (program)

IM  instrmem(imemrdata,imemaddr);


// Instantiation of Data Memory


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