//module responsible for resetting the others
module terminator
(
	reset,
	Bclkx16_,
	Rx_done,
	data,
	rst,
	dis
);

input reset;			//active low
input Bclkx16_;			//clock
input Rx_done;			//signal from control to store what is on the data input and reset all
input [0:7]data;		//data received from the register
output reg rst;				//the reset signal sent to the other modules : active low
output reg [0:7] dis;	//used to display the data received from th register and store it

always@(posedge Bclkx16_)
begin
	if(!reset)
	begin
	rst <= 1'b0;
	dis <= 8'b0;
	end
	
	else if(reset && Rx_done==1'b0)
	begin
	rst <= 1'b1;
	end
	
	else if(reset && Rx_done == 1'b1)
	begin
	dis = data;
	rst = 1'b1;
	end
end

endmodule