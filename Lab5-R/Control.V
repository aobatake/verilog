// EE 361 Controller file for PMIPSL0
// 
// This includes Controller, which is incomplete.  It is
// a sequential circuit
//
// Notice that the ports in module are listed
// as follows:  output ports, clock (if any),
// then input ports.
// This helps to keep things straight, especially
// when modules are instatiated in other
// modules.  This convention is used throughout
// all my examples.
//

module Control(
	PCControl,  // Control signals to PC circuitry
	RegWrite,   // Enable Register Write?
	RegDst,     // Choose Register Write Address (0:$rt, 1:$rd)
	ALUSrc,     // Choose ALU Source (0: Read Data 2, 1: SignExt)
	ALUSelect, 	// Select to the ALU
	Branch,		// Enable Branch?	
	Jump,       // Enable Jump?
	MemWrite,   // Enable MemWrite?
	MemRead,    // Enable MemRead?
	MemtoReg,   // Choose Which Data to Write to Register (0: ALUResult, 1: DM Read data)
	clock,	   // Clock input signal
	OpCode,	   // Opcode from the IF/ID pipeline register
	reset		   // Used to clear controller
	);

output [1:0] PCControl;		
output RegWrite;
output RegDst;
output ALUSrc;
output [2:0] ALUSelect;
output Branch;
output Jump;
output MemWrite;
output MemRead;
output MemtoReg;
input  clock;
input  [3:0] OpCode;		
input  reset;		

reg [1:0] PCControl;
reg RegWrite;
reg RegDst;
reg ALUSrc;
reg [2:0] ALUSelect;
reg Branch;
reg Jump;
reg MemWrite;
reg MemRead;
reg MemtoReg;

// The controller is sequential circuit with four states.
// It starts at state 0 and proceeds to states 1, 2, and 3. Then
// it goes back to state 0.  It's basically a 2-bit counter

reg [1:0] state;	

always @(posedge clock)  // Update state
	begin
	if (reset == 1) state <= 0;
	else
		case(state)
			0: state <= 1;
			1: state <= 2;
			2: state <= 3;
			default: state <= 0;
		endcase
	end

// The output of the Controller will depend on the state.
//
// State 0:  Instruction Fetch
//			o  Increment PC
//			o  Insert bubble into the pipeline at the
//				ID/EX register
//			* Note: At the end of this clock period
//				the instruction is in the IF/ID register
//				and PC is incremented by 2
// State 1:  Instruction Decode
//			o  Stall PC
//			o  Set outputs of the controller depending
//				on the opcode field from IF/ID register
//			* Note:  At the end of this clock period
//				the control signals are in the ID/EX reg
// State 2:  Execute
//			o  Stall PC
//			o  Insert bubble into the pipeline at the
//				ID/EX register
//			* Note:  At the end of this clock period
//				the control signals are in the EX/MEM reg
//				Also in the EX/MEM reg is the branch
//				target address, jump address, ALU output,
//				and ALUzero.
// State 3:  Memory access
//			o Stall PC (but allow the PC to load in case
//				of a branch or jump).  This is referred to
//				as Conditional Load
//			o Insert bubble into the pipeline at the
//				ID/EX reg
//
// We partition the control outputs into two sets:
//	(i) controlling	the PC and (ii) controlling the rest of 
//	the datapath.  This is
//	implemented with two "always" statements.
//

// The next always statement controls the PC.  It assumes
// that the PC can
//
//	o Stall, which means it holds its value
//	o Inc, which means PC = PC+2
//	o CondLoad (Conditional Load), which means 
//		PC = 	jump address, if the instruction is jump
//			branch address, if instr is branch taken
//			PC holds value, otherwise
//
//  Note that Inc occurs at state 0, Stall occurs in states
//  1 and 2, and CondLoad occurs in state 3.
//
// The PC should have a control input PCControl connected to
// the Controller that allows the Controller to affect a Stall,
// Inc, or CondLoad.  We use the following encoding:
//
//   PCControl 	= 0, for Stall
//			= 1, for Inc
//			= 2, for CondLoad
//
// This implies that PC must have circuitry that 
// will respond to the PCControl signals from the Controller.
// The PC must also have access to the jump address and target
// branch address that come from the Memory Access stage.
// In addition, the Memory Access stage must provide to the
// PC circuitry signals indicating whether a jump will be taken
// or a branch will be taken.
//
always @(state)
	case (state)
		0: PCControl = 1;
		1: PCControl = 0;
		2: PCControl = 0;
		3: PCControl = 2;
	endcase

