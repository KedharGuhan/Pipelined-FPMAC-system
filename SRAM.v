`timescale 1ns / 1ps

module SRAM (
    input clock,
//    input reset,
    input                writeEn,
    input                readEn,
    input       [3:0]    address,
    input       [15:0]   writeData,
    output      [15:0]   readData
);

    reg [15:0] ram [15:0]; 
    
    //initializing
    integer i;
    initial begin
             ram[0] = 16'hB800;
             ram[1] = 16'hC000;
             ram[2] = 16'h3800;
             ram[3] = 16'h4000;
             ram[4] = 16'h3400;
             ram[5] = 16'h4400;
             ram[6] = 16'hB400;
             ram[7] = 16'hC400;
             ram[8] = 16'h3A00;
             ram[9] = 16'h3D55;
             ram[10] = 16'hBA00;
             ram[11] = 16'hBD55;
             ram[12] = 16'hB000;
             ram[13] = 16'hC800;
             ram[14] = 16'h3000;
             ram[15] = 16'h4800;
    end
    

    always@(posedge clock) begin
        if(writeEn)        //0 - no write, 1 - write
                ram[address] <= writeData;
    end

    assign  readData = readEn ? ram[address] : 16'b0;


endmodule