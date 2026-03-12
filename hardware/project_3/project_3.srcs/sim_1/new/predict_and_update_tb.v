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
    localparam DATA_LEN = 32;
    localparam X_LEN = 16;
    localparam NULL = 32'd0;
    localparam RDM_RANGE = 32'h000F;
    
    reg clk;
    reg reset;
    reg signed [DATA_LEN-1:0] data_in;
    wire signed [DATA_LEN-1:0] update_approx;
    
    wire update_done;
    wire data_in_ready;
    
    wire last_predict;
    wire last_update;
    
    reg signed [DATA_LEN-1:0] x [0:X_LEN-1];
    integer i;
    
    reg last_sample = 0;
    
    reg data_valid = 0;
    
    predict_and_update uut (
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .last_sample(last_sample),
        .data_valid(data_valid),
        .update_approx(update_approx),
        .update_done(update_done),
        .data_in_ready(data_in_ready),
        .last_update(last_update),
        .last_predict(last_predict)
    );
    
    always #5 clk = ~clk;
    
    initial begin
    
    for (i = 0; i < X_LEN; i = i + 1) begin
        x[i] = $urandom & RDM_RANGE;
//        x[i] <= i; // index debug
    end

        clk = 0;
        reset = 1;
        data_in = NULL;
        
        #10 reset = 0;
        @(posedge clk);

        data_valid <= 1;
        for (i = 0; i < X_LEN; i = i + 1) begin
            if (i == X_LEN - 1) begin
                last_sample <= 1;
            end
       
            data_in <= x[i];
            @(posedge clk);
        end
        
        last_sample <= 0;
        data_valid <= 0;
        @(posedge clk);
    end
endmodule
