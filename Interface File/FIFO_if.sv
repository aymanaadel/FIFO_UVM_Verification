interface FIFO_if (input bit clk);
	parameter FIFO_WIDTH = 16;
	parameter FIFO_DEPTH = 8;
	parameter max_fifo_addr = $clog2(FIFO_DEPTH);

	// Design inputs
	logic [FIFO_WIDTH-1:0] data_in;
	logic rst_n, wr_en, rd_en;
	// Design outputs
	logic [FIFO_WIDTH-1:0] data_out;
	logic wr_ack, overflow;
	logic full, empty, almostfull, almostempty, underflow;

	// DUT modport
	modport DUT(
		input clk, data_in, rst_n, wr_en, rd_en,
		output data_out,wr_ack,overflow, full, empty, almostfull, almostempty, underflow
	);
	
endinterface