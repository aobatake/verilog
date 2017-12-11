

module lights;

reg clock;
reg [3:0] Light;
reg [2:0] State = 0;

initial clock = 1;
always #1 clock=~clock;

always @(posedge clock)
	begin
		case(State)
		0: Light <= 'b0001;
		1: Light <= 'b0010;
		2: Light <= 'b0100;
		3: Light <= 'b1000;
		4: Light <= 'b0100;
		5: Light <= 'b0010; 
		endcase	

		$display("LED Output = %b", Light);	
		if(State != 5) State = State + 1;
		else State = 0;
	end

endmodule
