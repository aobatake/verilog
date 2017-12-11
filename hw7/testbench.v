
module testbench;

// Signals
reg clock;
reg clear;

// Signals to Transmitter
reg  [1:0] taddr; // address of packets being sent by transmitter
reg  [3:0] tdata; // data in packets sent by transmitter
reg  tsend;	     // send enable from transmitter
wire trdy; 		 // ready signal from transmitter

// Signals to Receiver
reg  [1:0] rcaddr; // receiver's address
wire [3:0] rcdata; // receiver's data
wire new;		   // indicates a new packet

// Signals to Register File
wire [3:0] rfdata; // data output from register file
wire [1:0] waddr;  // write address
reg  [1:0] rfaddr; // read address
wire [3:0] wdata;  // write data
wire write;		   // write enable


// Serial communication link
wire link; 

// Clock Signal Generator
initial begin
	clock = 0;
	end
always #1 clock=~clock; // Clock generator

// Instantiation of Circuits

Transmitter transmitter_circ(link,trdy,clock,taddr,tdata,tsend,clear);

Receiver receiver_circ(rcdata,new,clock,link,rcaddr,clear);

RegFile regfile_circ(rfdata,clock,waddr,rfaddr,wdata,write);

RfileReceiver RfileRec_circuit(waddr,wdata,write,clock,link,clear);

// Generating signals

// After clearing, the transmitter will transmit three packets.
// The first packet is addressed to the receiver circuit, which
// has address set to 10 and has data 0011
// The next two packets are transmitted one after another.
// The first of these is to address 11 with data 1000, and
// the second of these is to address 10 with data 0100.
// Subsequently there are two more packets that are transmitted,
// the first of these is to address 00 with data 1111,
// and the second is to address 01 with data 1010.
//
initial begin

	// Initialize 
	rfaddr = 2'b10;
	rcaddr = 2'b10; // Set Receiver address to 10
	clear = 1;		// Clear Transmitter, Receiver, and RfileReceiver
	#4
	clear=0;
	#10
	
	taddr = 2'b10;  // Send packet with data 0011 to the receiver
	tdata = 4'b0011;
	tsend = 1;
	$display("\nTransmitting Packet [%b,%b]",taddr,tdata);
	#2 tsend = 0;
	#18
	
	$display("\n*** Contents of Register File");
	rfaddr = 2'b00;
	#1 $display("Reg[%b]= %b",rfaddr,rfdata);
	rfaddr = 2'b01;
	#1 $display("Reg[%b]= %b",rfaddr,rfdata);
	rfaddr = 2'b10;
	#1 $display("Reg[%b]= %b",rfaddr,rfdata);
	rfaddr = 2'b11;
	#1 $display("Reg[%b]= %b",rfaddr,rfdata);
	#2
	taddr = 2'b11;  // Send a packet with data 1000 but to the wrong address 11
	tdata = 4'b1000;
	tsend = 1;
	$display("\nTransmitting Packet [%b,%b]",taddr,tdata);
	#2 tsend = 0;
	#6
	
	taddr = 2'b10;   // Send a packet with data 0100 to the receiver address 10
	tdata = 4'b0100; //   right after the previous one
	tsend = 1;
	$display("\nTransmitting Packet [%b,%b]",taddr,tdata);
	#12
	tsend = 0;

	#12

	taddr = 2'b00;   // Send a packet with data 0100 to the receiver address 10
	tdata = 4'b1111; //   right after the previous one
	tsend = 1;
	$display("\nTransmitting Packet [%b,%b]",taddr,tdata);
	#2
	tsend = 0;

	#20

	taddr = 2'b01;   // Send a packet with data 0100 to the receiver address 10
	tdata = 4'b1010; //   right after the previous one
	tsend = 1;
	$display("\nTransmitting Packet [%b,%b]",taddr,tdata);
	#2
	tsend = 0;
	#20				
	
	$display("\n*** Contents of Register File");
	rfaddr = 2'b00;
	#1 $display("Reg[%b]= %b",rfaddr,rfdata);
	rfaddr = 2'b01;
	#1 $display("Reg[%b]= %b",rfaddr,rfdata);
	rfaddr = 2'b10;
	#1 $display("Reg[%b]= %b",rfaddr,rfdata);
	rfaddr = 2'b11;
	#1 $display("Reg[%b]= %b",rfaddr,rfdata);
	
	$finish;
	end


initial begin
	$monitor("Trans[addr,data,send,rdy]=[%b,%b,%b,%b] clk=%b link=%b Recvr[addr,data,new=[%b,%b,%b]  ",
		taddr,tdata,tsend,trdy,
		clock,link,		
		rcaddr,rcdata,new
		);
	end
endmodule
