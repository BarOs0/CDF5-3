`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/08/2026 12:16:41 PM
// Design Name: 
// Module Name: predict
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


module predict #(
    parameter DATA_LEN = 16,
    parameter NULL = 16'd0
)(
    input clk,
    input reset,
    
    input [DATA_LEN-1:0] data_in,
    
    // for predict
    input wire first_odd,
    input wire last_odd,
    
    input wire data_valid,
    
    // for predict
    output reg [DATA_LEN-1:0] predict_detail,
    output reg predict_done
    );
    
    // for predict
    reg signed [DATA_LEN-1:0] even_prev;
    reg signed [DATA_LEN-1:0] odd;
    reg signed [DATA_LEN-1:0] even_next;
    
// =============== DEBUG ==================
//    reg signed [DATA_LEN-1:0] sync_prev;
//    reg signed [DATA_LEN-1:0] sync_odd;
//    reg signed [DATA_LEN-1:0] sync_next;
// ========================================

    // for predict
    reg initialized = 0;
    reg first_odd_buff = 0;
    
    localparam IDLE = 3'd0;
    localparam GET_EVEN_PREV = 3'd1;
    localparam GET_ODD = 3'd2;
    localparam GET_EVEN_NEXT = 3'd3;
    localparam PREDICT = 3'd4;
    
    reg [2:0] state = IDLE;
    
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            even_prev <= NULL;
            odd <= NULL;
            even_next <= NULL;
            predict_detail <= NULL;
            
//            sync_prev <= NULL;
//            sync_odd <= NULL;
//            sync_next <= NULL;
            
            initialized <= 0;
            
            first_odd_buff <= 0;
            
            predict_done <= 0;
            
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
                    predict_done <= 0;
                    first_odd_buff <= first_odd;
                    state <= GET_EVEN_NEXT;
                end
                
                GET_EVEN_NEXT: begin
                    if(data_valid) begin
                        if(~initialized) begin
                            even_next <= data_in;
                            
//                            sync_prev <= even_prev; 
//                            sync_odd  <= odd;       
//                            sync_next <= data_in;

                            initialized <= 1;
                            if(first_odd_buff) begin
                                predict_detail <= odd - even_prev; 
                            end 
                            
                        end else begin
                            even_prev <= even_next; 
                            even_next <= data_in;
                            
//                            sync_prev <= even_next; 
//                            sync_odd  <= odd;       
//                            sync_next <= data_in;
                            
                            if(last_odd) begin
                                predict_detail <= odd - even_next; 
                            end else begin
                                predict_detail <= odd - ((even_next + data_in) >>> 1);
                            end
                        end
                        
                        predict_done <= 1;
                        state <= GET_ODD;
                    end
                end
                
                default: begin
                    state <= IDLE;
                end
                
            endcase
       end
    end
endmodule
