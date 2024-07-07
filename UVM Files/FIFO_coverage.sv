package FIFO_coverage_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"
import FIFO_seq_item_pkg::*;

	class FIFO_coverage extends uvm_component;
		`uvm_component_utils(FIFO_coverage)

		uvm_analysis_export #(FIFO_seq_item) cov_export;
		uvm_tlm_analysis_fifo #(FIFO_seq_item) cov_fifo;

		FIFO_seq_item seq_item_cov;

		covergroup cvr_grp;
			// Required cross coverage between 3 signals which are wr_en, rd_en and each output control signals
			wr_en_cp: coverpoint seq_item_cov.wr_en {option.weight = 0;}
			rd_en_cp: coverpoint seq_item_cov.rd_en {option.weight = 0;}
			W_R_with_wr_ack_cross: 		cross wr_en_cp, rd_en_cp, seq_item_cov.wr_ack;
			W_R_with_overflow_cross: 	cross wr_en_cp, rd_en_cp, seq_item_cov.overflow;
			W_R_with_full_cross: 		cross wr_en_cp, rd_en_cp, seq_item_cov.full;
			W_R_with_empty_cross: 		cross wr_en_cp, rd_en_cp, seq_item_cov.empty;
			W_R_with_almostfull_cross: 	cross wr_en_cp, rd_en_cp, seq_item_cov.almostfull;
			W_R_with_almostempty_cross: cross wr_en_cp, rd_en_cp, seq_item_cov.almostempty;
			W_R_with_underflow_cross: 	cross wr_en_cp, rd_en_cp, seq_item_cov.underflow;

			// Additional cover points and cross coverage
			full_cp: coverpoint seq_item_cov.full {bins full_HIGH= {1}; option.weight = 0;}
			empty_cp: coverpoint seq_item_cov.empty {bins empty_HIGH= {1}; option.weight = 0;}
			overflow_cp: coverpoint seq_item_cov.overflow {bins overflow_HIGH= {1}; option.weight = 0;}
			underflow_cp: coverpoint seq_item_cov.underflow {bins underflow_HIGH= {1}; option.weight = 0;}
			wr_ack_cp: coverpoint seq_item_cov.wr_ack {bins wr_ack_HIGH= {1}; option.weight = 0;}

			// empty shouldn't be HIGH if write enable is 1 
			wr_empty_cross: cross wr_en_cp, empty_cp iff (seq_item_cov.rst_n) {
				option.cross_auto_bin_max=0;
				illegal_bins ill_1 = binsof(wr_en_cp) intersect {1} && binsof(empty_cp.empty_HIGH);
			}
			// full shouldn't be HIGH if read enable is 1 
			rd_full_cross: cross rd_en_cp, full_cp {
				option.cross_auto_bin_max=0;
				illegal_bins ill_2 = binsof(rd_en_cp) intersect {1} && binsof(full_cp.full_HIGH);
			}
			// overflow shouldn't be HIGH if write enable is 0 
			wr_overflow_cross: cross wr_en_cp, overflow_cp {
				option.cross_auto_bin_max=0;
				illegal_bins ill_3 = binsof(wr_en_cp) intersect {0} && binsof(overflow_cp.overflow_HIGH);
			}
			// underflow shouldn't be HIGH if read enable is 0 
			rd_underflow_cross: cross rd_en_cp, underflow_cp {
				option.cross_auto_bin_max=0;
				illegal_bins ill_4 = binsof(rd_en_cp) intersect {0} && binsof(underflow_cp.underflow_HIGH);
			}
			// write ack shouldn't be HIGH if write enable is 0
			wr_wr_ack_cross: cross wr_en_cp, wr_ack_cp {
				option.cross_auto_bin_max=0;
				illegal_bins ill_5 = binsof(wr_en_cp) intersect {0} && binsof(wr_ack_cp.wr_ack_HIGH);
			}
		endgroup

		function new(string name = "FIFO_coverage", uvm_component parent = null);
			super.new(name,parent);
			cvr_grp=new();
		endfunction

		function void build_phase(uvm_phase phase);
			super.build_phase(phase);
			cov_export=new("cov_export",this);
			cov_fifo=new("cov_fifo",this);
		endfunction

		function void connect_phase(uvm_phase phase);
			super.connect_phase(phase);
			cov_export.connect(cov_fifo.analysis_export);
		endfunction

		task run_phase(uvm_phase phase);
			super.run_phase(phase);
			forever begin
				cov_fifo.get(seq_item_cov);
				cvr_grp.sample();
			end
		endtask

	endclass
endpackage