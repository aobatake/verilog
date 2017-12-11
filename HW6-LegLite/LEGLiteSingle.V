// EE 361
// LEGLite Single Cycle
// 
// Obviously, it's incomplete.  Just the ports are defined.
//

module LEGLiteSingle(
	iaddr,		// Program memory address.  This is the program counter
	daddr,		// Data memory address
	dwrite,		// Data memory write enable
	dread,		// Data memory read enable
	dwdata,		// Data memory write output
	alu_out,	// Output of alu for debugging purposes
	clock,
	idata,		// Program memory output, which is the current instruction
	ddata,		// Data memory output (input to regfile)
	reset
	);

output [15:0] iaddr;
output [15:0] daddr;
output dwrite;
output dread;
output [15:0] dwdata;
output [15:0] alu_out;
input clock;
input [15:0] idata; // Instructions 
input [15:0] ddata;	
input reset;

wire [2:0] opcode;
wire alu_zero;
wire [15:0]rdata1;
wire [15:0]rdata2;
wire [15:0]alu_mux_out;
wire [15:0]extended;
wire [3:0] rreg2;
wire [15:0]write_mux;
	
wire reg2loc;
wire branch;
wire memread;
wire memtoreg;
wire [2:0] alu_select;
wire memwrite;
wire regwrite;

wire pc;

assign dwrite = memwrite;
assign dread = memread;
assign dwdata = rdata2;


PCLogic PC_Circuit(
                        // Outputs
        iaddr,    // Program counter (pc)
                        // Inputs
        clock,
        extended[15:0],    //   sign extension from 7 bit constant
        branch,    //   CBZ instruction
        alu_zero,    //   zero from ALU, used in cond branch
        reset        //   reset input
        );

Control Control_Circuit(
		reg2loc,
		branch,
		memread,
		memtoreg,
		alu_select[2:0],
		memwrite,
		alusrc,
		regwrite,
		idata[15:13] //opcode input
		);
		

ALU ALU_Circuit(
    	daddr[15:0],      // 16-bit output from the ALU
    	alu_zero, // equals 1 if the result is 0, and 0 otherwise
        rdata1[15:0],     // data input
        alu_mux_out[15:0],     // data input
        alu_select[2:0]       // 3-bit select
        );

MUX2_3 Reg2_Mux(
        rreg2[2:0],   // Output of multiplexer
        idata[12:10],  // Input 0
        idata[2:0],  // Input 1
        reg2loc    // 1-bit select
        );	
        
MUX2 ALU_Mux(
        alu_mux_out[15:0],
        rdata2[15:0],
        extended[15:0],
        alusrc
        );

MUX2 Write_Mux(
        write_mux[15:0],
        daddr[15:0],
        ddata[15:0],
        memtoreg
        );

RegFile RegFile_Circuit(
        rdata1[15:0],  // read data output 1
        rdata2[15:0],  // read data output 2
        clock,
        write_mux[15:0],   // write data input
        idata[2:0],   // write regsiter
        idata[5:3],  // read reg 1
        rreg2[2:0],  // read reg 2
        regwrite    // write enable
        );
        
SignExt SignExtend(
        extended[15:0],
        idata[12:6]
        );

endmodule
