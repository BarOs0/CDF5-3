`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/09/2026 05:26:22 PM
// Design Name: 
// Module Name: predict_and_update
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


module predict_and_update #(
    parameter DATA_LEN = 16,
    parameter NULL = 16'd0
)(
    input clk,
    input reset,
    
    input [DATA_LEN-1:0] data_in,
    
    // for predict
    input wire first_odd,
    input wire last_odd,
    
    // for update
    input wire first_even,
    input wire last_even,
    
    input wire data_valid,
    
    // for predict
    output reg [DATA_LEN-1:0] predict_detail,
    output reg predict_done,
    
    // for update
    output reg [DATA_LEN-1:0] update_approx,
    output reg update_done
    );
    
    // for predict
    reg signed [DATA_LEN-1:0] even_prev;
    reg signed [DATA_LEN-1:0] odd;
    reg signed [DATA_LEN-1:0] even_next;
    reg signed [DATA_LEN-1:0] predict_d1;
    
// =========== DEBUG PREDICT ==============
    reg signed [DATA_LEN-1:0] sync_prev;
    reg signed [DATA_LEN-1:0] sync_odd;
    reg signed [DATA_LEN-1:0] sync_next;
// ========================================


    // for update
//    reg signed [DATA_LEN-1:0] odd_prev;
//    reg signed [DATA_LEN-1:0] even;
//    reg signed [DATA_LEN-1:0] odd;
    
// ============ DEBUG UPDATE ================
//    reg signed [DATA_LEN-1:0] sync_odd_prev;
//    reg signed [DATA_LEN-1:0] sync_even;
//    reg signed [DATA_LEN-1:0] sync_odd;
// ==========================================
    
//    reg [DATA_LEN-1:0] even_d1;
//    reg [DATA_LEN-1:0] even_d2;

    // for predict
    reg predict_initialized = 0;
    reg first_odd_d1 = 0;
    reg predict_done_d1 = 0;
    
    // for update
//    reg update_initialized = 0;
    
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
            predict_d1 <= NULL;
            predict_detail <= NULL;
            
//            odd_prev <= NULL;
//            even <= NULL;
//            even_d1 <= NULL;
//            even_d2 <= NULL;
//            odd <= NULL;
            update_approx <= NULL;

// =========== DEBUG PREDICT ==============            
            sync_prev <= NULL;
            sync_odd <= NULL;
            sync_next <= NULL;
// ========================================

// ============ DEBUG UPDATE ================
//            sync_odd_prev <= NULL;
//            sync_even <= NULL;
//            sync_odd <= NULL;
// ==========================================
            
            predict_initialized <= 0;
//            update_initialized <= 0;
            
            first_odd_d1 <= 0;
            
            predict_done <= 0;
            predict_done_d1 <= 0;
            update_done <= 0;
            
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
                    predict_d1 <= predict_detail;
                    if(data_valid) begin
                        odd <= data_in;
                    end
                    update_done <= 0;
                    predict_done <= 0;
                    predict_done_d1 <= predict_done;
                    first_odd_d1 <= first_odd;
                    state <= GET_EVEN_NEXT;
                end
                
                GET_EVEN_NEXT: begin
                    if(data_valid) begin
                        if(~predict_initialized) begin
                            even_next <= data_in;
                            
//                      =========== DEBUG PREDICT ==============                            
                            sync_prev <= even_prev; 
                            sync_odd  <= odd;       
                            sync_next <= data_in;
//                      ========================================

                            predict_initialized <= 1;
                            if(first_odd_d1) begin
                                predict_detail <= odd - even_prev; 
                            end
                            
                        end else begin
                            even_prev <= even_next; 
                            even_next <= data_in;
                            
//                      =========== DEBUG PREDICT ==============                            
                            sync_prev <= even_next; 
                            sync_odd  <= odd;       
                            sync_next <= data_in;
//                      ========================================   
                         
                            if(last_odd) begin
                                predict_detail <= odd - even_next; 
                            end else begin
                                predict_detail <= odd - ((even_next + data_in) >>> 1);
                            end
                            
                        end
                        state <= GET_ODD;
                    end
                    predict_done <= 1;
                    
                    // for update
                    if(predict_done_d1) begin
                        if(first_even) begin
                            update_approx <= even_prev + (predict_detail >>> 1);
                        end else if(last_odd) begin
                            update_approx <= even_prev + ((predict_d1 + predict_detail) >>> 2);
                        end else begin
                            update_approx <= even_prev + (predict_d1 >>> 1);
                        end
                        update_done <= 1;
                    end
                    predict_done_d1 <= predict_done;
                end
                
                default: begin
                    state <= IDLE;
                end
                
            endcase
       end
    end
endmodule