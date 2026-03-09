`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/08/2026 12:31:16 PM
// Design Name: 
// Module Name: predict_tb
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


module predict_tb(

    );
    localparam DATA_LEN = 16;
    localparam X_LEN = 8;
    localparam DUMMY_LEN = 1;
    
    reg clk;
    reg reset;
    reg signed [DATA_LEN-1:0] data_in;
    wire signed [DATA_LEN-1:0] data_out;
    wire done;
    
    reg signed [DATA_LEN-1:0] x [0:X_LEN-1];
    reg signed [DATA_LEN-1:0] dummy [0:DUMMY_LEN-1];
    integer i, j;
    
    reg first_last_odd = 0;
    reg last_even_minus_one = 0;
    reg data_valid = 0;
    
    predict uut (
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .first_last_odd(first_last_odd),
        .last_even_minus_one(last_even_minus_one),
        .data_valid(data_valid),
        .predict_detail(data_out),
        .done(done)
    );
    
    always #5 clk = ~clk;
    
    initial begin
    
    for (i = 0; i < X_LEN; i = i + 1) begin
        x[i] = $urandom & 16'hFFFF;
    end
        
    for (i = 0; i < DUMMY_LEN; i = i + 1) begin
        dummy[i] = 16'd255;
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
                last_even_minus_one <= 0;
                first_last_odd <= 1;
            end else if (i <= X_LEN/2 - 1) begin
                first_last_odd <= 0;
                last_even_minus_one <= 1;
            end else if (i == X_LEN - 1) begin
                last_even_minus_one <= 0;
                first_last_odd <= 1;
            end else begin
                last_even_minus_one <= 0;
                first_last_odd <= 0;
            end
       
            data_in <= x[i];
            @(posedge clk);
        end
        
        
        for(i = 0; i < DUMMY_LEN; i = i + 1) begin
            data_in <= dummy[i];
            @(posedge clk);
        end
        data_valid <= 0;
        
        // Po podaniu danych zerujemy wejście i czekamy na ostatni wynik
        data_in <= 16'd255;
        repeat(3) @(posedge clk); 
    end
    
endmodule
