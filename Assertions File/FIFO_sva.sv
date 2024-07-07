module FIFO_sva(FIFO_if.DUT f_if, input [f_if.max_fifo_addr:0] count);

// if count equals to FIFO depth then full is asserted 
full_assert: assert property (@(posedge f_if.clk) (count==f_if.FIFO_DEPTH) |-> f_if.full);

// if count equals to 0 depth then empty is asserted 
empty_assert: assert property (@(posedge f_if.clk) (count==0) |-> f_if.empty);

// if count equals to FIFO depth - 1 then almostfull is asserted 
almostfull_assert: assert property (@(posedge f_if.clk) (count==f_if.FIFO_DEPTH-1) |-> f_if.almostfull);

// if count equals to 1 then almostempty is asserted 
almostempty_assert: assert property (@(posedge f_if.clk) (count==1) |-> f_if.almostempty);

// if the FIFO isn't full and write enable is HIGH then wr_ack is asserted 
wr_ack_assert: assert property (@(posedge f_if.clk) disable iff(!f_if.rst_n) (f_if.wr_en&&count < f_if.FIFO_DEPTH) |=> f_if.wr_ack);

// if the FIFO is full and write enable is HIGH then overflow is asserted 
overflow_assert: assert property (@(posedge f_if.clk) disable iff(!f_if.rst_n) (f_if.wr_en&&f_if.full) |=> f_if.overflow);

// if the FIFO is empty and read enable is HIGH then underflow is asserted 
underflow_assert: assert property (@(posedge f_if.clk) disable iff(!f_if.rst_n) (f_if.rd_en&&f_if.empty) |=> f_if.underflow);

// if the FIFO isn't full and write enable is HIGH then count will be incremented
count_up_assert: assert property (@(posedge f_if.clk) disable iff(!f_if.rst_n) ({f_if.wr_en,f_if.rd_en}==2'b10 && !f_if.full) |=> count==$past(count)+1);

// if the FIFO isn't empty and read enable is HIGH then count will be decremented
count_down_assert: assert property (@(posedge f_if.clk) disable iff(!f_if.rst_n) (({f_if.wr_en,f_if.rd_en}==2'b01) && !f_if.empty) |=> count==$past(count)-1);

// empty shouldn't be HIGH if write enable is 1 
wr_empty_assert: assert property (@(posedge f_if.clk) disable iff(!f_if.rst_n) (f_if.wr_en) |=> !f_if.empty);

// full shouldn't be HIGH if read enable is 1 
rd_full_assert: assert property (@(posedge f_if.clk) (f_if.rd_en) |=> !f_if.full);

// overflow shouldn't be HIGH if write enable is 0
wr_overflow_assert: assert property (@(posedge f_if.clk) (!f_if.wr_en) |=> !f_if.overflow);

// underflow shouldn't be HIGH if read enable is 0
rd_underflow_assert: assert property (@(posedge f_if.clk) (!f_if.rd_en) |=> !f_if.underflow);

// write ack shouldn't be HIGH if write enable is 0
wr_wr_ack_assert: assert property (@(posedge f_if.clk) (!f_if.wr_en) |=> !f_if.wr_ack);

// if almostfull is HIGH and wr_en only is HIGH then the next cycle full will be HIGH
almostfull_full_assert: assert property (@(posedge f_if.clk) disable iff(!f_if.rst_n) (f_if.almostfull && f_if.wr_en && !f_if.rd_en) |=> f_if.full);

// if almostempty is HIGH and rd_en only is HIGH then the next cycle empty will be HIGH
almostempty_empty_assert: assert property (@(posedge f_if.clk) disable iff(!f_if.rst_n) (f_if.almostempty && f_if.rd_en && !f_if.wr_en) |=> f_if.empty);

// Cover Directives
full_cover: cover property (@(posedge f_if.clk) (count==f_if.FIFO_DEPTH) |-> f_if.full);
empty_cover: cover property (@(posedge f_if.clk) (count==0) |-> f_if.empty);
almostfull_cover: cover property (@(posedge f_if.clk) (count==f_if.FIFO_DEPTH-1) |-> f_if.almostfull);
almostempty_cover: cover property (@(posedge f_if.clk) (count==1) |-> f_if.almostempty);
wr_ack_cover: cover property (@(posedge f_if.clk) disable iff(!f_if.rst_n) (f_if.wr_en&&count < f_if.FIFO_DEPTH) |=> f_if.wr_ack);
overflow_cover: cover property (@(posedge f_if.clk) disable iff(!f_if.rst_n) (f_if.wr_en&&f_if.full) |=> f_if.overflow);
underflow_cover: cover property (@(posedge f_if.clk) disable iff(!f_if.rst_n) (f_if.rd_en&&f_if.empty) |=> f_if.underflow);
count_up_cover: cover property (@(posedge f_if.clk) disable iff(!f_if.rst_n) ({f_if.wr_en,f_if.rd_en}==2'b10 && !f_if.full) |=> count==$past(count)+1);
count_down_cover: cover property (@(posedge f_if.clk) disable iff(!f_if.rst_n) (({f_if.wr_en,f_if.rd_en}==2'b01) && !f_if.empty) |=> count==$past(count)-1);
wr_empty_cover: cover property (@(posedge f_if.clk) disable iff(!f_if.rst_n) (f_if.wr_en) |=> !f_if.empty);
rd_full_cover: cover property (@(posedge f_if.clk) (f_if.rd_en) |=> !f_if.full);
wr_overflow_cover: cover property (@(posedge f_if.clk) (!f_if.wr_en) |=> !f_if.overflow);
rd_underflow_cover: cover property (@(posedge f_if.clk) (!f_if.rd_en) |=> !f_if.underflow);
wr_wr_ack_cover: cover property (@(posedge f_if.clk) (!f_if.wr_en) |=> !f_if.wr_ack);
almostfull_full_cover: cover property (@(posedge f_if.clk) disable iff(!f_if.rst_n) (f_if.almostfull && f_if.wr_en && !f_if.rd_en) |=> f_if.full);
almostempty_empty_cover: cover property (@(posedge f_if.clk) disable iff(!f_if.rst_n) (f_if.almostempty && f_if.rd_en && !f_if.wr_en) |=> f_if.empty);
endmodule