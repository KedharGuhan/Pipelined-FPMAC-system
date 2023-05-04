module sFifo(
    input           clock,
    input           reset,

    input           wen,
    input   [15: 0] wdata,

    input           ren,
    output reg [15:0]  rdata,


    output          full,
    output          empty,

    output reg [3:0] writePtr,
    output reg [3:0] readPtr
);


    reg [15:0] SRAM [0:15];
    reg filling, emptying;

    always @ (posedge clock, negedge reset) begin
        if(!reset) begin
            writePtr    <= 16'b0;
            readPtr     <= 16'b0;
            filling     <= 0;
            emptying    <= 0;
            //turn this off later
//            SRAM        <= 0;
            //
        end else begin
            //Write
            if(wen & !ren & !full) begin
                writePtr <= writePtr + 1;
                filling  <= 1;
                emptying <= 0;
            end

            //Read
            if(ren & !wen & !empty) begin
                readPtr <= readPtr + 1;
                emptying <= 1;
                filling <= 0;
            end
        end
    end

 //   always @ (posedge clock) begin
    always @ (*) begin
        if(wen & !full)
            SRAM[writePtr] = wdata;
        
        if(ren) 
            rdata = SRAM[readPtr];
         else rdata = rdata;
     end

    assign full  = ((writePtr == readPtr) && filling)? 1 : 0;
    assign empty = ((writePtr == readPtr) && emptying)? 1 : 0;

endmodule