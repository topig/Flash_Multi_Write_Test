module LFSR(
//clk,en,LFSR);
//input clk;
//input en;
//output reg[7:0] LFSR;
  input clk,
  input rst,
  output reg [7:0] LFSR = 255
);

wire feedback = LFSR[7] ^ (LFSR[6:0]==7'b0000000);

always @(posedge clk or negedge rst)
begin
if(!rst)
	LFSR<=8'hFF;
else begin
	LFSR[0] <= feedback;
	LFSR[1] <= LFSR[0];
	LFSR[2] <= LFSR[1];
	LFSR[3] <= LFSR[2];
	LFSR[4] <= LFSR[3]^ feedback;
	LFSR[5] <= LFSR[4]^ feedback;
	LFSR[6] <= LFSR[5]^ feedback;
	LFSR[7] <= LFSR[6];
end
	end
endmodule