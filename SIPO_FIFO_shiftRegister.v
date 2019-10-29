//receiver shift register module

module sr(rx_err, d, clk, parity, parity_error, data, rst,strt_beg);
input strt_beg;
input rx_err;
input d;
input clk;
input rst; //active low
input parity;
output reg parity_error;
output reg[7:0] data;

reg [8:0] rec_data; //storage for received data
reg [1:0] state;


//states
parameter A = 2'b00;
parameter B = 2'b01;
parameter C = 2'b10;

integer i;

xor(even,rec_data[7],rec_data[6],rec_data[5],rec_data[4],rec_data[3],rec_data[2],rec_data[1],rec_data[0]);
xnor(odd,rec_data[7],rec_data[6],rec_data[5],rec_data[4],rec_data[3],rec_data[2],rec_data[1],rec_data[0]);

always@(posedge clk)
begin
	if(!rst)
	begin
		state <=A;
		data <= 0;
		i <= 0;
		parity_error <= 0;
	end
	
	else if(rst && strt_beg)
	begin
		case (state)
	
		A:begin
			
			i <= 1;
			parity_error <= 0;
			rec_data[0] <= d;
			state <= B;
			//end
		  end
		
		B:begin
			if( i <= 32'h7)
				begin
				rec_data [i] <= d;
				i<=i+1;
				end
				
			
			else if(i==8)
			state <= A;
		  end
	endcase
	end
end


always@(posedge clk)
begin
 if(state == B && i == 8)
		begin
				
					rec_data[8] = d;
					if(parity == 1'h0)
						begin
							if(even == rec_data[8])
							begin
								if(rx_err != 1'b1)data[7:0] <= {rec_data [7:0]};
							end
							else   parity_error <= 1'b1;
						end
					else if(parity == 1'b1)
						begin
							if(odd == rec_data[8])
								begin
									if(rx_err != 1'b1)data[7:0] <= {rec_data [7:0]};
								end
								else  parity_error <= 1'b1;
						end
					
					
			
		end
end	


endmodule
					 
			
			
