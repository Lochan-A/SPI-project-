`timescale 1ns / 1ps

module ss_tb;

    // Inputs
    reg PCLK;
    reg PRESETn;
    reg mstr;
    reg spiswai;
    reg [1:0] spi_mode;
    reg send_data;
    reg [15:0] BaudRateDivisor;

    // Outputs
    wire tip;
    wire ss;
    wire receive_data;

    // Instantiate the slaveselect module
    slaveselect uut (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .mstr(mstr),
        .spiswai(spiswai),
        .spi_mode(spi_mode),
        .send_data(send_data),
        .BaudRateDivisor(BaudRateDivisor),
        .tip(tip),
        .ss(ss),
        .receive_data(receive_data)
    );

    // Clock generation
    always #5 PCLK = ~PCLK; // 100 MHz clock (10 ns period)

    initial begin
        // Initialize inputs
        PCLK = 0;
        PRESETn = 0;
        mstr = 0;
        spiswai = 0;
        spi_mode = 2'b00;
        send_data = 0;
        BaudRateDivisor = 16'd10;

        // Reset the system
        #20;
        PRESETn = 1;

        // Wait a bit then configure for valid operation
        #20;
        mstr = 1;
        spi_mode = 2'b00;
        spiswai = 0;

        // Start transmission
        #20;
        send_data = 1;

        #10;
        send_data = 0;

        // Let it run for more time
        #200;

        // Trigger another send
        send_data = 1;
        #10;
        send_data = 0;

        #200;

        // End simulation
        $finish;
    end

endmodule

