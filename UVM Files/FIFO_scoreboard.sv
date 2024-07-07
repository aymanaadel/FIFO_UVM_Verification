package FIFO_scoreboard_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"
import FIFO_seq_item_pkg::*;

	class FIFO_scoreboard extends uvm_scoreboard;
		`uvm_component_utils(FIFO_scoreboard)

		uvm_analysis_export #(FIFO_seq_item) sb_export;
		uvm_tlm_analysis_fifo #(FIFO_seq_item) sb_fifo;

		FIFO_seq_item seq_item_sb;

		// golden/reference outputs
		parameter FIFO_WIDTH = 16;
		parameter FIFO_DEPTH = 8;
		logic [FIFO_WIDTH-1:0] data_out_ref;
		bit wr_ack_ref, overflow_ref;
		bit full_ref, empty_ref, almostfull_ref, almostempty_ref, underflow_ref;
		int error_count=0, correct_count=0;
		// queue to use it as a golden model for FIFO
		typedef logic [FIFO_WIDTH-1:0] FIFO_word;
		FIFO_word FIFO_que[$];

		function new(string name = "FIFO_scoreboard", uvm_component parent = null);
			super.new(name,parent);
		endfunction

		function void build_phase(uvm_phase phase);
			super.build_phase(phase);
			sb_export=new("sb_export",this);
			sb_fifo=new("sb_fifo",this);
		endfunction

		function void connect_phase(uvm_phase phase);
			super.connect_phase(phase);
			sb_export.connect(sb_fifo.analysis_export);
		endfunction

		task run_phase(uvm_phase phase);
			super.run_phase(phase);
			forever begin
				sb_fifo.get(seq_item_sb);
				check_data(seq_item_sb);
			end
		endtask

		function void report_phase(uvm_phase phase);
			super.report_phase(phase);
			`uvm_info("report_phase", $sformatf("At time %0t: Simulation Ends and Error Count= %0d, Correct Count= %0d", $time, error_count, correct_count), UVM_MEDIUM);
		endfunction

		function void check_data(FIFO_seq_item F_cd);
			reference_model(F_cd);
			outputs_check_assert: 
			assert(
				data_out_ref===F_cd.data_out &&
				wr_ack_ref===F_cd.wr_ack &&
				overflow_ref===F_cd.overflow &&
				full_ref===F_cd.full &&
		     	empty_ref===F_cd.empty &&
				almostfull_ref===F_cd.almostfull && 
			   	almostempty_ref===F_cd.almostempty &&
				underflow_ref===F_cd.underflow
			) begin

				correct_count++; 
			end
			else begin
				error_count++;
				`uvm_error("run_phase", "Comparison Error");
			end

			outputs_check_cover: cover(
				data_out_ref===F_cd.data_out &&
				wr_ack_ref===F_cd.wr_ack &&
				overflow_ref===F_cd.overflow &&
				full_ref===F_cd.full &&
		     	empty_ref===F_cd.empty &&
				almostfull_ref===F_cd.almostfull && 
			   	almostempty_ref===F_cd.almostempty &&
				underflow_ref===F_cd.underflow
			);
		endfunction

		function void reference_model(FIFO_seq_item F_rm);

			if (!F_rm.rst_n) begin
				FIFO_que.delete();
				underflow_ref=0;  overflow_ref=0; 
				wr_ack_ref=0;
			end 
			else begin
				// read only & not empty
				if ( {F_rm.wr_en,F_rm.rd_en} == 2'b01 && FIFO_que.size() != 0 ) begin
					data_out_ref=FIFO_que.pop_front(); wr_ack_ref=0;
				end 
				// write only & not full
				else if ( {F_rm.wr_en,F_rm.rd_en} == 2'b10 && FIFO_que.size() != FIFO_DEPTH ) begin
					FIFO_que.push_back(F_rm.data_in); wr_ack_ref=1;
				end
				// both read and write & (full, empty, not full or empty)
				else if ( {F_rm.wr_en,F_rm.rd_en} == 2'b11 ) begin
					if (FIFO_que.size() == FIFO_DEPTH) begin
						data_out_ref=FIFO_que.pop_front(); wr_ack_ref=0;
					end else if (FIFO_que.size() == 0) begin
						FIFO_que.push_back(F_rm.data_in); wr_ack_ref=1;
					end else begin
						FIFO_que.push_back(F_rm.data_in); wr_ack_ref=1;
						data_out_ref=FIFO_que.pop_front();
					end
				end 
				else begin
					 wr_ack_ref=0;
				end


			end
			underflow_ref = (!F_rm.rst_n)? 0:(empty_ref && F_rm.rd_en)? 1 : 0;
			overflow_ref  =	(!F_rm.rst_n)? 0:(full_ref  && F_rm.wr_en)? 1 : 0;
			full_ref = (FIFO_que.size() == FIFO_DEPTH)? 1 : 0;
			empty_ref = (FIFO_que.size() == 0)? 1 : 0;
			almostfull_ref = (FIFO_que.size() == FIFO_DEPTH-1)? 1 : 0; 
			almostempty_ref = (FIFO_que.size() == 1)? 1 : 0;
		endfunction

	endclass

endpackage