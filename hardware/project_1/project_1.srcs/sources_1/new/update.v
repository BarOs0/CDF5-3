`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/09/2026 05:39:56 PM
// Design Name: 
// Module Name: update
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


module update #(
    parameter DATA_LEN = 16,
    parameter NULL = 16'd0
)(
    input clk,
    input reset,
    
    input [DATA_LEN-1:0] data_in,
    
    input wire first_odd,
    input wire last_odd,
    
    input wire first_even,
    input wire last_even,
    
    input wire data_valid,
    
    output reg [DATA_LEN-1:0] update_approx,
    output reg update_done
    );
    
    wire [DATA_LEN-1:0] detail;
    wire predict_done;
    
    predict i_predict (
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .first_odd(first_odd),
        .last_odd(last_odd),
        .data_valid(data_valid),
        .predict_detail(detail),
        .predict_done(predict_done)
    );
    
    reg signed [DATA_LEN-1:0] odd_prev;
    reg signed [DATA_LEN-1:0] even;
    reg signed [DATA_LEN-1:0] odd;
    
    reg signed [DATA_LEN-1:0] sync_odd_prev;
    reg signed [DATA_LEN-1:0] sync_even;
    reg signed [DATA_LEN-1:0] sync_odd;
    
    reg [DATA_LEN-1:0] even_d1;
    reg [DATA_LEN-1:0] even_d2;
    
    reg initialized = 0;
    
    localparam IDLE = 3'd0;
    localparam GET_EVEN = 3'd1;
    localparam GET_ODD = 3'd2;

    reg [1:0] state = GET_EVEN;
    
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            odd_prev <= NULL;
            even <= NULL;
            odd <= NULL;
            update_approx <= NULL;
            initialized <= 0;
            
            sync_odd_prev <= NULL;
            sync_even <= NULL;
            sync_odd <= NULL;
            
            even_d1 <= NULL;
            even_d2 <= NULL;
            
            update_done <= 0;
            
            state <= IDLE;
        end else begin
            
            case(state)
            
                IDLE: begin
                    state <= GET_EVEN;
                end
            
                GET_EVEN: begin
                
                    if(data_valid) begin
                        even <= data_in;
                    end
                    
                    update_done <= 0;
                    state <= GET_ODD;
                end
                
                GET_ODD: begin
                    if(data_valid) begin
                        if(predict_done) begin
                            odd <= detail;
                            initialized <= 1;
                        end
                        
                        if(initialized) begin
                            odd_prev <= odd;
                        end
                        
                        even_d1 <= even;
                        even_d2 <= even_d1;
                        
                        sync_odd_prev <= odd_prev;
                        sync_even <= even_d2;
                        sync_odd <= odd;
                        
                        if(first_even) begin
                            update_approx <= even + (odd >>> 1);
                        end else if(last_odd) begin
                            update_approx <= even + ((odd_prev + odd) >>> 2);
                        end else begin
                            update_approx <= even + (odd_prev >>> 1);
                        end
                        
                        update_done <= 1;
                        state <= GET_EVEN;
                    end
                end
                
                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
