//delay block
module delay(rst,Bclkx16_,err,strt_sig,err_del,strt_del);

input Bclkx16_;
input err;
input strt_sig;
input rst;
output reg err_del;
output reg strt_del;
//output reg clk;
reg [1:0] state ;
//states
parameter A = 2'b00;
parameter B = 2'b01;
parameter C = 2'b10;


//counters
integer err_counter;
integer strt_counter;

always@(posedge Bclkx16_)
begin
if(!rst)
	begin
	err_counter <= 1'b0;
	strt_counter <= 1'b0;
	err_del <= 1'b0;
	strt_del <= 1'b0;
	state <= A;
	end

else 
	begin
		case(state)
		A:begin
		  if(err)
			begin
			state <= B;
			err_counter <= 1'b1;
			end
		  else if(strt_sig)
			begin
			state <= C;
			strt_counter <= 1'b1;
			end
		  end
		  
		B:begin
		  if(err_counter < 32'h10) err_counter = err_counter+1; 
		  end
		  
		C:begin
		  if(strt_counter < 32'h10) strt_counter = strt_counter+1; 
		  end
		endcase
	end
end  
	  
	  
always@(posedge Bclkx16_)
begin
case(state)
	B:begin
		if(err_counter < 32'h10) err_del <= 1'b1;
		if(err_counter == 32'h10)
		begin
		err_del <=1'b0;
		err_counter <= 1'b0;
		end
	  end
	  
	C:begin
		if(strt_counter < 32'h10) strt_del <= 0;
		if(strt_counter == 32'h10)
		begin
		strt_del <=strt_counter;
		err_counter <= 0;
		end
	  end
endcase
end

endmodule


	  