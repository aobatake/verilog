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
	reset,		// Reset
	PCControl
	);

output [15:0] imemaddr;
output [15:0] dmemaddr;
output [15:0] dmemwdata;
output dmemwrite;
output dmemread;
output [15:0] aluresult;
output [1:0] PCControl;
input clock;
input [15:0] imemrdata;
input [15:0] dmemrdata;
input reset;
wire [15:0] imemaddr;
wire [15:0] dmemaddr;
reg [15:0] dmemwdata;
reg dmemwrite;
reg dmemread;
wire [15:0] aluresult;

// ***** Variables at each stage of the pipeline *****
//
//     --- Variables in IF stage and PC logic ---

reg	[31:0] PC;
reg [15:0] PCTemp;
wire [31:0] PCTempSignExt;
wire [31:0] PCPlus2;

 //    --- Variables in the IF/ID pipeline register ---
reg [15:0] IFIDInstr;
reg [15:0] IFIDPCPlus2;
wire [2:0] IFIDOpcode;
wire [2:0] IFIDRegfield1;
wire [2:0] IFIDRegfield2;
wire [2:0] IFIDRegfield3;
wire [6:0] IFIDConst;
wire [2:0] IFIDwaddr;

    //     --- Variables in the ID stage ---
wire [15:0] rdata1; // Variables connected to reg file
wire [15:0] rdata2;
wire [15:0] wdata;
wire [15:0] IDSignExt; // Sign extension
wire [2:0] readreg2;
wire ALUSrc;

// Variables from the controller
reg [1:0] PCControl;	// Control signals to the PC logic
wire RegWrite;
wire [2:0] ALU_Select;
wire Branch;
wire MemWrite;
wire MemRead;
wire MemtoReg;
wire reg2loc;

 //  --- Variables in the ID/EX pipeline register ---
reg [15:0] IDEXPCPlus2;
reg [15:0] IDEXRegRead1;
reg [15:0] IDEXRegRead2;
reg [15:0] IDEXInstr;
reg [15:0] IDEXSignExtend;
reg IDEXALUSrc;
reg [2:0] IDEXALU_Select;
reg IDEXRegWrite;
reg IDEXBranch;
reg IDEXMemWrite;
reg IDEXMemRead;
reg IDEXMemtoReg;
reg [3:0] IDEXOpcode;
reg [2:0] IDEXRegfield1;
reg [2:0] IDEXRegfield2;
reg [6:0] IDEXConst;
reg [2:0] IDEXwaddr;

//   --- Variables in the EX stage ---
wire [15:0] alusrc2;
wire [15:0] aluout1;
wire aluzero;
wire [15:0] branchaddr;

//   --- Variables in the EX/MEM pipeline register ---
reg [15:0] EXMEMALUOut;
reg EXMEMALUZero;
reg EXMEMRegWrite;
reg EXMEMBranch;
reg EXMEMMemWrite;
reg EXMEMMemRead;
reg EXMEMMemtoReg;
reg [15:0] EXMEMbranchaddr;
reg [15:0] EXMEMRegRead2;
reg [2:0] EXMEMwaddr;

//   --- Variables in the MEM stage ---
wire PCSrc;  //reg PCSrc

//   --- Variables in the MEM/WB pipeline register ---
reg [15:0] MEMWBdmemrdata;
reg [15:0] MEMWBdmemread;
reg MEMWBMemtoReg;
reg MEMWBRegWrite;
reg [15:0] MEMWBALUOut;
reg [2:0] MEMWBwaddr;

// ***** Logic at each stage of the pipeline *****

//---- IF Stage and PC logic --------------------
assign PCPlus2 = PC + 2; // This is the adder circuit near the PC
assign PCTempSignExt = {{16{EXMEMbranchaddr[15]}},EXMEMbranchaddr[15:0]};
always @(posedge clock)
	begin
	if (reset==1) begin
		PC <= 0;
		PCControl <= 0;
	end
	else if (PCControl == 0) begin
	 PC <= PCPlus2; // PC <= PCPlus2
	 	PCControl <= ( PCControl + 1 ) % 4;
	 end
	else if (PCControl == 3)
	   begin
		 	PCControl <= ( PCControl + 1 ) % 4;
	   if (PCSrc == 1) begin
		  PC <= PCTempSignExt;
			//PCControl <= 0;
			end
	   else PC <= PC;
	   end
	else begin
	 PC <= PC;
	 	PCControl <= ( PCControl + 1 ) % 4;
		end



	end

