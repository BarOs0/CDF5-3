`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/06/2026 09:58:51 PM
// Design Name: 
// Module Name: predict_pipe_tb
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


module predict_pipe_tb(

    );
    
    reg clk;
    reg reset;
    reg signed [15:0] data_in;
    wire signed [15:0] data_out;
    wire done;
    
    localparam X_LEN = 12;
    reg signed [15:0] x [0:X_LEN-1];
    integer i;
    
    reg first_odd = 0;
    reg last_even_minus_one = 0;
    reg data_valid = 0;
    
    predict_pipe uut (
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .first_odd(first_odd),
        .last_even_minus_one(last_even_minus_one),
        .data_valid(data_valid),
        .predict_detail(data_out),
        .done(done)
    );
    
    always #5 clk = ~clk;
    
    initial begin
    
    for (i = 0; i < X_LEN; i = i + 1) begin
        x[i] = i;
    end

        clk = 0;
        reset = 1;
        data_in = 16'd255;
        
        #10 reset = 0; // Puszczamy reset po 20ns
        @(posedge clk); // Czekamy na zbocze narastające

        // Wprowadzanie 6 elementów do potoku
        data_valid <= 1;
        for (i = 0; i < X_LEN; i = i + 1) begin
            if(i == 1) begin
                first_odd <= 1;
            end else if (i <= X_LEN/2 - 1) begin
                first_odd <= 0;
                last_even_minus_one <= 1;
            end else begin
                last_even_minus_one <= 0;
                first_odd <= 0;
            end
            
            
            data_in <= x[i];
            
            @(posedge clk); 
        end
        data_valid <= 0;
        
        // Po podaniu danych zerujemy wejście i czekamy na ostatni wynik
        data_in <= 0;
        repeat(3) @(posedge clk); 
    end


endmodule
