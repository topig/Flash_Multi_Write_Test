module Erase_Multi_Write(rst, rst2, clk, rb, io, cle, we, ale, re, ce, HEX0, HEX1, HEX2, HEX3);

input	rst;
input	rst2;
input	clk;
input	rb;
inout	[7:0]	io;

output	reg	cle; 
output	reg	we;
output	reg	ale;
output	reg	re;
output	reg	ce;
output	[6:0]	HEX0;
output	[6:0]	HEX1;
output	[6:0]	HEX2;
output	[6:0]	HEX3;


reg	[3:0]	st; //status:0->RST 1:>Erase b->Program F->Finish

reg	[7:0]	out;
reg	[7:0]	temp;
reg	[5:0]	state;
reg	[5:0]	nextstate;
reg	[13:0]	counter;
reg	[5:0] counter2;
reg [8:0]	counter3;
reg	[11:0]	devcode;
reg	[7:0] data;
reg	[4:0]	clkcnt;
reg	[11:0]	addrcount;
reg	[11:0]	blockcount;
reg	[7:0] status;
reg [2:0] n;
reg en;
reg	clk_double;

parameter	RST=0, SEND_CMD=1, GET_DAT=2,SEND_ADDR=3,SEND_DAT=4;
parameter	RS1=31, RS2=32;
parameter	ER0=5,ER1=6,ER2=7,ER3=8,ER4=9,ER5=10,ER6=11,ER7=12,ER8=13,ER9=14,ER10=15,ER11=16;
parameter	WE0=17,WE1=18,WE2=19,WE3=20,WE4=21,WE5=22,WE6=23,WE7=24,WE8=25,WE9=26,WE10=27,WE11=28,WE12=29,WE13=30;


parameter	INITIAL_ADDR=0;  //Set initial address
parameter	PAGE_PER_BLOCK=8'hFF; //8'hFF; //Set number of pages to be read (# of pages-1 as the pagecount starts from 0)
parameter	DATA_BYTES_PER_PAGE=8192; //BACA:4096 BADA:8192
parameter	PAGE_SIZE=8936;//BACA: 4320  BADA:8936(8192+744)
parameter	INITIAL_BLOCK=12'h00;
parameter	LAST_BLOCK=2127; //BACA:12'hFFF; BADA:12h084f
parameter	TEST_CYCLE=10;

assign io=we?8'bZ:out; 
wire en_o;
wire	[7:0] RandData;
assign en_o=en;

LFSR L0(en_o,rst2,RandData);

