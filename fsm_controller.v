module fsm_controller(
    input clock,
    input reset,
    input PB,
    input full,
    input empty,
//    output mem_reset,
    output reg mem_enable,
    output reg fifo_reset,
    output reg fifo_writeEnable,
    output reg fifo_readEnable,
    output reg FPMAC_Enable,
    input [3:0] acc_count,
    output reg SSDController_rst,
//    output SSDController_en,
    output reg init,
    output reg done,
    output reg value_sel     //0-> mem rdata, 1-> fpmac result
);

    reg [1:0] state, prev_state; 
    reg blink;
//    reg hold_state;

    always@(posedge clock, negedge reset) begin
        if(!reset) begin
            prev_state   <= 0;
            state        <= 0;
            blink        <= 0;
        end else begin
            prev_state   <= state;
            if(PB) state <= state + 1;  //next state logic
            if(acc_count == 4'd8) 
                blink        <= ~blink;
            else blink = 0;
        end
    end

    always@(*) begin
        if(!reset) begin
 //           mem_reset           = 1'b0;
            mem_enable          = 1'b0;
            fifo_reset          = 1'b0;
            fifo_writeEnable    = 1'b0;
            fifo_readEnable     = 1'b0;
            FPMAC_Enable        = 1'b0;
            SSDController_rst   = 1'b0;
            init                = 1'b0;
            done                = 1'b0;
            value_sel           = 1'b0;
        end else begin
//            mem_reset           = 1'b0;
            mem_enable          = 1'b0;
            fifo_reset          = 1'b0;
            fifo_writeEnable    = 1'b0;
            fifo_readEnable     = 1'b0;
            FPMAC_Enable        = 1'b0;
            SSDController_rst   = 1'b0;
            init                = 1'b0;
            done                = 1'b0;
            value_sel           = 1'b0;

            case(state)
                2'b0: begin  //Reset State
                    SSDController_rst = 1;
//                    if(state != prev_state) begin
//                        mem_reset   = 1; 
                        fifo_reset  = 1;
//                    end else begin
//                        mem_reset   = 0;
//                        fifo_reset  = 0;
//                    end
                end
                2'b1: begin //SRAM init state
                    mem_enable  = 1;
                    init = 1;
                end
                2'd2: begin //FIFO Load state
                    mem_enable  = 1;
                    //value_sel = 0; 
                    if(!full)
                        fifo_writeEnable = 1;
                    else
                        done = 1; 
                end
                2'd3: begin //MAC state
                    value_sel = 1;
                    if(!empty) begin
                        fifo_readEnable = 1;
                        FPMAC_Enable    = 1;
                    if(blink)
                        done = 1;
                    else done = 0;
                    end
                end
            endcase

        end
    end

endmodule