//Team2: Kedhar Vatsan Akshatha Pravalika
`timescale 1ns / 1ps

module sevenSegmentDisplayController(
    input            clock_100Mhz,             // 100 Mhz clock source on Nexys A7 FPGA
    input            reset,                    // reset
    input            init,
    input            done,
    input     [15:0] value,
    output reg [7:0] Anode_Activate, // anode signals of the 7-segment LED display
    output reg [6:0] LED_out// cathode patterns of the 7-segment LED display
);

    reg [3:0] LED_BCD;
    reg [19:0] refresh_counter; 
    // 20-bit for creating 10.5ms refresh period or 380Hz refresh rate
    // the first 2 MSB bits for creating 4 LED-activating signals with 2.6ms digit period
    wire [1:0] LED_activating_counter, timeslot; 
            //   count       0    ->  1  ->  2  ->  3
            // activates    LED1    LED2   LED3   LED4
    always @(posedge clock_100Mhz or negedge reset)
    begin 
        if(!reset)
            refresh_counter <= 0;
		else
            refresh_counter <= refresh_counter + 1;
    end 
//    assign LED_activating_counter = refresh_counter[1:0]; //simulation
    assign LED_activating_counter = refresh_counter[19:18]; //emulation
    assign timeslot = LED_activating_counter%4;
    // anode activating signals for 4 LEDs, digit period of 2.6ms
    // decoder to generate anode signals 
    
    always @(*)
    begin
        if(!reset) begin
            LED_BCD         =   4'b0;
            Anode_Activate  =   4'b0;
        end else if (timeslot == 0) begin
		    LED_BCD           = value[15:12]; 
		    Anode_Activate    = 8'b01111111;    // activate LED1 and Deactivate LED2, LED3, LED4
          end
        else if (timeslot == 1) begin
            LED_BCD         = value[11:8]; 
            Anode_Activate  = 8'b10111111;  // activate LED2 and Deactivate LED1, LED3, LED4
            end
        else if (timeslot == 2) begin
            LED_BCD         = value[7:4]; 
            Anode_Activate  = 8'b11011111;  // activate LED3 and Deactivate LED2, LED1, LED4
            end
         else begin
            LED_BCD         = value[3:0]; 
            Anode_Activate  = 8'b11101111;  // activate LED4 and Deactivate LED2, LED3, LED1
            end
    end

    // Cathode patterns of the 7-segment LED display 
    always @ (*) begin
        if (init) begin
            if(timeslot == 0) 
                    LED_out = 7'b111_1001;    //I("1")
            else if (timeslot == 1)
                    LED_out = 7'b010_1011;    //n
            else if (timeslot == 2)
                    LED_out = 7'b110_1111;    //i
            else    LED_out = 7'b000_0111;    //t
        end 
        else if (done) begin
            if(timeslot == 0) 
                    LED_out = 7'b010_0001;    //d
            else if (timeslot == 1)
                    LED_out = 7'b010_0011;     //o
            else if (timeslot == 2)
                    LED_out = 7'b010_1011;    //n
            else    LED_out = 7'b000_0110;    //E
        end 
        else case(LED_BCD)
            4'b0000: LED_out = 7'b100_0000;    // digit 0
            4'b0001: LED_out = 7'b111_1001;    // digit 1
            4'b0010: LED_out = 7'b010_0100;    // digit 2
            4'b0011: LED_out = 7'b011_0000;    // digit 3
            4'b0100: LED_out = 7'b001_1001;    // digit 4
            4'b0101: LED_out = 7'b001_0010;    // digit 5
            4'b0110: LED_out = 7'b000_0010;    // digit 6
            4'b0111: LED_out = 7'b111_1000;    // digit 7
            4'b1000: LED_out = 7'b000_0000;    // digit 8
            4'b1001: LED_out = 7'b001_0000;    // digit 9
            4'b1010: LED_out = 7'b000_1000;    // digit A
            4'b1011: LED_out = 7'b000_0011;    // digit B
            4'b1100: LED_out = 7'b100_0110;    // digit C
            4'b1101: LED_out = 7'b010_0001;    // digit d
            4'b1110: LED_out = 7'b000_0110;    // digit E
            4'b1111: LED_out = 7'b000_1110;    // digit F
            default: LED_out = 7'b0111100;    // letter n
        endcase
    end
 endmodule