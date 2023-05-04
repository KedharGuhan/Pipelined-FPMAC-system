`timescale 1ns / 1ps

module clock_divider(
	input clock, 
	input reset, 
	output reg slow_clock
);

//parameter clock_limit = 100;          //simulation
parameter clock_limit = 100000000/10;    //emulation

reg [29:0] clk_counter;

always @(posedge clock or negedge reset) begin 
	if(!reset) begin
		clk_counter <= 30'b0;
		slow_clock	<= 1'b0;
	end else if (clk_counter == clock_limit) begin 
			clk_counter <= 0;
			slow_clock <= ~slow_clock; 
	end else 
			clk_counter <= clk_counter+1;
end

endmodule
