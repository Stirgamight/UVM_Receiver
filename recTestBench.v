//The test bench for the receiver top hierarchy
`timescale 100ns/100ns
module test;

reg clk;
reg Bclkx16_;
reg Rx;
reg parity;
reg rst;


wire Rx_err;
wire parity_error;
wire [7:0] data;

grndrec rec
(
	 .clk(clk),
     .Bclkx16_(Bclkx16_),
	 .Rx(Rx),
	 .parity(parity),
     .rst(rst),

 .Rx_err(Rx_err),
 .parity_error(parity_error),
 .data(data)
);

initial
begin
	clk = 1;
	Bclkx16_ = 1;
end

always
begin
	#1 Bclkx16_ = !Bclkx16_;
end

always
begin
	#16 clk = !clk;
end

event reset_trigger;
event reset_done;
event terminate;
initial
begin
	forever begin
	@(reset_trigger);
	@(posedge clk);
	rst = 1'b0;
	@(posedge clk);
	rst = 1'b1;
	->reset_done;
	end
end



initial
begin
	forever begin
	@(terminate);
	#2 $finish;
	end
end

initial
begin
-> reset_trigger;
@(reset_done);

//no error even parity case
parity = 1'b0;//even parity indication
Rx = 1'b0; #32;//enter the start bit
Rx = 1'b1; #128;//enter 4 ones
Rx = 1'b0; #64;//enter 2 0's
Rx = 1'b1; #64;//enter 2 ones now the sequence is 1111 0011
Rx = 1'b0; #32;//enter the parity bit: 0 means even parity
Rx = 1'b1; #32;//the stop bit
#16;
//frame error even parity case
parity = 1'b0;//even parity indication
Rx = 1'b0; #32;//enter the start bit
Rx = 1'b1; #128;//enter 4 ones
Rx = 1'b0; #64;//enter 2 0's
Rx = 1'b1; #64;//enter 2 ones now the sequence is 1111 0011
Rx = 1'b0; #32;//enter the parity bit: 0 means even parity
Rx = 1'b0; #32;//the stop bit
#16;

//even parity error case
parity = 1'b0;//even parity indication
Rx = 1'b0; #32;//enter the start bit
Rx = 1'b1; #128;//enter 4 ones
Rx = 1'b0; #32;//enter  0
Rx = 1'b1; #32;//enter  1
Rx = 1'b1; #64;//enter 2 ones now the sequence is 1111 0011
Rx = 1'b0; #32;//enter the parity bit: 0 means even parity
Rx = 1'b1; #32;//the stop bit
#16;



//no error odd parity case
parity = 1'b1;//odd parity indication
Rx = 1'b0; #32;//enter the start bit
Rx = 1'b1; #157;//enter 5 ones
Rx = 1'b0; #32;//enter  0
Rx = 1'b1; #64;//enter 2 ones now the sequence is 1111 0011
Rx = 1'b1; #32;//enter the parity bit: 1 means odd parity
Rx = 1'b1; #32;//the stop bit
#16;
//frame error odd parity case
parity = 1'b1;//odd parity indication
Rx = 1'b0; #32;//enter the start bit
Rx = 1'b1; #157;//enter 5 ones
Rx = 1'b0; #32;//enter  0
Rx = 1'b1; #64;//enter 2 ones now the sequence is 1111 0011
Rx = 1'b1; #32;//enter the parity bit: 1 means odd parity
Rx = 1'b0; #32;//the stop bit
#16;
//odd parity error case
parity = 1'b1;//odd parity indication
Rx = 1'b0; #32;//enter the start bit
Rx = 1'b1; #128;//enter 4 ones
Rx = 1'b0; #64;//enter 2 0's
Rx = 1'b1; #64;//enter 2 ones now the sequence is 1111 0011
Rx = 1'b1; #32;//enter the parity bit: 1 means odd parity
Rx = 1'b1; #32;//the stop bit
#16;
->terminate;
end
endmodule 












