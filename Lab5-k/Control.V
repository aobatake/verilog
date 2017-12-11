//
// The control module for LEGLite
//   The control will input the opcode value (3 bits)
//   then determine what the control signals should be
//   in the datapath
// 
//---------------------------------------------------------------
module Control(
        state,
		reg2loc,
		branch,
		memread,
		memtoreg,
		alu_select,
		memwrite,
		alusrc,
		regwrite,
		opcode,
		clock,
		reset
		);

input [1:0] state;
output reg2loc;
output branch;
output memread;
output memtoreg;
output [2:0] alu_select; // Select to the ALU
output memwrite;
output alusrc;
output regwrite;
input [2:0] opcode;
input clock;
input reset;

wire [1:0] state;
reg reg2loc;
reg branch;
reg memread;
reg memtoreg;
reg [2:0] alu_select;
reg memwrite;
reg alusrc;
reg regwrite;

always @(state or posedge clock)
    begin
    case (state)
    0:
        begin
        reg2loc = 0;
        branch = 0;
        memread = 0;
        memtoreg = 0;
        regwrite = 0;
        alusrc = 0;
        end
    1:
        begin
        case(opcode)
        0:			// ADD instruction
            begin
            reg2loc = 0;
            branch = 0;    // Disable branch
            memread = 0;   // Disable memory
            memtoreg = 1;  // Select ALU to write to memory
            alu_select = 3'b000; // Have ALU do an ADD
            memwrite = 0;  // Disable memory
            alusrc = 0;    // Select register for input to ALU
            regwrite = 1;  // Write result back to register file
            end

        1:          // SUB instruction
            begin
            reg2loc = 0;   // Pick 2nd reg field
            branch = 0;    // Disable branch
            memread = 0;   // Disable memory
            memtoreg = 0;  // Select ALU to write to register
            alu_select = 2'b01; // Have ALU do SUB
            memwrite = 0;  // Disable memory
            alusrc = 0;    // Select register for input to ALU
            regwrite = 1;  // Write result back to register file
            end

        3:          //LDUR
            begin
            reg2loc = 1;
            branch = 0;
            memread = 1;
            memtoreg = 1;
            alu_select = 3'b000;
            memwrite = 1;
            alusrc = 1;
            regwrite = 1;
            end
        
        4:          //STUR
            begin
            branch = 0;
            memread = 0;
            memtoreg = 0;
            alu_select = 3'b000;
            memwrite = 1;
            alusrc = 1;
            regwrite = 0;
            end
            
        5:          //CBZ Instructions
            begin
            reg2loc = 1;
            branch = 1;
            memread = 0;
            memtoreg = 0;
            alu_select = 3'b010;
            memwrite = 0;
            alusrc = 0;
            regwrite = 0;
            end

        6:          //ADDI instructions
            begin
            reg2loc = 0;
            branch = 0;
            memread = 0;
            memtoreg = 0;
            alu_select = 3'b000;
            memwrite = 0;
            alusrc = 1;
            regwrite = 1;
            end
            
        
        7:           //ANDI
            begin
            reg2loc = 0;
            branch = 0;
            memread = 0;
            memtoreg = 1;
            alu_select = 3'b100;
            memwrite = 0;
            alusrc = 1;
            regwrite = 1;
            end
            
            
        default:  // Note that default is unnecessary if all case 
                //    values are considered
            begin
            branch = 0;    // Disable branch
            memread = 0;   
            memtoreg = 0;  
            alu_select = 3'b000; 
            memwrite = 0;  // Disable memory
            alusrc = 0;    
            regwrite = 0;  // Disable regiter file
            end
        endcase
        end
    2:
        begin
            reg2loc = 0;
            branch = 0;
            memread = 0;
            memtoreg = 0;
            regwrite = 0;
            memwrite = 0;
            alusrc = 0;
        end
    3:
        begin
            reg2loc = 0;
            branch = 0;
            memread = 0;
            memtoreg = 0;
            regwrite = 0;
            memwrite = 0;
            alusrc = 0;
        end
    default:
        begin
            reg2loc = 0;
            branch = 0;
            memread = 0;
            memtoreg = 0;
            regwrite = 0;
            memwrite = 0;
            alusrc = 0;
        end
    endcase

    //$display("memread: %b", memread);
    end
    
endmodule