// This "always" statement takes care of the rest of the
// control outputs.  Note that state 1 has outputs that
// that depend on the opcode, but all other states insert
// bubbles into the pipeline.
always @(state)
	begin 
	if (state == 1)// Instruction Decode
		begin
		case(OpCode)
		0:			// add instruction (R-Type)
			begin
				RegDst = 1;    // Pick third reg field for dest reg
				Jump = 0;      // Disable jump
				Branch = 0;    // Disable branch
				MemRead = 0;   // Disable memory
				MemtoReg = 0;  // Select ALU to write to memory
				ALUSelect = 0; // Have ALU do an ADD
				MemWrite = 0;  // Disable memory
				ALUSrc = 0;    // Select register for input to ALU
				RegWrite = 1;  // Write result back to register file
			end
		1:			// subtract instruction (R-Type)
			begin
				RegDst = 1;			// Use $rd for destination register
				Jump = 0;			// Disable jump
				Branch = 0;			// Disable brannch
				MemRead = 0;		// Disable memory read
				MemtoReg = 0;		// Use ALU Result to Write Data to Register 
				ALUSelect = 1;	// Have ALU do a SUBSTRACT
				MemWrite = 0;		// Disaable memory write
				ALUSrc = 0;			// Select $rt for ALU input
				RegWrite = 1;		// Write result back to register $rd
			end
		2:			// slt instruction (R-Type)
			begin
				RegDst = 1;			// Use $rd for destination register
				Jump = 0;			// Disable jump
				Branch = 0;			// Disable branch
				MemRead = 0;		// Disable memory read
				MemtoReg = 0;		// Use ALU result to write data to register 
				ALUSelect = 2;	// Have ALU do an SLT 
				MemWrite = 0;		// Disable memory write
				ALUSrc = 0;			// Select $rt for ALU input
				RegWrite = 1;		// Write either a 1 or 0 back to register $rd
			end
		3: 		// lw instruction (I-Type)
			begin
				RegDst = 0;			// Use $rt for destination register
				Jump = 0;			// Disable jump
				Branch = 0;			// Disable branch
				MemRead = 1;		// Read value from calculated address
				MemtoReg = 1;		// Read data from memory and store to Register
				ALUSelect = 0;	// Have ALU calculate he address ($rs + SignExtend)
				MemWrite = 0;		// Not writing to memory
				ALUSrc = 1;			// Use Sign Extend for ALU input
				RegWrite = 1;		// Write result back to register $rt
			end
		4:			// sw instruction (I-Type)
			begin
				RegDst = 0;			// We are not writing to register, value does not matter
				Jump = 0;			// Disable jump
				Branch = 0;			// Disable branch
				MemRead = 0;		// Disable memory read
				MemtoReg = 0;		// Doesn't matter, not writing to register
				ALUSelect = 0;	// Have ALU calculate the address to write to ($rs + SignExtend)
				MemWrite = 1;		// Use value of $rt to write memory data
				ALUSrc = 1;			// Use signext for calculating memory address
				RegWrite = 0;		// Disable register write
			end
		5:			// beq instruction (I-Type)
			begin
				RegDst = 0;			// Doesn't matter, not writing to register
				Jump = 0;			// Disable jump
				Branch = 1;			// Enable branch
				MemRead = 0;		// Disable memory read
				MemtoReg = 0;		// Disable, not writing to register
				ALUSelect = 1;	// Have ALU subtract to determine if equal
				MemWrite = 0;		// Disable memory write
				ALUSrc = 0;			// Use value of $rt to compare with $rs
				RegWrite = 0;		// Disable register write
			end
		6: 		// addi instruction (I-Type)
			begin
				RegDst = 0;			// Use $rt for destination register
				Jump = 0;			// Disable jump
				Branch = 0;			// Disable branch
				MemRead = 0;		// Disable memory read
				MemtoReg = 0;		// Use ALU result to write data to register $rt
				ALUSelect = 0;	// Have ALU do an add operation
				MemWrite = 0;		// Not writing to memory
				ALUSrc = 1;			// Use Sign Extend as ALU input
				RegWrite = 1;		// Write ALU result to register $rt
			end
		7:			// andi instruction (I-Type)
			begin
				RegDst = 0;			// Use $rt for destination register
				Jump = 0;			// Disable jump
				Branch = 0;			// Disable branch
				MemRead = 0;		// Disable memory read
				MemtoReg = 0;		// Use ALU result to write data to register $rt
				ALUSelect = 4;	// Use ALU to do an AND operation
				MemWrite = 0;		// Not writing to memory
				ALUSrc = 1;			// Use Sign Extend as ALU input
				RegWrite = 1;		// Write ALU result to register $rt
			end
		8:			// j instruction (J-Type)
			begin 
				// Values don't matter if jump is enabled
				RegDst = 0;
				Jump = 1;
				Branch = 0;
				MemtoReg = 0;
				ALUSelect = 0;
				MemWrite = 0;
				ALUSrc = 0;
				RegWrite = 0;
			end
		9: 		// jal instruction (J-Type)
			begin
				RegDst = 0;
				Jump = 1;
				Branch = 0;
				MemtoReg = 0;
				ALUSelect = 0;
				MemWrite = 0;
				ALUSrc = 0;
				RegWrite = 0;
			end
		10: 		// ret instruction (J-Type)
			begin
				RegDst = 0;
				Jump = 1;
				Branch = 0;
				MemtoReg = 0;
				ALUSelect = 0;
				MemWrite = 0;
				ALUSrc = 0;
				RegWrite = 0;
			end
		default:			
			begin
				RegDst = 0;
				Jump = 0;
				Branch = 0;
				MemtoReg = 0;
				ALUSelect = 0;
				MemWrite = 0;
				ALUSrc = 0;
				RegWrite = 0;
			end
		endcase
	end

	else // Insert bubble for all other states
		begin
		RegWrite = 0;
		RegDst = 0;
		ALUSrc = 0;
		ALUSelect = 0;
		Branch = 0;
		Jump = 0;
		MemWrite = 0;
		MemRead = 0;
		MemtoReg = 0;
		end
	end
	
endmodule
