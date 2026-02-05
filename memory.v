// imple of memory design
`timescale  1ns/1ps
`define DEPTH 16
`define WIDTH 16
`define ADDR_WIDTH $clog2(`DEPTH)
module memory(clk_i,rst_i,wr_rd_i,addr_i,wdata_i,rdata_o,valid_i,ready_o);
 // declaring the parameter
 /*	parameter DEPTH=16;
	parameter WIDTH=8;
	parameter ADDR_WIDTH =$clog2(DEPTH);*/

// declaring input and output port

	 input clk_i,rst_i,wr_rd_i,valid_i;
	 input [`ADDR_WIDTH-1:0]addr_i;
	 input [`WIDTH-1:0]wdata_i;
	 output reg[`WIDTH-1:0]rdata_o;
	 output reg ready_o;

// declaring the memory
	reg[`WIDTH-1:0]mem[`DEPTH-1:0];

// internal signal
	integer i;
// memory declaration
		always@(posedge clk_i)begin
		if(rst_i==1)begin
        rdata_o=0;
		ready_o=0;
		for(i=0;i<`DEPTH;i=i+1)begin
			mem[i]=0;
		end
	end	
	else begin
			if(valid_i==1)begin
	  		 	ready_o=1;
			if(wr_rd_i==1)begin
				mem[addr_i]=wdata_i;
		 	end
				else begin
					rdata_o=mem[addr_i];
				end
			end
			else ready_o=0;
		end
	end
endmodule


			



