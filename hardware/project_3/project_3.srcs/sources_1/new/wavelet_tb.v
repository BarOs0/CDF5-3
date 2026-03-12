`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/12/2026 10:22:31 PM
// Design Name: 
// Module Name: wavelet_tb
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


module wavelet_tb();

    parameter DATA_WIDTH = 32;
    parameter X_LEN = 16;
    
    reg clk = 0;
    reg resetn = 0;
    always #5 clk = ~clk;
    
    reg [DATA_WIDTH-1:0] data_in_tdata;
    reg data_in_tvalid;
    reg data_in_tlast;
    wire data_in_tready;
    wire [3:0] data_in_tstrb = 4'hf;
    
    wavelet uut (
    .data_in_aclk(clk),
    .data_in_aresetn(resetn),
    .data_in_tready(data_in_tready),
    .data_in_tdata(data_in_tdata),
    .data_in_tstrb(data_in_tstrb),
    .data_in_tlast(data_in_tlast),
    .data_in_tvalid(data_in_tvalid),
    .update_approx_aclk(clk),
    .update_approx_aresetn(resetn),
    .predict_detail_aclk(clk),
    .predict_detail_aresetn(resetn),
    .control_aclk(clk),
    .control_aresetn(resetn)
    );
    
    integer i;
    reg [DATA_WIDTH-1:0] test_data [0:X_LEN-1];
    
    initial begin
    for(i=0; i<X_LEN; i=i+1) test_data[i] = i * 2;

        data_in_tvalid = 0;
        data_in_tlast = 0;
        resetn = 0;
        #20 resetn = 1;
        
        @(posedge clk);
        for(i = 0; i < X_LEN; i = i + 1) begin
        data_in_tdata <= test_data[i];
        data_in_tvalid <= 1;
        data_in_tlast <= (i == X_LEN - 1);
        
        wait(data_in_tready == 1);
        @(posedge clk);
        end
        
        data_in_tvalid <= 0;
        data_in_tlast <= 0;
        #100 $finish;
        
    end
endmodule
