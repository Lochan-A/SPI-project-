`timescale 1ns/1ps

module apb_tb;

    // Inputs
    reg         PCLK;
    reg         PRESETn;
    reg  [2:0]  PADDR;
    reg         PWRITE;
    reg         PSEL;
    reg         PENABLE;
    reg  [7:0]  PWDATA;
    reg         ss;
    reg  [7:0]  miso_data;
    reg         receive_data;
    reg         tip;

    // Outputs
    wire [7:0]  PRDATA;
    wire        PREADY;
    wire        PSLVERR;
    wire        mstr, cpol, cpha, lsbfe, spiswai;
    wire [2:0]  sppr;
    wire [2:0]  spr;
    wire        spi_interrupt_request;
    wire        send_data;
    wire        mosi_data;
    wire [1:0]  spi_mode;

    // Instantiate the Unit Under Test (UUT)
    apb_slaves_interface uut (
        .PCLK(PCLK), .PRESETn(PRESETn), .PADDR(PADDR),
        .PWRITE(PWRITE), .PSEL(PSEL), .PENABLE(PENABLE),
        .PWDATA(PWDATA), .PRDATA(PRDATA), .PREADY(PREADY),
        .PSLVERR(PSLVERR), .ss(ss), .miso_data(miso_data),
        .receive_data(receive_data), .tip(tip), .mstr(mstr),
        .cpol(cpol), .cpha(cpha), .lsbfe(lsbfe), .spiswai(spiswai),
        .sppr(sppr), .spr(spr), .spi_interrupt_request(spi_interrupt_request),
        .send_data(send_data), .mosi_data(mosi_data), .spi_mode(spi_mode)
    );

    // Clock generation
    initial PCLK = 0;
    always #5 PCLK = ~PCLK;  // 100MHz clock

    // Task for APB write
    task apb_write;
        input [2:0] addr;
        input [7:0] data;
        begin
            @(posedge PCLK);
            PADDR  = addr;
            PWDATA = data;
            PWRITE = 1;
            PSEL   = 1;
            PENABLE = 0;
            @(posedge PCLK);
            PENABLE = 1;
            @(posedge PCLK);
            PSEL = 0;
            PENABLE = 0;
        end
    endtask

    // Task for APB read
    task apb_read;
        input [2:0] addr;
        begin
            @(posedge PCLK);
            PADDR  = addr;
            PWRITE = 0;
            PSEL   = 1;
            PENABLE = 0;
            @(posedge PCLK);
            PENABLE = 1;
            @(posedge PCLK);
            PSEL = 0;
            PENABLE = 0;
        end
    endtask

    initial begin
        // Initialize Inputs
        PADDR = 0; PWRITE = 0; PSEL = 0; PENABLE = 0;
        PWDATA = 0; ss = 1; miso_data = 8'h00;
        receive_data = 0; tip = 0;

        // Reset pulse
        PRESETn = 0;
        #20;
        PRESETn = 1;

        // Configure Control Register 1
        apb_write(3'b000, 8'b11010000); // SPIE=1, SPE=1, MSTR=1

        // Configure Control Register 2
        apb_write(3'b001, 8'b00000010); // SPISWAI=1

        // Configure Baud Rate Register
        apb_write(3'b010, 8'b0001010); // SPPR=001, SPR=010

        // Write data to SPI_DR
        apb_write(3'b101, 8'hA5);

        // Simulate MISO input
        #20;
        miso_data = 8'h3C;
        receive_data = 1;
        ss = 0;
        #10;
        receive_data = 0;

        // Read back control and data registers
        #20;
        apb_read(3'b000);  // SPI_CR1
        apb_read(3'b001);  // SPI_CR2
        apb_read(3'b010);  // SPI_BR
        apb_read(3'b011);  // SPI_SR
        apb_read(3'b101);  // SPI_DR

        // Simulate transfer in progress
        #20;
        tip = 1;
        ss = 0;
        #20;
        tip = 0;
        ss = 1;

        #100;
        $finish;
    end

endmodule

