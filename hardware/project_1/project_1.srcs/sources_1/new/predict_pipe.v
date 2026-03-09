`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/06/2026 09:33:41 PM
// Design Name: 
// Module Name: predict_pipe
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


module predict_pipe #(
    parameter DATA_LEN = 16
)(
    input clk,
    input reset,
    
    input [DATA_LEN-1:0] data_in,
    
    input wire first_odd,
    input wire last_even_minus_one,
    input wire data_valid,
    
    output reg [DATA_LEN-1:0] predict_detail,
    output reg done
    );
    
    reg signed [DATA_LEN-1:0] even_prev;
    reg signed [DATA_LEN-1:0] odd;
    reg signed [DATA_LEN-1:0] even_next;
    
    localparam IDLE = 3'd0;
    localparam GET_EVEN_PREV = 3'd1;
    localparam GET_ODD = 3'd2;
    localparam GET_EVEN_NEXT = 3'd3;
    localparam PREDICT = 3'd4;
    
    reg [2:0] state = GET_EVEN_PREV;
    
    always @(posedge clk or posedge reset) begin
        
        if(reset) begin
            even_prev <= 16'd255;
            odd <= 16'd255;
            even_next <= 16'd255;
            done <= 0;
            
            state <= IDLE;
        end else begin
        
            case(state)
            
                IDLE: begin
                    state <= GET_EVEN_PREV;
                end
            
                GET_EVEN_PREV: begin
                    if(data_valid) begin
                        even_prev <= data_in;
                    end
                    
                    state <= GET_ODD;
                end
                
                GET_ODD: begin
                    if(data_valid) begin
                        odd <= data_in;
                    end
                    
                    state <= GET_EVEN_NEXT;
                end
                
                GET_EVEN_NEXT: begin
                    if(data_valid) begin
                        even_next <= data_in;
                    end
                    
                    done <= 0;
                    state <= PREDICT;
                end
                
                PREDICT: begin
                    if(first_odd) begin
                        predict_detail <= odd - even_prev;
                    end else if (last_even_minus_one) begin
                        predict_detail <= odd - ((even_prev + even_next) >>> 1);
                    end else begin
                        predict_detail <= odd - even_prev;
                    end
                    
                    even_prev <= even_next;
                    if(data_valid) begin
                        odd <= data_in;
                    end
                    state <= GET_EVEN_NEXT;
                    done <= 1;
                end
            
                default: begin
                    state <= IDLE;
                end    
            endcase
       end
    end
endmodule