assign imemaddr = PC; // PC = instruction memory address

always @(posedge clock)
	begin
	IFIDInstr <= imemrdata;
	IFIDPCPlus2 <= PCPlus2;
	end


assign IFIDOpcode = imemrdata[15:13];
assign IFIDRegfield1 = imemrdata[5:3];
assign IFIDRegfield2 = imemrdata[12:10];
assign IFIDRegfield3 = imemrdata[2:0];
assign IFIDConst = imemrdata[12:6];
assign IFIDwaddr = imemrdata[2:0];

//--- ID Stage ----------


assign IDSignExt = {{9{IFIDConst[6]}},IFIDConst[6:0]};


Control control1(
    PCControl,
    reg2loc,
	Branch,
	MemRead,
	MemtoReg,
	ALU_Select,
	MemWrite,
	ALUSrc,
	RegWrite,
	IFIDOpcode,
	clock,
	reset
	);

MUX2_3 regmux(
    readreg2,
    IFIDRegfield2,
    IFIDRegfield3,
    reg2loc
    );



RegFile rfile1(
 	rdata1,			// read data output 1
	rdata2,			// read data output 2
	clock,
	wdata,			// write data input
	MEMWBwaddr,		// write address
	IFIDRegfield1,	// read address 1
	readreg2,      	// read address 2
	MEMWBRegWrite   // write enable
	);

//	always@(posedge clock)
//	$display("%b", wdata);
//---- ID/EX Pipeline Register --------


always @(posedge clock)
	begin
	IDEXPCPlus2 <= IFIDPCPlus2;
	IDEXRegRead1 <= rdata1;
	IDEXRegRead2 <= rdata2;
	IDEXInstr <= IFIDInstr;
	IDEXSignExtend <= IDSignExt;
	IDEXALU_Select <= ALU_Select;
	IDEXALUSrc <= ALUSrc;
    IDEXRegWrite <= RegWrite;
    IDEXBranch <= Branch;
    IDEXMemWrite <= MemWrite;
    IDEXMemRead <= MemRead;
    IDEXMemtoReg <= MemtoReg;
    IDEXOpcode <= IFIDOpcode;
    IDEXRegfield1 <= IFIDRegfield1;
    IDEXRegfield2 <= IFIDRegfield2;
    IDEXConst <= IFIDConst;
    IDEXwaddr <= IFIDwaddr;
	end


//---- EX Stage --------

MUX2 alumux( // ALU multiplexer
	alusrc2,
	IDEXRegRead2,
	IDEXSignExtend,
	IDEXALUSrc
	);

ALU alu1(
	aluout1,	// 16-bit output from the ALU
	aluzero,	// equals 1 if the result is 0, and 0 otherwise
	IDEXRegRead1,	// data input
	alusrc2,		// data input
	IDEXALU_Select		// 3-bit select, aluselect
	);

assign branchaddr = IDEXPCPlus2 + (IDEXSignExtend << 1) - 2;


assign aluresult = aluout1; // Connect the alu with the outside world

//------ EX/MEM pipeline register ---


always @(posedge clock)
 	begin
	EXMEMALUOut <= aluout1;
	EXMEMALUZero <= aluzero;
    EXMEMRegWrite <= IDEXRegWrite;
    EXMEMBranch <= IDEXBranch;
    EXMEMMemWrite <= IDEXMemWrite;
    EXMEMMemRead <= IDEXMemRead;
    EXMEMMemtoReg <= IDEXMemtoReg;
    EXMEMwaddr <= IDEXwaddr;
    EXMEMbranchaddr <= branchaddr;
    EXMEMRegRead2 <= IDEXRegRead2;
   	end


//------- MEM Stage ----------------
assign PCSrc = EXMEMBranch && EXMEMALUZero;
assign dmemaddr = EXMEMALUOut;

//------- MEM/WB pipeline register ----

always @(posedge clock)
    begin
    MEMWBRegWrite <= EXMEMRegWrite;
    MEMWBMemtoReg <= EXMEMMemtoReg;
    MEMWBdmemrdata <= dmemrdata;
    MEMWBALUOut <= EXMEMALUOut;
    MEMWBwaddr <= EXMEMwaddr;
    dmemread <= EXMEMMemRead;
    dmemwrite <= EXMEMMemWrite;
    dmemwdata <= EXMEMRegRead2;
    end

//------- WB Stage ------------------

MUX2 WB_Mux(
    wdata,
    MEMWBALUOut,
    MEMWBdmemrdata,
    MEMWBMemtoReg
);
endmodule
