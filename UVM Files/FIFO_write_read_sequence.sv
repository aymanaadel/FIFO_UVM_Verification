package FIFO_write_read_sequence_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"
import FIFO_seq_item_pkg::*;

	class FIFO_write_read_sequence extends uvm_sequence #(FIFO_seq_item);
		`uvm_object_utils(FIFO_write_read_sequence)

		FIFO_seq_item seq_item;

		function new(string name = "FIFO_write_read_sequence");
			super.new(name);
		endfunction

		task body;
			repeat(10000) begin
				seq_item=FIFO_seq_item::type_id::create("seq_item");
				start_item(seq_item);
				assert(seq_item.randomize());
				finish_item(seq_item);
			end
		endtask
		
	endclass

endpackage


