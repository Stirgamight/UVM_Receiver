//receiver grand-module ; lower hierarchy modules: (1) "control ctrl" and (2) "sr regi"
module grndrec (clk, Bclkx16_, Rx ,rst , parity ,  parity_error, data,Rx_err );
input clk;
input Bclkx16_;
input Rx;
input parity;
input rst;

//output Rx_done;
output Rx_err;
output parity_error;
output [7:0] data;


wire dataLink;//the wire between the control system and the register block for d
wire err; //the error wire between the control system and the register
wire strt_sig;//the start signal from control to the register to begin storing data
wire reset;//the connection between the terminator reset output to the other modules reset inputs
wire ter_sig;//used to connect Rx-done from control to that in terminator
wire[0:7]dis_line;//connects the input display of the terminator to the output of the register

//reset is active low
control ctrl (.Rx(Rx), .Bclkx16_(Bclkx16_), .rst(reset), .Rx_done(ter_sig), .Rx_err(err), .d(dataLink), .safe_data(strt_sig));
sr regi (.rx_err(err), .d(dataLink), .clk(clk), .parity(parity), .parity_error(parity_error), .data(dis_line), .rst(reset), .strt_beg(strt_sig));
terminator ter(.reset(rst),.Bclkx16_(Bclkx16_),.Rx_done(ter_sig),.data(dis_line),.rst(reset),.dis(data));
assign Rx_err = err;
endmodule
