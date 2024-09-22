module top#( parameter clk_frequency = 27_000_000 )
        (
        input sys_clk,
		input rst_n,
		output reg red,
		output reg yellow,
		output reg green
        );


    parameter count_ms = clk_frequency / 1000;
    parameter count_10000ms = count_ms * 10000 -1;
    parameter count_7000ms = count_ms * 7000 -1;
    parameter count_3000ms = count_ms * 3000 -1;
    
	// states ONE-HOT encoding
	parameter [3:0] OFF    = 4'b0001,
	                RED    = 4'b0010,
					YELLOW = 4'b0100,
					GREEN  = 4'b1000;
					
	reg [3:0] state;      
	reg [3:0] next_state; 
	
	reg [31:0] timer; 
    reg       timer_clear;
	
	// Next state logic
	always @(*) begin
	    next_state  = OFF;     // default values
		red         = 0;
		yellow      = 0;
		green       = 0;
		timer_clear = 0;
	    case (state)
		    OFF           : begin
                                next_state = RED;
							end
		    RED           : begin
								red = 1;
								if (timer == count_10000ms) begin
									next_state  = YELLOW;
									timer_clear = 1;
								end else begin
									next_state = RED;
								end
							end
		    YELLOW         : begin
								yellow = 1;
								if (timer == count_3000ms) begin
									next_state = GREEN;
									timer_clear = 1;
								end else begin
									next_state = YELLOW;
								end
							end
		    GREEN         : begin
								green = 1;
								if (timer == count_7000ms) begin
									next_state = RED;
									timer_clear = 1;
								end else begin
									next_state = GREEN;
								end 
							end 							
		    default: next_state = OFF; 
		endcase
		
	end
	
	// State sequencer logic
	always @(posedge sys_clk or negedge rst_n) begin
	    if(!rst_n)
		    state <= OFF;
	    else
		    state <= next_state;
	end
	
	// Timer logic
	always @(posedge sys_clk or negedge rst_n) begin
	    if(!rst_n)
		    timer <= 32'd0;
	    else if (timer_clear == 1) 
		    timer <= 32'd0;
	    else if (state != OFF)  
		    timer <= timer + 1'b1; 
	end
	
endmodule
