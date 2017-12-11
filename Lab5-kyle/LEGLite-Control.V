// EE 361
// LEGLite
//
// The control module for LEGLite
//   The control will input the opcode value (3 bits)
//   then determine what the control signals should be
//   in the datapath
//
//---------------------------------------------------------------
module Control(
        PCControl,
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

output reg2loc;
input [1:0] PCControl;
output branch;
output memread;
output memtoreg;
output [2:0] alu_select; // Select to the ALU
output memwrite;
output alusrc;
output regwrite;
input  [2:0] opcode;
input clock;
input reset;

reg reg2loc;
wire [1:0] PCControl;
reg branch;
reg memread;
reg memtoreg;
reg [2:0] alu_select;
reg memwrite;
reg alusrc;
reg regwrite;


always @(PCControl)
    begin
    case (PCControl)
    0:
        begin
        branch = 0;
        memread = 0;
        memtoreg = 0;
        regwrite = 0;
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
        6:          //TODO: ADDI instructions
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
        5:          //TODO: CBZ Instructions
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

        3:          //LD
            begin
            branch = 0;
            memread = 1;
            memtoreg = 1;
            alu_select = 3'b000;
            memwrite = 0;
            alusrc = 1;
            regwrite = 1;
            end

        4:
            begin
            branch = 0;
            memread = 0;
            memtoreg = 0;
            alu_select = 3'b000;
            memwrite = 1;
            alusrc = 1;
            regwrite = 0;
            end

        7:
            begin
            branch = 0;
            memread = 0;
            memtoreg = 0;
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
            branch = 0;
            memread = 0;
            memtoreg = 0;
            regwrite = 0;
            memwrite = 0;
        end
    3:
        begin
            branch = 0;
            memread = 0;
            memtoreg = 0;
            regwrite = 0;
            memwrite = 0;
        end
    default:
        begin
            branch = 0;
            memread = 0;
            memtoreg = 0;
            regwrite = 0;
            memwrite = 0;
        end
    endcase
    end
endmodule
