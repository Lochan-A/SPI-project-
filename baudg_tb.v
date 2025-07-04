`timescale 1ns / 1ps

module baudg_tb;

    reg        PCLK;
    reg        PRESETn;
    reg  [1:0] spi_mode;
    reg        spiswai;
    reg  [2:0] sppr;
    reg  [2:0] spr;
    reg        cpol;
    reg        cpha;
    reg        ss;
    wire       sclk;
    wire [11:0] BaudRateDivisor;
    wire       flag_low, flags_low, flag_high, flags_high;

    // Instantiate the DUT
    baudrate_generator dut (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .spi_mode(spi_mode),
        .spiswai(spiswai),
        .sppr(sppr),
        .spr(spr),
        .cpol(cpol),
        .cpha(cpha),
        .ss(ss),
        .sclk(sclk),
        .BaudRateDivisor(BaudRateDivisor),
        .flag_low(flag_low),
        .flags_low(flags_low),
        .flag_high(flag_high),
        .flags_high(flags_high)
    );

    // Generate fast PCLK: 10 ns period = 100 MHz clock
    initial begin
        PCLK = 0;
        forever #5 PCLK = ~PCLK;  // Toggle every 5 ns
    end

   

    initial begin
        // Initialize inputs
        PRESETn  = 0;
        spi_mode = 2'b00;
        spiswai  = 0;
        sppr     = 3'd0;
        spr      = 3'd0;         // BaudRateDivisor = (0+1) * 2^(0+1) = 1 * 2 = 2
        cpol     = 0;
        cpha     = 0;
        ss       = 1;

        // Hold reset
        #20;
        PRESETn = 1;

        // Enable SPI (ss low)
        #10;
        ss = 0;

        // Observe flags in mode 0
        #500;

       
        // Switch to SPI mode 1 (cpol=0, cpha=1)
        cpha = 1;
        spi_mode = 2'b01;
        #500;

        
        $finish;
    end

endmodule

