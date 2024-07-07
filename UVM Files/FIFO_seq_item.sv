package FIFO_seq_item_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"

	class FIFO_seq_item extends uvm_sequence_item;
		`uvm_object_utils(FIFO_seq_item)

		parameter FIFO_WIDTH = 16;
		parameter FIFO_DEPTH = 8;
		// Design inputs
		rand logic [FIFO_WIDTH-1:0] data_in;
		rand logic rst_n, wr_en, rd_en;
		// Design outputs
		logic [FIFO_WIDTH-1:0] data_out;
		logic wr_ack, overflow;
		logic full, empty, almostfull, almostempty, underflow;

		int WR_EN_ON_DIST= 70;
		int RD_EN_ON_DIST= 30;

		// Assert reset less often
		constraint rst_c { rst_n dist {0:=2, 1:=98}; }

		// Constraint the write enable to be high with distribution of the value WR_EN_ON_DIST & to be low with 100-WR_EN_ON_DIST
		constraint wr_en_c { wr_en dist {1:=WR_EN_ON_DIST, 0:=100-WR_EN_ON_DIST}; }

		// Constraint the read enable the same as write enable but using RD_EN_ON_DIST
		constraint rd_en_c { rd_en dist {1:=RD_EN_ON_DIST, 0:=100-RD_EN_ON_DIST}; }
		
		function new(string name = "FIFO_seq_item");
			super.new(name);
		endfunction
		
		function string convert2string();
			return $sformatf("%s reset=0b%0b, wr_en=0b%0b, rd_en=0b%0b, data_in=0x%0x,
			data_out=0x%0x, full=0b%0b, empty=0b%0b", super.convert2string(), rst_n, wr_en, rd_en, data_in,
			data_out, full, empty);
		endfunction

		function string convert2string_stimulus();
			return $sformatf("reset=0b%0b, wr_en=0b%0b, rd_en=0b%0b, data_in=0x%0x", 
				rst_n, wr_en, rd_en, data_in);
		endfunction

	endclass

endpackage