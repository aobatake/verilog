// EE 361 Homework 7 Problem B
// 
// Name:  <Your First and Last Name>
// Date:  <Today's Date>

//--------------------------------------------------------------------------

// Transmitter circuit

module Transmitter(link,ready,clock,taddr,tdata,send,clear);

output link; // connected to the communication link
output ready; // indicates when it is ready to load a new packet
input clock;
input [1:0] taddr;
input [3:0] tdata;
input send;
input clear;  // clear input.  clears the state to 0.

reg [6:0] buffer; // packet to be transmitted

reg [2:0] state;  // state of the transmitter
   //  0 = waiting to transmit
   //  1 = transmitting start bit
   //  2 = transmitting bit 5
   //  3 = transmitting bit 4, 
   //    ...   etc
   //  7 = transmitting bit 0, last bit
				  
reg ready; // output indicating when the transmitter is ready
           //  Note that ready = 1 when state = 0 or state = 7,
           //  i.e., the circuit is waiting or is transmitting
           //  its last bit.
reg link;  // output of the Transmitter to the link




always @(posedge clock) // update state
   begin
   if (clear==1) state <= 0;
   else
      begin // This is what the circuit normally does
      if (state==0 || state==7) // ready to load a new packet
         begin
         if (send==1) state <= 1;
	     else state <= 0;
         end
      else state <= state+1; // Transmitting bits
      end
   end


// ready output indicates when waiting or transmitting the last bit
always @(state) 
   begin
   if (state==0 || state==7) ready = 1;
   else ready = 0;
   end
	

// Update buffer.  Normally the buffer shifts bits out.  But when
// ready = 1 and send = 1 then it loads a new packet.
always @(posedge clock) // update buffer
   begin
   if (ready==1 && send==1)
      buffer <= {1'b1,taddr,tdata}; // load new packet into buffer
   else buffer <= buffer << 1;   // shift the next bit out
   end

always @(state) // update output to link.  
   begin
   if (state==0) link = 0; // nothing to send
   else link = buffer[6];
   end



endmodule


//-------------------------------------------------------------------

// Receiver circuit

module Receiver(rcdata,new,clock,link,rcaddr,clear);

output [3:0] rcdata;
output new;
input clock;
input link;
input [1:0] rcaddr;
input clear;        // clear input.  clears state to 0

reg [2:0] state; // state of the receiver
   //  0 = waiting for the start bit
   //  1 = received start bit
   //  2 = received bit 5 [addr]
   //  3 = received bit 4 [addr]
   //  4 = received bit 3 [data]
   //  5 = received bit 2 [data]
   //  6 = received bit 1 [data], 
   //        and about to receive the last bit
   //  7 = received bit 0 [data], last bit

reg [5:0] buffer; // input buffer that shifts in packet from link.  
			      //    the last 6 bits received from the link

reg [3:0] rcdata; // connected to the output port
reg new;		  // connected to the output port


// Update the state counter.  Note a new packet can be received if
// state = 0 (receiver is idle) or state = 7 (receiver is receiving
// the last bit of the old packet.
always @(posedge clock) 
   begin
   if (clear==1) state <= 0;
   else
      begin
      if (state==0 || state==7) // ready to receive new packet
         begin
         if (link==1) state <=1; // if incoming bit is a start bit, go to state 1
         else state <= 0;        // else go to state 0
         end
      else state <= state+1;  // in the process of receiving a packet
      end	
   end


//  Shifts a bit from the link into the buffer

always @(posedge clock) buffer <= {buffer[4:0],link};
	
// When the circuit reaches state 7 (completely receives packet), it checks
// whether the packet has the address "rcaddr".  During state 7, the addr
// and data field of the packet is in the buffer.  In other words,
//
// buffer[5:0] = {addr[1:0],data[3:0]}
//
// I.e., during state 7, buffer[5:4] = addr and buffer[3:0] = data
//
// So during state 7, if buffer[5:4] == rcaddr (the receiver's address) then
// buffer[3:0] should be loaded into rcdata.  Also "new" should become "1" to
// indicate new data. 
//

always @(posedge clock) // update rcdata
   begin
   if (state==7 && buffer[5:4]==rcaddr) rcdata <= buffer[3:0];
   end

always @(posedge clock)
   begin
   if (state==7 && buffer[5:4]==rcaddr) new <= 1;
   else new <= 0;
   end

endmodule



//--------------------------------------------------------------------------

// Register file that has four 4-bit registers


module RegFile(rfdata,clock,waddr,rfaddr,wdata,write);

output [3:0] rfdata;  // read data
input clock;
input [1:0] waddr;  // write address
input [1:0] rfaddr; // read address
input [3:0] wdata;  // write data
input write;        // write enable


reg [3:0] regcell[0:3]; // Register array that's 4-bits wide

assign rfdata = regcell[rfaddr]; // Output read data

always @(posedge clock)  // Write to the register file
   if (write==1) regcell[waddr]=wdata;


endmodule



//-------------------------------------------------------------------------

// RfileReceiver circuit
// Your assignment is to design this module.  Delete the lines with
// prefix ***.  
//

module RfileReceiver(waddr,wdata,write,clock,link,clear);

output [1:0] waddr; // used to control register file
output [3:0] wdata; // used to tranfer data to register file
output write;	    // write enable to register file
input  clock;
input  link;	    // input from serial link from transmitter
input  clear;


	reg [2:0] state; // state of the receiver
   	//  0 = waiting for the start bit
   	//  1 = received start bit
   	//  2 = received bit 5 [addr]
   	//  3 = received bit 4 [addr]
   	//  4 = received bit 3 [data]
   	//  5 = received bit 2 [data]
   	//  6 = received bit 1 [data], 
   	//        and about to receive the last bit
   	//  7 = received bit 0 [data], last bit

	reg [1:0] waddr;
	reg [3:0] wdata;
	reg write;
	reg [5:0] buffer;
// Update the state counter.  Note a new packet can be received if
// state = 0 (receiver is idle) or state = 7 (receiver is receiving
// the last bit of the old packet.
always @(posedge clock) 
   begin
   if (clear==1) state <= 0;
   else
      begin
      if (state==0 || state==7) // ready to receive new packet
         begin
         if (link==1) state <= 1; // if incoming bit is a start bit, go to state 1
		else state <= 0;        // else go to state 0
		 end		
      else state <= state+1;  // in the process of receiving a packet
      end	
	end

always @(posedge clock) buffer <= {buffer[4:0],link};
	
always @(posedge clock) // update rcdata
   begin
   if (state==7) waddr <= buffer[5:4];
   end

always @(posedge clock)
   	begin
   	if (state == 7) wdata <= buffer[3:0];
 	if(state == 7) write <= 1;	
	end

endmodule
