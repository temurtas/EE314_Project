module fifo (clk, rst, write_to_stack, data_in, read_from_stack, data_out, stack_full, stack_half_full, stack_empty);

  parameter	    stack_width	=   12;
  parameter    stack_height	=   8;
  parameter    stack_ptr_width	=   3;
  parameter    HF_level		=   4;

  input clk, rst, write_to_stack, read_from_stack;
  input [stack_width-1:0] data_in;
  output stack_full, stack_half_full, stack_empty;
  output [stack_width-1:0] data_out;

  reg [stack_ptr_width-1:0] read_ptr, write_ptr;
  reg [stack_ptr_width:0] ptr_gap;  // Gap between the pointers
  reg [stack_width-1:0] data_out;
  reg [stack_width:0] stack [stack_height-1:0];

  // stack status signals
  assign stack_full = (ptr_gap == stack_height);
  assign stack_half_full = (ptr_gap == HF_level); 
  assign stack_empty = (ptr_gap == 0);
  
  always @ (posedge clk or posedge rst)
     if (rst == 1) begin
        data_out <= 0;
        read_ptr <= 0;
        write_ptr <= 0;
        ptr_gap   <= 0; 
     end 
     else if (write_to_stack && (!read_from_stack) && (!stack_full)) begin
        stack [write_ptr] <= data_in;
        write_ptr <= write_ptr + 1;
        ptr_gap   <= ptr_gap + 1;
     end
     else if ((!write_to_stack) && read_from_stack && (!stack_empty)) begin
        data_out <= stack[read_ptr];
        read_ptr  <= read_ptr + 1;
        ptr_gap   <= ptr_gap - 1;
     end 
     else if (write_to_stack && read_from_stack && stack_empty) begin
        stack [write_ptr] <= data_in;
        write_ptr <= write_ptr + 1;
        ptr_gap   <= ptr_gap + 1;
     end
else if (write_to_stack && read_from_stack && stack_full) begin
        data_out <= stack[read_ptr];
        read_ptr <= read_ptr + 1;
        ptr_gap   <= ptr_gap - 1;
     end
     else if (write_to_stack && read_from_stack && (!stack_empty) && (!stack_full)) begin
        stack [write_ptr] <= data_in;
        data_out <= stack[read_ptr];
        write_ptr <= write_ptr + 1;
        read_ptr  <= read_ptr + 1;
     end
	 
endmodule 
