//receiver control system implementation

module control(Rx, Bclkx16_, rst, Rx_done, Rx_err, d, safe_data);
input Rx;			//Data received
input rst;			//reset pin : active low
input Bclkx16_;		//output of the baud rate generator

reg [2:0]state; 
output reg Rx_done;
output reg Rx_err;
output reg d;
output reg safe_data;



//the states:
parameter A = 3'b010;  //idle/reset state
parameter B = 3'b110;  //detected 0 at i/p: count to 7//sampling counter begins to count >>reset when it reaches 7
parameter C = 3'b111;  //the sampling counter reaches 32 and the strt_beg flag is set: reset the counter,store the data
parameter D = 3'b011;  //sampling counter reaches 15//reset data_beg//set data_end//store data//reset the counter
parameter E = 3'b000;  //data_count==7//input is 1//sampling counter is 15//go back to A//set Rx_done

//flags
integer strt_beg;//flag indicating the detection of start bit


//counters
reg[0:3] samplingCounter;
reg[0:3] dataCounter;
reg[0:3] endCounter;
reg[0:3] errCounter;

//cont. assignment
//assign strt_sig = strt_beg;

always@(posedge Bclkx16_)
begin
	if (!rst) begin
			  state <= A;
			  strt_beg <= 0;
			  endCounter <=0;
			  errCounter <=0;
			  samplingCounter <= 0;
			  dataCounter <= 0;
			  Rx_done <=0;
			  Rx_err <=0;
			  safe_data <= 1'b0;
			  end
	else begin
		 case(state)
				A :begin
				strt_beg <= 0;
				safe_data <= 1'b0;
				endCounter <= 0;
				errCounter <= 0;
				samplingCounter <= 0;
				dataCounter <= 0;
				Rx_done <=0;
				Rx_err <=0;
					if(Rx == 0)
					begin
					if(samplingCounter == 32'h7) state <= B;
					else samplingCounter <= samplingCounter+1;
					end
				   end
				B :begin
					
					strt_beg <= 1'b1;
					state <= C;
					samplingCounter <= 1;
					
				   end
				C :begin
					if (samplingCounter == 32'hf)
					begin
						state <= D;
						safe_data<=1'b1;
						samplingCounter <= 0;
						dataCounter <= dataCounter+1;
					end
					else if(strt_beg == 1'b1)
					
					samplingCounter <= samplingCounter +1;
					end
				D :begin
					if(dataCounter == 32'h9) 
					begin
					safe_data <= 0;
					state <= E;
					endCounter <= 1'b1;
					end
					else if(strt_beg == 1'b1 && dataCounter <= 32'h9)
						begin
						//samplingCounter <= 0;
						//dataCounter <= dataCounter+1;
						samplingCounter <= samplingCounter +1;
						state <= C;
						end
				   end
				E:begin
					if(endCounter < 32'h8) 
					endCounter <= endCounter+1; 
				  end 
				  
				
			endcase
	end
end
always@(posedge Bclkx16_)
begin
	case(state)
		E:begin
			if(endCounter == 32'h8 && Rx==1'b1) 
			begin
			Rx_done<=1'b1;
			state <= A;
			end
			else if(endCounter == 32'h8 && Rx !=1'b1) 
			begin
			if(errCounter < 32'hf)
				begin
				Rx_err <= 1'b1;
				errCounter <= errCounter +1'b1;
				end
			else state <= A;
			end
		  end
		C:begin
		  if (samplingCounter == 32'hf) d<= Rx;
		  end
	endcase
end


endmodule
