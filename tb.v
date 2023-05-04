`timescale 1ns / 1ps

module tb();
    
reg clock;
reg reset;
reg pushButton;
wire [6:0] segActive;
wire [7:0] Anode_Activate;

//top dut(clock, reset, pushButton, segActive, Anode_Activate);

    
initial forever #1 clock = !clock;

initial begin
    clock = 1;
    reset = 1;
    pushButton = 0;
    
    #11 reset = 0;
    #12 reset = 1;
end

initial begin
    #20000     pushButton = 1;
    #1000     pushButton = 0;
    #20000     pushButton = 1;
    #1000     pushButton = 0;
    #10000     pushButton = 1;
    #1000     pushButton = 0;
    #20000     pushButton = 1;
    #1000     pushButton = 0;
    #20000   $finish();

end

endmodule