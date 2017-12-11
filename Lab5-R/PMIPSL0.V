/*
** Authors: Brylian Foronda, John Barret
** Date: November 28, 2012
** Fall 2012, EE 361L Final Lab Project
** Pipeline MIPS Lite
*/

module PMIPSL0(
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
   
// PMIPS Outputs
output [15:0] imemaddr;    // 16-Bit Register for Instruction Memory (PC)
output [15:0] dmemaddr;    // DMem Address, calculated using ALU Results (EXMEM Stage)
output [15:0] dmemwdata;   // DMem Data, read data from data memory
output [15:0] aluresult;   
output dmemwrite;	         // DMem Write enable
output dmemread;	         // DMem Read enable

// PMIPS Inputs
input [16:0] imemrdata;	   // 17-bit Instructions
input [15:0] dmemrdata;
input clock;
input reset; 

// 16-bit Debug Probes
output [15:0] probe1, probe2, probe3;


// ***** Variables at each stage of the pipeline *****


//     --- Variables in IF stage and PC logic ---

reg	[31:0] PC; 
wire 	[31:0] PCPlus2;

 //    --- Variables in the IF/ID pipeline register ---
reg [16:0] IFIDInstr; 
reg [15:0] IFIDPCPlus2;
wire [3:0] IFIDOpcode;
wire [2:0] IFIDReadAddr1;
wire [2:0] IFIDReadAddr2;
wire [2:0] IFIDReadAddr3;
wire [6:0] IFIDConst;

//     --- Variables in the ID stage ---

wire [15:0] IDJumpAddr;				// Calculated Jump Address
wire [15:0] IDReadData1; 			// Register file outputs ($rs)
wire [15:0] IDReadData2;			// $rt

wire [15:0] IDSignExt; 				// Sign extension

wire negclock;

// Variables from the controller
wire [1:0] PCControl;	// Control signals to the PC logic
wire RegWrite;
wire RegDst;
wire [2:0] ALUSelect;
wire ALUSrc;
wire Branch;
wire Jump;
wire MemWrite;
wire MemRead;
wire MemtoReg;

 //  --- Variables in the ID/EX pipeline register ---

reg [15:0] IDEXPCPlus2; 
reg [15:0] IDEXReadData1;
reg [15:0] IDEXReadData2;
reg [2:0] IDEXReadAddr2;
reg [2:0] IDEXReadAddr3;
reg [15:0] IDEXSignExtend;
reg [2:0] IDEXALUSelect;
reg [15:0] IDEXJumpAddr;
reg IDEXALUSrc;
reg IDEXRegDst;
reg IDEXJump;
reg IDEXBranch;
reg IDEXMemRead;
reg IDEXMemtoReg;
reg IDEXMemWrite;
reg IDEXRegWrite;

//   --- Variables in the EX stage ---
wire [15:0] EXALUSrc;
wire [15:0] EXALUOut;
wire EXALUZero;

wire [15:0] EXBranchAddr;
wire [2:0] EXWriteAddr;

//   --- Variables in the EX/MEM pipeline register ---
reg [15:0] EXMEMALUOut;
reg EXMEMALUZero;
reg [15:0] EXMEMBranchAddr;
reg EXMEMBranch;
reg EXMEMRegWrite;
reg EXMEMJump;
reg EXMEMMemWrite;
reg EXMEMMemRead;
reg EXMEMMemtoReg;
reg [15:0] EXMEMReadData2;
reg [2:0] EXMEMWriteAddr;
reg [15:0] EXMEMJumpAddr;
reg [15:0] EXMEMPCPlus2;

//   --- Variables in the MEM stage ---
wire MEMBranch;

//   --- Variables in the MEM/WB pipeline register ---
reg [15:0] MEMWBMemRead;
reg [2:0] MEMWBWriteAddr;
reg [15:0] MEMWBALUOut;
reg MEMWBRegWrite;
reg MEMWBMemtoReg;

//   --- Variables in the WB stage ---
wire [15:0] WBData;

// ***** Logic at each stage of the pipeline *****

//---- IF Stage and PC logic --------------------
assign PCPlus2 = PC + 2; // This is the adder circuit near the PC

always @(posedge clock)
	begin
	if (reset==1) 	PC <= 0;
	else if (PCControl == 0) PC <= PC;
	else if (PCControl == 1) PC <= PCPlus2;
	else if (PCControl == 2)
		begin
			if(MEMBranch == 1)
				PC <= EXMEMBranchAddr;
			else if (EXMEMJump == 1)
				PC <= EXMEMJumpAddr;
			else
				PC <= PC;
		end
	end

assign imemaddr = PC; // PC = instruction memory address

always @(posedge clock)
	begin
	if (reset == 1)
		begin
		IFIDInstr <= 0;
		IFIDPCPlus2 <= 0;
		end
	else
		begin
		IFIDPCPlus2 <= PCPlus2;
		IFIDInstr <= imemrdata;
		end
	end

// Breaks up instruction
assign IFIDOpcode = IFIDInstr[16:13];
assign IFIDReadAddr1 = IFIDInstr[12:10];
assign IFIDReadAddr2 = IFIDInstr[9:7];
assign IFIDReadAddr3 = IFIDInstr[6:4];
assign IFIDConst = IFIDInstr[6:0];

//--- ID Stage ----------

assign negclock = ~clock;  // Reg file is synchronized
						   // to pos clock edge, so we
						   // supply inverted clock
						   // signal to the reg file.

 RegFile RegFile(
 	IDReadData1,		// read data output 1
	IDReadData2,		// read data output 2
	negclock,		
	WBData,				// write data input
	MEMWBWriteAddr,	// write address
	IFIDReadAddr1,		// read address 1
	IFIDReadAddr2,		// read address 2
	MEMWBRegWrite,
	reset
	);			

assign IDSignExt = {{9{IFIDInstr[6]}},IFIDInstr[6:0]};
assign IDJumpAddr = {IFIDPCPlus2[15:14],IFIDInstr[12:0]<<1};

Control Control(
	PCControl,					
	RegWrite,
	RegDst,
	ALUSrc,
	ALUSelect,
	Branch,
	Jump,
	MemWrite,
	MemRead,
	MemtoReg,
	clock,			
	IFIDOpcode,	// from the IFID pipeline register
	reset
	);

//---- ID/EX Pipeline Register --------

always @(posedge clock)
	begin
	IDEXPCPlus2 <= IFIDPCPlus2;	   
	IDEXReadData1 <= IDReadData1;		// Register value 1 $rs
	IDEXReadData2 <= IDReadData2;		// Register value 2 $rt
	IDEXSignExtend <= IDSignExt;	   // 16-bit Sign Ext constant
	IDEXALUSelect <= ALUSelect;	   // 3-bit ALU Select, determines ALU operation
	IDEXReadAddr2 <= IFIDReadAddr2;  // 3-bit Read/Write Address $rt
	IDEXReadAddr3 <= IFIDReadAddr3;  // 3-bit Read/Write Address $rd
	IDEXBranch <= Branch;
	IDEXJump <= Jump;
	IDEXALUSrc <= ALUSrc;
	IDEXRegDst <= RegDst;
	IDEXRegWrite <= RegWrite;
	IDEXMemWrite <= MemWrite;
	IDEXMemRead <= MemRead;
	IDEXMemWrite <= MemWrite;
	IDEXMemtoReg <= MemtoReg;
	IDEXJumpAddr <= IDJumpAddr;
	end


//---- EX Stage --------

MUX2S RegDstMux(
	EXWriteAddr,		// 3-bit Write Address
	IDEXReadAddr2,	   // $rt
	IDEXReadAddr3,	   // $rd
	IDEXRegDst			// RegDst Mux 0:$rt, 1:$rd
	);

MUX2 ALUMux(
	EXALUSrc,			// 16-bit Data output depending on ALUSrc value	
	IDEXReadData2,	   // Data from $rt
	IDEXSignExtend,	// Sign Extended constant
	IDEXALUSrc			// ALUSrc 0:$rt, 1:SignExt constant
	);	

ALU ALU(
	EXALUOut,			// 16-bit output from the ALU
	EXALUZero,			// equals 1 if the result is 0, and 0 otherwise
	IDEXReadData1,	   // data input
	EXALUSrc,			// data input
	IDEXALUSelect		// 3-bit select
	);		

assign aluresult = EXALUOut; // Connect the alu with the outside world
assign EXBranchAddr = (IDEXSignExtend << 1) + IDEXPCPlus2; // Calculate branch address

//------ EX/MEM pipeline register ---

always @(posedge clock)
 	begin
	EXMEMALUOut <= EXALUOut;
	EXMEMALUZero <= EXALUZero;
	EXMEMMemtoReg <= IDEXMemtoReg;
	EXMEMMemRead <= IDEXMemRead;
	EXMEMMemWrite <= IDEXMemWrite;
	EXMEMJump <= IDEXJump;
	EXMEMRegWrite <= IDEXRegWrite;
	EXMEMBranch <= IDEXBranch;
	EXMEMBranchAddr <= EXBranchAddr;
	EXMEMReadData2 <= IDEXReadData2;
	EXMEMWriteAddr <= EXWriteAddr;
	EXMEMJumpAddr <= IDEXJumpAddr;
	EXMEMPCPlus2 <= IDEXPCPlus2;
	end


//------- MEM Stage ----------------

// And Operation to determine if BEQ
assign MEMBranch = (EXMEMBranch&EXMEMALUZero);

// Assign PMIPS Outputs
assign dmemaddr = EXMEMALUOut;
assign dmemwdata = EXMEMReadData2;
assign dmemwrite = EXMEMMemWrite;	
assign dmemread = EXMEMMemRead;		

//------- MEM/WB pipeline register ----

always @(posedge clock)
 	begin
	MEMWBMemRead <= dmemrdata;
	MEMWBALUOut <= EXMEMALUOut;
	MEMWBWriteAddr <= EXMEMWriteAddr;
	MEMWBMemtoReg <= EXMEMMemtoReg;
	MEMWBRegWrite <= EXMEMRegWrite;
	end

//------- WB Stage ------------------
MUX2 wbmux( // ALU multiplexer
	WBData,		
	MEMWBALUOut,
	MEMWBMemRead,		
	MEMWBMemtoReg		
	);	

// Assign debug probes
assign probe1 = MEMBranch;
assign probe2 = EXMEMJump;
assign probe3 = WBData;

endmodule