always @ (posedge clk_double)  
begin
	if(!rst)	begin  //reset registers
			re<=1;
			ce<=0;
			cle<=0;
			ale<=0;
			we<=1;
			state<=RST;
			addrcount<=INITIAL_BLOCK;
			blockcount<=INITIAL_BLOCK;
			counter<=0;
			counter2<=0;
			counter3<=0;
			st<=0;
			devcode<=8'b0;
			out<=8'b0;
			status<=0;
			end
	else	begin
		case(state)
			RST:begin
				re<=1;
				ce<=0;
				cle<=0;
				ale<=0;
				we<=1;
				if (rb==0) state<=RST;
				else state<=RS1;	
			end	
			////CMD, DATa
			SEND_CMD:begin
				nextstate<=nextstate;
				out<=out;
				case(n)
					0:begin
						re<=1;
						ce<=0;
						cle<=0;
						ale<=0;
						we<=1;
						n<=n+1;
						state<=SEND_CMD;
					end
					1:begin
						re<=1;
						ce<=0;
						cle<=1;
						ale<=0;
						we<=1;	
						n<=n+1;
						state<=SEND_CMD;
					end
					2:begin
						re<=1;
						ce<=0;
						cle<=1;
						ale<=0;
						we<=0;	
						n<=n+1;
						state<=SEND_CMD;
					end
					3:begin
						re<=1;
						ce<=0;
						cle<=1;
						ale<=0;
						we<=1;	
						n<=n+1;
						state<=SEND_CMD;
					end
					4:begin
						re<=1;
						ce<=0;
						cle<=0;
						ale<=0;
						we<=1;	
						n<=0;
						state<=nextstate;
					end
				default:begin
						re<=1;
						ce<=0;
						cle<=0;
						ale<=0;
						we<=1;
						n<=0;
						state<=SEND_CMD;
					end
					endcase
			end

			SEND_ADDR:begin
					nextstate<=nextstate;
					out<=out;
					case(n)
					0:begin
						re<=1;
						ce<=0;
						cle<=0;
						ale<=0;
						we<=1;
						n<=n+1;
						state<=SEND_ADDR;
					end
					1:begin
						re<=1;
						ce<=0;
						cle<=0;
						ale<=1;
						we<=1;	
						n<=n+1;
						state<=SEND_ADDR;
					end
					2:begin
						re<=1;
						ce<=0;
						cle<=0;
						ale<=1;
						we<=0;	
						n<=n+1;
						state<=SEND_ADDR;
					end
					3:begin
						re<=1;
						ce<=0;
						cle<=0;
						ale<=1;
						we<=1;	
						n<=n+1;
						state<=SEND_ADDR;
					end
					4:begin
						re<=1;
						ce<=0;
						cle<=0;
						ale<=0;
						we<=1;	
						n<=0;
						state<=nextstate;
					end
					default:begin
						re<=1;
						ce<=0;
						cle<=0;
						ale<=0;
						we<=1;
						n<=0;
						state<=SEND_ADDR;
					end
					endcase
				end
				SEND_DAT:begin
					nextstate<=nextstate;
					out<=out;
					en<=0;
					case(n)
					0:begin
						re<=1;
						ce<=0;
						cle<=0;
						ale<=0;
						we<=1;
						n<=n+1;
						state<=SEND_DAT;
					end
					1:begin
						re<=1;
						ce<=0;
						cle<=0;
						ale<=0;
						we<=0;	
						n<=n+1;
						state<=SEND_DAT;
					end
					2:begin
						re<=1;
						ce<=0;
						cle<=0;
						ale<=0;
						we<=1;	
						n<=n+1;
						state<=nextstate;
					end
					default:begin
						re<=1;
						ce<=0;
						cle<=0;
						ale<=0;
						we<=1;
						n<=0;
						state<=SEND_DAT;
					end
					endcase
			end
			GET_DAT:begin
					nextstate<=nextstate;
					case(n)
					0:begin
						re<=1;
						ce<=0;
						cle<=0;
						ale<=0;
						we<=1;
						n<=n+1;
						state<=GET_DAT;
					end
					1:begin
						re<=0;
						ce<=0;
						cle<=0;
						ale<=0;
						we<=1;	
						n<=n+1;
						state<=GET_DAT;
					end
					2:begin
						re<=0;
						ce<=0;
						cle<=0;
						ale<=0;
						we<=1;	
						n<=n+1;
						data<=io;
						state<=GET_DAT;
					end
					3:begin
						re<=1;
						ce<=0;
						cle<=0;
						ale<=0;
						we<=1;	
						n<=n+1;
						state<=nextstate;
					end
					default:begin
						re<=1;
						ce<=0;
						cle<=0;
						ale<=0;
						we<=1;
						n<=0;
						state<=GET_DAT;
					end
					endcase
			end
			
			RS1:begin
				re<=1;
				ce<=0;
				cle<=0;
				ale<=0;
				we<=1;
				out<=8'hFF; 
				n<=0;
				state<=SEND_CMD;
				nextstate<=RS2;
			end

			RS2:begin    //return here after each block
				re<=1;
				ce<=0;
				cle<=0;
				ale<=0;
				we<=1;
				n<=0;
				if(rb!=0)	state<=ER0;
				else state<=RS2;
				end
			ER0:begin
				st<=4'h01;
				re<=1;
				ce<=0;
				cle<=0;
				ale<=0;
				we<=1;
				out<=8'h60; 
				n<=0;
				state<=SEND_CMD;
				nextstate<=ER1;
			end
			ER1:begin
				re<=1;
				ce<=0;
				cle<=0;
				ale<=1;
				we<=1;
				counter<=0;
				state<=ER2;
				end
			ER2:begin
				re<=1;
				ce<=0;
				cle<=0;
				ale<=1;
				we<=0;
				case(counter)
					0:out<=8'h00;
					1:out<=addrcount[7:0];
					2:out<={4'b0,addrcount[11:8]};
				endcase
				counter<=counter+1;
				state<=ER3;
				end
			ER3:begin
				re<=1;
				ce<=0;
				cle<=0;
				ale<=1;
				we<=1;
				if(counter==3)begin
				state<=ER4;
				counter<=0;
				end
				else	state<=ER2;
				end
			ER4:begin
				re<=1;
				ce<=0;
				cle<=0;
				ale<=0;
				we<=1;
				out<=8'hD0; 
				n<=0;
				state<=SEND_CMD;
				nextstate<=ER5;
				end
			ER5:begin
				re<=1;
				ce<=0;
				cle<=0;
				ale<=1;
				we<=1;
				if (rb!=0) state<=ER6;
				else state<=ER5;
				end
			ER6: begin
				if(rb!=0) begin
				re<=1;
				ce<=0;
				cle<=0;
				ale<=0;
				we<=1;
				out<=8'h70; 
				n<=0;
				state<=SEND_CMD;
				nextstate<=ER7;
				end
				else state<=ER5;
				end
			ER7:begin
				re<=1;
				ce<=0;
				cle<=0;
				ale<=0;
				we<=1;
				n<=0;
				state<=GET_DAT;
				nextstate<=ER8;
				end
			ER8:begin
				re<=1;
				ce<=0;
				cle<=0;
				ale<=0;
				we<=1;
				if(data[7]==1 && data[6]==1 && data[5]==1 && data[0]==0)begin
					state<=ER9;
					counter2<=0;
				end
				else state<=ER11;
				end
			ER11:begin
				re<=1;
				ce<=0;
				cle<=0;
				ale<=0;
				we<=1;
				devcode<=addrcount;
				counter2<=counter2+1;
				if (counter2>5) begin
						counter2<=0;
						state<=ER9;
				end
				else begin 
						state<=RS2;
				end
				end
			ER9:begin
				re<=1;
				ce<=0;
				cle<=0;
				ale<=0;
				we<=1;
				if (addrcount<LAST_BLOCK) begin
					addrcount<=addrcount+1;
					state<=RS2;
					end
				else state<=ER10;
				end
			ER10:begin
				re<=1;
				ce<=0;
				cle<=0;
				ale<=0;
				we<=1;
				counter<=0;
				out<=8'b0;			
				state<=WE0;
				addrcount<=INITIAL_ADDR;
				blockcount<=INITIAL_BLOCK;
				counter2<=0;
				n<=0;
				en<=0;
				end
				
			WE0:begin
				st<=4'hd;
				re<=1;
				ce<=0;
				cle<=0;
				ale<=0;
				we<=1;
				en<=0;
				counter<=0;
				counter2<=0;
				n<=0;
				if (rb==0) state<=WE0;
				else state<=WE1;			
				end
		
			WE1:begin
				re<=1;
				ce<=0;
				cle<=0;
				ale<=0;
				we<=1;
				out<=8'h80; 
				n<=0;
				state<=SEND_CMD;
				nextstate<=WE2;
			end
			WE2:begin
				re<=1;
				ce<=0;
				cle<=0;
				ale<=0;
				we<=1;
				out<=8'h00; 
				counter<=0;
				state<=WE3;
			end
			WE3:begin
				re<=1;
				ce<=0;
				cle<=0;
				ale<=1;
				we<=1;
				if (counter<5) state<=WE4;
				else	begin
					counter<=0;
					state<=WE5;
				end
			end
			WE4:begin
				re<=1;
				ce<=0;
				cle<=0;
				ale<=1;
				we<=0;
				case(counter)
					0:out<=8'h00;
					1:out<=8'h00;
					2:out<=addrcount[7:0];
					3:out<=blockcount[7:0];
					4:out<={4'b0,blockcount[11:8]};
				endcase
				counter<=counter+1;
				state<=WE3;
			end

			WE5:begin
				re<=1;
				ce<=0;
				cle<=0;
				ale<=0;
				we<=1;
				counter<=counter+1;
				if (counter<DATA_BYTES_PER_PAGE) begin
					en<=1;
					out<=RandData;
					n<=0;
					state<=SEND_DAT;
					nextstate<=WE5;
				end
				else if(counter>=DATA_BYTES_PER_PAGE&&counter<PAGE_SIZE) begin
					en<=0;
					out<=8'h00;
					n<=0;
					state<=SEND_DAT;
					nextstate<=WE5;
				end
				else begin
					en<=0;
					out<=8'h00;
					n<=0;
					state<=SEND_DAT;
					nextstate<=WE6;
				end
			end
			WE6:begin
				counter<=0;
				re<=1;
				ce<=0;
				cle<=0;
				ale<=0;
				we<=1;
				out<=8'h10; 
				n<=0;
				state<=SEND_CMD;
				nextstate<=WE7;
			end		
			
			WE7:begin
				counter<=0;
				re<=1;
				ce<=0;
				cle<=0;
				ale<=0;
				we<=1;
				out<=8'h70; 
				n<=0;
				if(rb==0)state<=WE7;
				else begin
					state<=SEND_CMD;
					nextstate<=WE8;
				end
				end
			WE8:begin
				re<=0;
				ce<=0;
				cle<=0;
				ale<=0;
				we<=1;
				status<=io;
				counter<=counter+1;
				if (counter<=5) state<=WE8;
				else begin
				if (rb==0)state<=WE7;
				else begin
				counter<=0;
				state<=WE9;
				end
				end
			end
			WE9:begin
				re<=1;
				ce<=0;
				cle<=0;
				ale<=0;
				we<=1;
				if (status[7]==1 && status[6]==1 && status[5]==1 && status[0]==0 && addrcount<PAGE_PER_BLOCK) begin
						counter2<=0;
						addrcount<=addrcount+12'b1;
						state<=WE0;
						end
				else if (status[7]==1 && status[6]==1 && status[5]==1 && status[0]==0 && addrcount>=PAGE_PER_BLOCK) begin
						counter2<=0;
						state<=WE11;
						end
				else state<=WE10;
				end
			WE10:begin
				re<=1;
				ce<=0;
				cle<=0;
				ale<=0;
				we<=1;
				counter2<=counter2+1;
				if (addrcount<PAGE_PER_BLOCK && counter2<10)state<=WE7;
				else if (addrcount<PAGE_PER_BLOCK && counter2>=10)begin
						counter2<=0;
						addrcount<=addrcount+12'b1;
						state<=WE0;
				end
				else if (addrcount>=PAGE_PER_BLOCK && counter2<10)state<=WE7;
				else begin
						counter2<=0;
						state<=WE11;
				end		
			end

			WE11:begin
				re<=1;
				ce<=0;
				cle<=0;
				ale<=0;
				we<=1;
				if(blockcount<LAST_BLOCK)begin
						addrcount<=INITIAL_ADDR;
						blockcount<=blockcount+12'b1;
						state<=WE0;
					end
				else state<=WE12;
			end
			WE12:begin
				re<=1;
				ce<=0;
				cle<=0;
				ale<=0;
				we<=1;
				counter3<=counter3+1;
				if (counter3<TEST_CYCLE) state<=RST;
				else state<=WE13;
			end
			
			WE13:begin
				re<=1;
				ce<=1;
				cle<=0;
				ale<=0;
				we<=1;
				state<=WE13;
				st<=4'hf;
			end
			default:begin
						re<=1;
						ce<=0;
						cle<=0;
						ale<=0;
						we<=1;
						n<=0;
						state<=5'bX;
						nextstate<=5'bX;
			end		
		endcase
	end
end

always @ (posedge clk)

begin
	if(!rst2)	begin
		clk_double<=0;
		clkcnt<=0;
		end
	else begin
		if (clkcnt==2) begin
			clk_double<=1;
			clkcnt<=clkcnt+1;
			end
		else if (clkcnt==5) begin 
			clk_double<=0;
			clkcnt<=0;
			end
		else begin
			clkcnt<=clkcnt+1;
		end
	end

end	
			
hex2seg h0(counter3[3:0],HEX0);
hex2seg h1(counter3[7:4],HEX1);
hex2seg h2(blockcount[11:8],HEX2);
hex2seg h3(st[3:0],HEX3);
//hex2seg h2(state[3:0],HEX2);
//hex2seg h3({2'b00,state[5:4]},HEX3);
endmodule