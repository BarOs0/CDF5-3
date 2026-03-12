`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/09/2026 05:27:49 PM
// Design Name: 
// Module Name: predict_and_update_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module predict_and_update_tb(

    );
    localparam DATA_LEN = 16;
    localparam X_LEN = 16;
    localparam DUMMY_LEN = 1; // MCU must send 1 empty sample at the end
    localparam NULL = 16'd0;
    localparam RDM_RANGE = 16'h0FFF;
    
    reg clk;
    reg reset;
    reg signed [DATA_LEN-1:0] data_in;
    wire signed [DATA_LEN-1:0] update_approx;
    wire update_done;
    
    reg signed [DATA_LEN-1:0] x [0:X_LEN-1];
    reg signed [DATA_LEN-1:0] dummy [0:DUMMY_LEN-1];
    integer i;
    
    reg first_odd = 0;
    reg last_odd = 0;
    
    reg first_even = 0;
    reg last_even = 0;
    
    reg data_valid = 0;
    
    predict_and_update uut (
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .first_odd(first_odd),
        .last_odd(last_odd),
        .first_even(first_even),
        .last_even(last_even),
        .data_valid(data_valid),
        .update_approx(update_approx),
        .update_done(update_done)
    );
    
    always #5 clk = ~clk;
    
    initial begin
    
    for (i = 0; i < X_LEN; i = i + 1) begin
        x[i] = $urandom & RDM_RANGE;
//        x[i] <= i;
    end
        
    for (i = 0; i < DUMMY_LEN; i = i + 1) begin
        dummy[i] = NULL; // empty dummy
    end

        clk = 0;
        reset = 1;
        data_in = NULL;
        
        #10 reset = 0;
        @(posedge clk);

        data_valid <= 1;
        for (i = 0; i < X_LEN; i = i + 1) begin
            if(i == 0) begin
                first_odd <= 0;
                last_odd <= 0;
                first_even <= 1;
                last_even <= 0;
            end else if (i == 1) begin
                first_odd <= 1;
                last_odd <= 0;
                first_even <= 0;
                last_even <= 0;
            end else if (i == X_LEN - 1) begin
                first_odd <= 0;
                last_odd <= 1;
                first_even <= 0;
                last_even <= 0;
            end else if (i == X_LEN - 2) begin
                first_odd <= 0;
                last_odd <= 0;
                first_even <= 0;
                last_even <= 1;
            end else begin
                first_odd <= 0;
                last_odd <= 0;
                first_even <= 0;
                last_even <= 0;
            end
       
            data_in <= x[i];
            @(posedge clk);
        end
        
        for(i = 0; i < DUMMY_LEN; i = i + 1) begin
            data_in <= dummy[i]; // sending dummy - empty signal, end of the array symbol
            first_odd <= 0;
            last_odd <= 0;
            first_even <= 0;
            last_even <= 0;
            @(posedge clk);
        end
        
        data_valid <= 0;
        
        data_in <= NULL;
        repeat(3) @(posedge clk); 
    end
endmodule
