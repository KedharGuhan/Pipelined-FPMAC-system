`timescale 1ns / 1ps

module pushButtonValidator(
    input clock,
    input reset,
    input pushButton,
    output reg pushButtonValid
);

    reg pushButton_delay1;
    
    always@(posedge clock, negedge reset) begin
        if(!reset)
            pushButton_delay1 <= 0;
        else pushButton_delay1 <= pushButton;
    end

    always@(posedge clock, negedge reset) begin
        if(!reset)
            pushButtonValid <= 0;
        else if(pushButton & !pushButton_delay1)
                pushButtonValid <= 1;
            else pushButtonValid <= 0;
    end

endmodule