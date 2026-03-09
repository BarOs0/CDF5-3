`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: 
// 
// Create Date: 03/06/2026 10:58:57 AM
// Design Name: 
// Module Name: cdf_5_3
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


module cdf_5_3 #(

    parameter DATA_LEN = 16
)(
    
    // Controls
    input clk,
    input reset,
    
    // Data input
    input [DATA_LEN-1:0] input_data,
    
    // Flags for the algorithm (MCU generated)
    input wire first_odd,
    input wire first_even,
    input wire last_even_minus_one,
    input wire last_odd,
    
    // Output data
    output reg [DATA_LEN-1:0] approx,
    output reg [DATA_LEN-1:0] detail,
    output reg done
    );
    
    // Data buffer
    // buff = [even_curr, odd_prev, even_next, odd_curr]
    reg signed [DATA_LEN-1:0] buff [3:0];
    reg [1:0] idx = 2'd0;
    reg start;
    
    //        even <=> approx
    //        odd <=> detail
    
    always @(posedge clk or posedge reset) begin
    
    buff[idx] <= input_data;
    idx <= idx + 2'd1;
    
    if (idx == 2'd3) begin
        start <= 1;
    end
    
        if(reset) begin
            
            buff[0] <= 0;
            buff[1] <= 0;
            buff[2] <= 0;
            buff[3] <= 0;
            
            idx <= 0;
            done <= 0;
            
        end else if (start) begin
        
            // === PREDICT ===
            if (first_odd) begin
                buff[3] <= buff[3] - buff[0];
            end else if (last_even_minus_one) begin
                buff[3] <= buff[3] - ((buff[0] + buff[2]) >>> 1);
            end else begin
                buff[3] <= buff[3] - buff[0];
            end
            
            // === UPDATE === 
            if (first_even) begin
                buff[0] <= buff[0] + (buff[3] >>> 1);
            end else if (last_odd) begin
                buff[0] <= buff[0] + ((buff[1] + buff[3]) >>> 2);
            end else begin
                buff[0] <= buff[0] + (buff[1] >>> 1);
            end
        
            done <= 1;
        end
    end
    
endmodule
