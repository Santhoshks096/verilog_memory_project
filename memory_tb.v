//`include "memory.v"
`define PRINT 1
module top;

// declaring the parameter
 /*	parameter DEPTH=16;
	parameter WIDTH=8;
	parameter ADDR_WIDTH =$clog2(DEPTH);*/

// declaring reg and output port
	 reg clk_i,rst_i,wr_rd_i,valid_i;
	 reg [`ADDR_WIDTH-1:0]addr_i;
	 reg [`WIDTH-1:0]wdata_i;
	 wire[`WIDTH-1:0]rdata_o;
	 wire ready_o;
	 memory	/*#(.DEPTH(DEPTH),.WIDTH(WIDTH))*/ dut(
	                                             .clk_i     (clk_i),
										         .rst_i     (rst_i),
												 .wr_rd_i   (wr_rd_i),
												 .addr_i    (addr_i),
												 .wdata_i   (wdata_i),
												 .rdata_o   (rdata_o),
												 .valid_i   (valid_i),
												 .ready_o   (ready_o));

	integer i;
	reg[25*8:0]testname;
	
// clock generation
	initial begin
		clk_i=0;
		forever #5 clk_i=~clk_i;
	end

	initial begin
		reset_mem();
		$value$plusargs("testcase=%0s",testname);
		case(testname)
			"test_5wr_5rd":begin
				write_mem(0,5);
				read_mem(0,5);
			end
				"test_5writes":begin
				write_mem(0,5);
	    	end
		     	"test_5wr_3rd":begin
				write_mem(0,5);
				read_mem(0,3);
			end
				"test_2writes":begin
				write_mem(0,2);
			end
				"test_wr":begin
				write_mem(1,`DEPTH);
			end
		     	"test_1wr_1rd":begin
				write_mem(6,`DEPTH);
				read_mem(8,`DEPTH);
			end
				"test_wr_rd":begin
				write_mem(0,`DEPTH);
				read_mem(0,`DEPTH);
			end
				"test_first_half":begin //1/4
				write_mem(0,(`DEPTH/4));
				read_mem(0,(`DEPTH/4));
			end
				"test_half":begin       //1/2
				write_mem(0,(`DEPTH/2));
				read_mem(0,(`DEPTH/2));
			end
				"test_3/4":begin        //3/4
				write_mem(0,3*(`DEPTH/4));
				read_mem(0,3*(`DEPTH/4));
			end
				"test_1/4_3/4":begin 
				write_mem(0,(`DEPTH/4));
				read_mem(0,3*(`DEPTH/4));
			end	
				"test_wr_3/4":begin 
				write_mem(0,`DEPTH);
				read_mem(0,3*(`DEPTH/4));
			end
				"test_3rd_portion_only":begin 
				write_mem(`DEPTH/2,3*(`DEPTH/4));
				read_mem(`DEPTH/2,3*(`DEPTH/4));
			end
				"test_2nd_portion_only":begin 
				write_mem(3,(`DEPTH/2));
				read_mem(3,(`DEPTH/2));
			end	
             /*	"test_3rd":begin   this condition only PRINT 3 address and then not show for read condition
				read_mem(0,3);
			end*/
			
		     /*	"test_1wr_rd":begin
				write_mem(0,`DEPTH);the reverse method is not working 
				read_mem(`DEPTH,0);
			end*/
         
// backdoor wright test
				"test_bd_wr_bd_rd":begin
				mem_bd_write();
				mem_bd_read();
			end 
				"test_bd_wr_fd_rd":begin
				mem_bd_write();
				read_mem(0,`DEPTH);
			end	
				"test_fd_wr_bd_rd":begin
				write_mem(0,`DEPTH);
				mem_bd_read();
			end
				"test_fd_wr_fd_rd":begin
				write_mem(0,`DEPTH);
				read_mem(0,`DEPTH);
			end
	endcase
		#50;
		$finish();
	end

//declaring reset in task function
	task reset_mem();
		begin
			rst_i=1;
			wr_rd_i=0;
			addr_i=0;
			wdata_i=0;
			valid_i=0;
			repeat(2)@(posedge clk_i);
			rst_i=0;
		end
	endtask
// memory write_task
	task write_mem(input integer start_loc,input integer end_loc);
		begin
			if(`PRINT==1)$display("-----------write memory------------");
			for(i=start_loc;i<end_loc;i=i+1)begin
			@(posedge clk_i);
			valid_i=1;
			wait(ready_o==1);
			wr_rd_i=1;
			addr_i=i;
			wdata_i=$random;
			if(`PRINT==1)$display("addr=%d ||wdata=%h",addr_i,wdata_i);
		end
			@(posedge clk_i);
			valid_i=0;
			wr_rd_i=0;
			addr_i=0;
			wdata_i=0;
		end
	endtask	
// memory read_task
	task read_mem(input integer start_loc,input integer end_loc);
		begin
			if(`PRINT==1)$display("-----------read memory------------");
			for(i=start_loc;i<end_loc;i=i+1)begin
			@(posedge clk_i);
			valid_i=1;
			wait(ready_o==1);
			wr_rd_i=0;
			addr_i=i;
			#1;
			if(`PRINT==1)$display("addr=%d ||rdata=%h",addr_i,rdata_o);
		end
			@(posedge clk_i);
			valid_i=0;
			wr_rd_i=0;
			addr_i=0;
		end
	endtask	

// memory_back_door_access

//back door write task
	task mem_bd_write();
		begin
			$readmemh("tex.hex",dut.mem);
		end
	endtask

//back door read task
		task mem_bd_read();
		begin
			$writememb("out.bin",dut.mem);
		end

	endtask 
  
  /*
// back door write task

	task mem_bd_write();
		begin
			$readmemb("good.bin",dut.mem);
		end
	endtask
//back door read task

	task mem_bd_read();
		begin
			$writememh("bad.hex",dut.mem);
		end
	endtask
  
  */
  
  	initial begin
      $dumpfile("wave.vcd");
      $dumpvars(0,top);
      #1000;
      $finish();
    end
endmodule





		



