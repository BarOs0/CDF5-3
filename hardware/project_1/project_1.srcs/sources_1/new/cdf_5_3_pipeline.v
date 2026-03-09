`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/06/2026 01:08:33 PM
// Design Name: 
// Module Name: cdf_5_3_pipeline
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


module cdf_5_3_pipeline #(

    parameter DATA_LEN = 16
)(
    // Controls
    input clk,
    input reset,
    
    // Data input
    input [DATA_LEN-1:0] input_data,
    
    // Data valid flag (MCU generated)
    input wire data_valid,
    
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
    
    // State machine
    localparam IDLE = 2'd0;
    localparam COLLECT_EVEN = 2'd1;
    localparam COLLECT_ODD = 2'd2;
    localparam WAVELET = 2'd3;
    reg [1:0] state = IDLE;
    
    // Data buffers
    reg signed [DATA_LEN-1:0] even_next;
    reg signed [DATA_LEN-1:0] even_curr;
    reg signed [DATA_LEN-1:0] odd_prev;
    reg signed [DATA_LEN-1:0] odd_curr;
    
    reg signed [DATA_LEN-1:0] predicted_detail;
    reg signed [DATA_LEN-1:0] updated_approx;
    
    reg even_odd_toggle;
    
    always @(posedge clk or posedge reset) begin
        
        if (reset) begin
        
            state <= IDLE;
            
            even_next <= 0;
            even_curr <= 0;
            odd_prev <= 0;
            odd_curr <= 0;
            
            predicted_detail <= 0;
            updated_approx <= 0;
            
            even_odd_toggle <= 0;
            
        end
        
        case(state)
            
            // [even_curr, odd_prev, even_next, odd_curr]
            
            IDLE: begin
                done <= 0;
                if (data_valid) begin
                    even_curr <= input_data;
                    state <= COLLECT_ODD;
                end
            end
                
            COLLECT_ODD: begin
                if (data_valid) begin
                    
                end
            end
        
        
    
    end
    
endmodule
