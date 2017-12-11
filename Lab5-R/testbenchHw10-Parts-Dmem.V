// EE 361 Hw 9 Testbench for sequential circuit Parts
// * 128 word data memory and IO

module testbench;

reg clock;

wire [15:0] dm_rdata;
wire [6:0] io_display;
reg [15:0] dm_addr;
reg [15:0] dm_wdata;
reg dm_write;
reg dm_read;
reg io_sw0;
reg io_sw1;

// Instantiation
DMemory_IO DMem_Circuit(
	dm_rdata,	// read data
	io_display,	// IO port connected to 7 segment display
	clock,		// clock
	dm_addr,	// address
	dm_wdata,	// write data
	dm_write,	// write enable
	dm_read,	// read enable
	io_sw0,		// IO port connected to sliding switch 0
	io_sw1		// IO port connected to sliding switch 1
	);


// Clock signal
initial clock = 0;
always #1 clock = ~clock;

initial
	begin
	dm_addr=6;
	dm_wdata=5;
	dm_write=0;
	dm_read=0;
	io_sw0=0;
	io_sw1=1;
	#4
	dm_write=1;
	dm_read=1;
	#2
	dm_write=0;
	#2
	dm_read=0;
	#2
	dm_read=1;
	#4
	dm_wdata=8;
	dm_addr=22;
	#4
	dm_write=1;
	#2
	dm_write=0;
	#4
	dm_addr=16'hfffa;
	dm_wdata=14;
	#4
	dm_write=1;
	#2
	dm_write=0;
	#4
	dm_addr=16'hfff0;
	#4
	io_sw0=1;
	io_sw1=0;
	#4
	$finish;
	end

initial
	begin
	$display("Adr=address Rd=Read Wr=Write we=write enable, re = read enable");
	$monitor("Adr=%b Rd=%b Wr=%b we=%b re=%b dsp[%b] sw[%b,%b] clk=%b",
		dm_addr,
		dm_rdata,
		dm_wdata,
		dm_write,
		dm_read,
		io_display,
		io_sw1,
		io_sw0,
		clock
		);
	end



endmodule