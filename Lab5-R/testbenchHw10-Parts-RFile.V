// EE 361 Hw 9 Testbench for sequential circuit Parts
// * 8 x 16 register file

module testbench;

wire [15:0] rf_rdata1;
wire [15:0] rf_rdata2;
reg [15:0] rf_wdata;
reg [2:0] rf_waddr;
reg [2:0] rf_raddr1;
reg [2:0] rf_raddr2;
reg rf_write;
reg clock;

// Instantiation
RegFile  RFile_Circuit(
	rf_rdata1,	// read data output 1
	rf_rdata2,	// read data output 2
	clock,	
	rf_wdata,	// write data input
	rf_waddr,	// write address
	rf_raddr1,	// read address 1
	rf_raddr2,	// read address 2
	rf_write	// write enable
	);			

// Clock signal
initial clock = 0;
always #1 clock = ~clock;

// Generating signals to the circuits

initial 
	begin
	rf_wdata = 9;
	rf_raddr1 = 0;
	rf_raddr2 = 1;
	rf_waddr = 1;
	rf_write = 0;
	#4
	rf_write = 1;
	#2
	rf_write = 0;
	#4
	rf_wdata = 7;
	rf_raddr1 = 6;
	rf_raddr2 = 1;
	rf_waddr = 6;
	rf_write = 0;
	#4
	rf_write = 1;
	#2
	rf_write = 0;
	#4
	rf_raddr2=0;
	#4
	rf_waddr=0;
	#4
	rf_write=1;
	#2
	rf_write=0;
	#4
	$finish;
		
	end

initial
	$monitor("Read1[%b]=%b Read2[%b]=%b Write[%b]=%b write=%b clock=%b",
		rf_raddr1,
		rf_rdata1,
		rf_raddr2,
		rf_rdata2,
		rf_waddr,
		rf_wdata,
		rf_write,
		clock
		);
endmodule