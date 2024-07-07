	package FIFO_test_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"
import FIFO_env_pkg::*;
import FIFO_reset_sequence_pkg::*;
import FIFO_write_only_sequence_pkg::*;
import FIFO_read_only_sequence_pkg::*;
import FIFO_write_read_sequence_pkg::*;
import FIFO_config_pkg::*;

	class FIFO_test extends uvm_component;
		`uvm_component_utils(FIFO_test)

		// env
		FIFO_env env;
		// sequences
		FIFO_reset_sequence reset_sequence;
		FIFO_write_only_sequence write_only_sequence;
		FIFO_read_only_sequence read_only_sequence;
		FIFO_write_read_sequence write_read_sequence;
		// config object to get the if
		FIFO_config FIFO_cfg;

		function new(string name = "FIFO_test", uvm_component parent = null);
			super.new(name,parent);
		endfunction

		function void build_phase(uvm_phase phase);
			super.build_phase(phase);
			env=FIFO_env::type_id::create("env",this);
			// the following are object so there is no "this" as in slides!!!!!!!!!!
			reset_sequence=FIFO_reset_sequence::type_id::create("reset_sequence");
			write_only_sequence=FIFO_write_only_sequence::type_id::create("write_only_sequence");
			read_only_sequence=FIFO_read_only_sequence::type_id::create("read_only_sequence");
			write_read_sequence=FIFO_write_read_sequence::type_id::create("write_read_sequence");
			FIFO_cfg=FIFO_config::type_id::create("FIFO_cfg");
			// get the IF
			if (!uvm_config_db#(virtual FIFO_if)::get(this, "", "FIFO_IF", FIFO_cfg.FIFO_vif)) begin
				`uvm_fatal("build_phase", "TEST - unable to get the IF");
			end
			// set the config object (which containing the IF)
			uvm_config_db#(FIFO_config)::set(this, "*", "CFG", FIFO_cfg);
		endfunction

		task run_phase(uvm_phase phase);
			super.run_phase(phase);
			phase.raise_objection(this);
			// start the sequences
			`uvm_info("run_phase", "Reset Asserted", UVM_LOW);
			reset_sequence.start(env.agt.sqr);
			`uvm_info("run_phase", "Reset De-asserted", UVM_LOW);
			`uvm_info("run_phase", "write_only_sequence starts", UVM_LOW);
			write_only_sequence.start(env.agt.sqr);
			`uvm_info("run_phase", "write_only_sequence ends", UVM_LOW);
			`uvm_info("run_phase", "read_only_sequence starts", UVM_LOW);
			read_only_sequence.start(env.agt.sqr);
			`uvm_info("run_phase", "read_only_sequence ends", UVM_LOW);
			`uvm_info("run_phase", "write_read_sequence starts", UVM_LOW);
			write_read_sequence.start(env.agt.sqr);
			`uvm_info("run_phase", "write_read_sequence ends", UVM_LOW);
			phase.drop_objection(this);
		endtask

	endclass

endpackage