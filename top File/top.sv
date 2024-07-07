import uvm_pkg::*;
`include "uvm_macros.svh"
import FIFO_test_pkg::*;

module top;
	// clock generation
	bit clk;
	initial begin
		clk=0;
		forever #1 clk=~clk;
	end
	// interface
	FIFO_if #(.FIFO_WIDTH(16), .FIFO_DEPTH(8)) f_if(clk);
	// DUT
	FIFO dut(f_if);
	// assertions
	bind FIFO FIFO_sva FIFO_sva_inst (f_if, dut.count);

	initial begin
		uvm_config_db#(virtual FIFO_if)::set(null, "uvm_test_top", "FIFO_IF", f_if);
		run_test("FIFO_test");
	end

endmodule