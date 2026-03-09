`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/06/2026 05:34:44 PM
// Design Name: 
// Module Name: cdf_5_3_pipe
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


module cdf_5_3_pipe #(
    parameter DATA_LEN = 16
)(
    // Controls
    input clk,
    input reset,
    input valid_in,  // Input data valid signal
    
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
    output reg valid_out
);

    // Pipeline registers
    // buff = [even_curr, odd_prev, even_next, odd_curr]
    reg signed [DATA_LEN-1:0] even_curr;
    reg signed [DATA_LEN-1:0] odd_prev;
    reg signed [DATA_LEN-1:0] even_next;
    reg signed [DATA_LEN-1:0] odd_curr;
    
    // Intermediate results (pipeline stages)
    reg signed [DATA_LEN-1:0] detail_predict;
    reg signed [DATA_LEN-1:0] approx_update;
    
    // State machine
    localparam FILL_EVEN_CURR = 3'd0;
    localparam FILL_ODD_PREV = 3'd1;
    localparam FILL_EVEN_NEXT = 3'd2;
    localparam FILL_ODD_CURR = 3'd3;
    localparam PREDICT = 3'd4;
    localparam UPDATE = 3'd5;
    
    reg [2:0] state = FILL_EVEN_CURR;   
    always @(posedge clk or posedge reset) begin
    
        if(reset) begin
            even_curr <= 0;
            odd_prev <= 0;
            even_next <= 0;
            odd_curr <= 0;
            detail_predict <= 0;
            approx_update <= 0;
            
            state <= FILL_EVEN_CURR;
            valid_out <= 0;
            approx <= 0;
            detail <= 0;
           
        end else begin
        
            valid_out <= 0;  // Default: no output
            
            case(state)
            
                FILL_EVEN_CURR: begin
                    if (valid_in) begin
                        even_curr <= input_data;
                        state <= FILL_ODD_PREV;
                    end
                end
                
                FILL_ODD_PREV: begin
                    if (valid_in) begin
                        odd_prev <= input_data;
                        state <= FILL_EVEN_NEXT;
                    end
                end
                
                FILL_EVEN_NEXT: begin
                    if (valid_in) begin
                        even_next <= input_data;
                        state <= FILL_ODD_CURR;
                    end
                end
                
                FILL_ODD_CURR: begin
                    if (valid_in) begin
                        odd_curr <= input_data;
                        state <= PREDICT;
                    end
                end
                
                PREDICT: begin
                    // === STAGE 1: PREDICT ===
                    // detail = odd - (even_left + even_right) / 2
                    
                    if (first_odd) begin
                        detail_predict <= odd_curr - even_curr;
                    end else if (last_even_minus_one) begin
                        detail_predict <= odd_curr - ((even_curr + even_next) >>> 1);
                    end else begin
                        detail_predict <= odd_curr - even_next;
                    end
                   
                end
                    
                    
                UPDATE: begin
                    // === STAGE 2: UPDATE === 
                    // approx = even + (detail_left + detail_right) / 4
                    
                    
                    if (first_even) begin
                        approx_update <= even_curr + ((detail_predict) >>> 1);
                    end else if (last_odd) begin
                        approx_update <= even_curr + ((odd_prev + detail_predict) >>> 2);
                    end else begin
                        approx_update <= even_curr + ((odd_prev) >>> 1);
                    end
                    
                    // Output results
                    approx <= approx_update;
                    detail <= detail_predict;
                    valid_out <= 1;
                    
                    // Shift pipeline for next iteration
                    if (valid_in) begin
                        even_curr <= even_next;
                        odd_prev <= detail_predict;  // Use transformed detail
                        even_next <= input_data;
                        
                        state <= FILL_ODD_CURR;
                    end else begin
                        state <= FILL_EVEN_CURR;  // No more data, return to idle
                    end
                end
                
                default: begin
                    state <= FILL_EVEN_CURR;
                end
            endcase
        end
    end
    
endmodule