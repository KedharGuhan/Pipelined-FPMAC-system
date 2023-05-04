`timescale 1ns / 1ps

module top(
    input clock,
    input reset,
    input pushButton,
    output [6:0] segActive,
    output [7:0] Anode_Activate
    );

    wire slow_clock;
    wire pushButtonValid;

    wire mem_enable;
    wire [3:0] memory_readAddr, fifo_readAddr;
    reg [3:0] fifo_readAddr_prev;

    wire fifo_full, fifo_empty; 
    wire fifo_rst, fifo_writeEnable, fifo_readEnable;
    

    wire [15:0] FPMAC_numA;
    reg  [15:0] FPMAC_numB;
    reg [1:0] MAC_latency_compensate;
    reg fifo_empty_prev;
    wire MAC_acivation;
    wire MAC_Enable;
    wire [3:0] acc_count;
    wire [15:0] FPMAC_result, displayValue, memory_readData;

    wire SSD_ctrl_rst;   
    wire init, done;

    wire value_sel;

    assign displayValue = value_sel ? FPMAC_result : memory_readData;
 
    clock_divider clock_divider_1Hz(clock, reset, slow_clock);

    pushButtonValidator PBValidator(slow_clock, reset, pushButton, pushButtonValid);

    SRAM memory(
        .clock(slow_clock),
        .writeEn(1'b0),
        .readEn(mem_enable),
        .address(memory_readAddr),
        .writeData(16'b0),
        .readData(memory_readData)
        );


    sFifo FIFO(
    	.clock(slow_clock), 
    	.reset(~fifo_rst), 
    	.wen(fifo_writeEnable), 
    	.wdata(memory_readData), 
    	.ren(fifo_readEnable), 
    	.rdata(FPMAC_numA), 
    	.full(fifo_full), 
    	.empty(fifo_empty),
        .writePtr(memory_readAddr),
        .readPtr(fifo_readAddr)
        );

    always@(posedge slow_clock, negedge reset) begin
        if(!reset)
            FPMAC_numB  <= 16'b0;
        else 
            FPMAC_numB  <= FPMAC_numA;
    end
       
     //clock-gating + activation
     assign MAC_acivation = ((fifo_readAddr%2) & MAC_Enable) | MAC_latency_compensate;
     
     always@(posedge slow_clock, negedge reset) begin
         if(!reset) begin
            MAC_latency_compensate  <= 2'd0;
            fifo_empty_prev         <= 1'b0;
         end else begin 
            fifo_empty_prev         <= fifo_empty;
            if(!fifo_empty)
                MAC_latency_compensate <= 0;
            else begin
                if((fifo_empty == 1) & (fifo_empty_prev == 0))
                     MAC_latency_compensate <= 2'd3;
                 else if(MAC_latency_compensate != 0)
                    MAC_latency_compensate <= MAC_latency_compensate -1;
            end  
         end
     end   
      
    MAC FPMAC(
        .numA(FPMAC_numA),
        .numB(FPMAC_numB),
        .clk(slow_clock), 
        .Asynch_Reset(~reset),      //reset_n to reset
        .MAC_activate(MAC_acivation),
        .ACC_Result(FPMAC_result),
        .acc_count(acc_count)
        ); 

    sevenSegmentDisplayController SSD_ctrl(
        .clock_100Mhz   (clock),            
        .reset          (~SSD_ctrl_rst),
        .init           (init),
        .done           (done),
        .value          (displayValue),
        .Anode_Activate (Anode_Activate), 
        .LED_out        (segActive)
        );

    fsm_controller fsm(
        .clock(slow_clock), .reset(reset), .PB(pushButtonValid), 
        .full(fifo_full), .empty(fifo_empty), .mem_enable(mem_enable),
    //    .mem_reset(mem_reset),  
        .fifo_reset(fifo_rst), .fifo_writeEnable(fifo_writeEnable), 
        .fifo_readEnable(fifo_readEnable), 
        .FPMAC_Enable(MAC_Enable), .acc_count(acc_count),
        .SSDController_rst(SSD_ctrl_rst), 
        .init(init), .done(done), .value_sel(value_sel)
        );

endmodule
