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
    output reg signed [DATA_LEN-1:0] predict_detail,
    output reg predict_done,
    
    // for update
    output reg signed [DATA_LEN-1:0] update_approx,
    output reg update_done
    );
    
    // for predict
    reg signed [DATA_LEN-1:0] even_prev;
    reg signed [DATA_LEN-1:0] odd;
    reg signed [DATA_LEN-1:0] even_next;
    reg signed [DATA_LEN-1:0] predict_d1;
    reg signed [DATA_LEN-1:0] predict_d2;
    
// =========== DEBUG PREDICT ==============
    reg signed [DATA_LEN-1:0] sync_prev;
    reg signed [DATA_LEN-1:0] sync_odd;
    reg signed [DATA_LEN-1:0] sync_next;
// ========================================

    // for predict
    reg next_initialized = 0;
    reg predict_initialized = 0;
    reg first_odd_d = 0;
    reg predict_done_d = 0;
    
    // for update
    reg [3:0] first_even_d;
    reg [3:0] last_odd_d;
    
    localparam GET_EVEN_PREV = 3'd0;
    localparam GET_ODD = 3'd1;
    localparam GET_EVEN_NEXT = 3'd2;
    localparam PREDICT = 3'd3;
    
    reg [1:0] state = GET_EVEN_PREV;
    
    always @(posedge clk or posedge reset) begin
        if(reset) begin
        
            even_prev <= NULL;
            odd <= NULL;
            even_next <= NULL;
            
            predict_d1 <= NULL;
            predict_d2 <= NULL;
            
            predict_detail <= NULL;
            
            update_approx <= NULL;

// =========== DEBUG PREDICT ==============            
            sync_prev <= NULL;
            sync_odd <= NULL;
            sync_next <= NULL;
// ========================================
            
            next_initialized <= 0; // ttuaj
            predict_initialized <= 0;
            
            first_odd_d <= 0;
            first_even_d <= 4'b0;
            last_odd_d <= 4'b0;
            
            predict_done <= 0;
            predict_done_d <= 0;
            update_done <= 0;
            
            state <= GET_EVEN_PREV;
            
        end else 
        
        first_even_d <= {first_even_d[2:0], first_even};
        last_odd_d <= {last_odd_d[2:0], last_odd};
        predict_d1 <= predict_detail;
        predict_d2 <= predict_d1;
        first_odd_d <= first_odd;
        predict_done_d <= predict_done;
        update_done <= predict_done_d; // zobaczyc czy to dziala na testach (update gotowy dokladnie po 2 zegarkach po predict)
        
            case(state)
            
                GET_EVEN_PREV: begin
                    if(data_valid) begin
                        even_prev <= data_in;
                        state <= GET_ODD;
                    end
                end
                
                GET_ODD: begin
                    if(data_valid || predict_done) begin
                        odd <= data_in;
                        predict_initialized <= 0;
                        predict_done <= 0;
                        state <= GET_EVEN_NEXT;
                    end
                end
                
                GET_EVEN_NEXT: begin
                    if(data_valid) begin
                        if(~next_initialized) begin // tutaj
                            even_next <= data_in;
                            
//                      =========== DEBUG PREDICT ==============                            
                            sync_prev <= even_prev; 
                            sync_odd  <= odd;       
                            sync_next <= data_in;
//                      ========================================

                            // for predict
                            next_initialized <= 1; //tutaj
                            if(first_odd_d) begin // left edge
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
                         
                            // for predict
                            if(last_odd_d[0]) begin // right egde
                                predict_detail <= odd - even_next; 
                            end else begin // middle
                                predict_detail <= odd - ((even_next + data_in) >>> 1);
                            end
                            
                        end
                        predict_initialized <= 1;
                        state <= GET_ODD;
                        predict_done <= 1;
                    end

                    // for update
                    if(predict_done_d) begin
                        if(first_even_d[3]) begin
                            update_approx <= even_prev + (predict_detail >>> 1);
                        end else if(last_odd_d[3]) begin
                            update_approx <= even_prev + (predict_d2 >>> 1);
                        end else begin
                            update_approx <= even_prev + ((predict_d2 + predict_detail) >>> 2);
                        end
                    end
                end
                
                default: begin
                    state <= GET_EVEN_PREV;
                end
                
            endcase
       end
endmodule

// PREDICT_DONE_D trwa za krotko w if do predict, powinien byc o 1 takt wiecej 