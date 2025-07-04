`timescale 1ns / 1ps

module spi_top_tb();

  reg         PCLK;
  reg         PRESETn;
  reg  [2:0]  PADDR;
  reg         PWRITE;
  reg         PSEL;
  reg         PENABLE;
  reg  [7:0]  PWDATA;
  reg         miso;

  wire        ss;
  wire        sclk;
  wire        spi_interrupt_request;
  wire        mosi;
  wire [7:0]  PRDATA;
  wire        PREADY;
  wire        PSLVERR;

  // Instantiate the SPI top module
  spi_top uut (
    .PCLK(PCLK),
    .PRESETn(PRESETn),
    .PADDR(PADDR),
    .PWRITE(PWRITE),
    .PSEL(PSEL),
    .PENABLE(PENABLE),
    .PWDATA(PWDATA),
    .miso(miso),
    .ss(ss),
    .sclk(sclk),
    .spi_interrupt_request(spi_interrupt_request),
    .mosi(mosi),
    .PRDATA(PRDATA),
    .PREADY(PREADY),
    .PSLVERR(PSLVERR)
  );

  // Clock generation
  initial PCLK = 0;
  always #5 PCLK = ~PCLK; // 100 MHz clock

  // Test sequence
  initial begin
    // Initial values
    PRESETn = 0;
    PSEL    = 0;
    PENABLE = 0;
    PWRITE  = 0;
    PADDR   = 0;
    PWDATA  = 8'h00;
    miso    = 1'b0;

    // Apply reset
    #20 PRESETn = 1;

    // Write to SPI_CR1: spie=1, spe=1, mstr=1, cpol=0, cpha=0, lsbfe=1
    apb_write(3'b000, 8'b11010001);
    #20;

    // Write to SPI_CR2: modfen=1, spiswai=1
    apb_write(3'b001, 8'b00010010);
    #20;

    // Write to SPI_BR: sppr=1, spr=5
    apb_write(3'b010, 8'b00100101);
    #20;

    // Write to SPI_DR: data = 0xAA
    apb_write(3'b101, 8'b10101010);
    #200;

    // Modify miso during transmission
    miso = 1; #30;
    miso = 0; #30;
    miso = 1; #30;

    // Read SPI_SR
    apb_read(3'b011);
    #20;

    // Read SPI_DR
    apb_read(3'b101);
    #20;

    // Change LSBFE to 0 (MSB first) and send another byte
    apb_write(3'b000, 8'b11010000);
    apb_write(3'b101, 8'b11001100);
    #200;

    // Change CPOL and CPHA to test SPI mode 3 (CPOL=1, CPHA=1)
    apb_write(3'b000, 8'b11011100);
    apb_write(3'b101, 8'b11110000);
    #200;

    $stop;
  end

  // APB Write Task
  task apb_write(input [2:0] addr, input [7:0] data);
  begin
    @(posedge PCLK);
    PSEL    = 1;
    PWRITE  = 1;
    PADDR   = addr;
    PWDATA  = data;
    PENABLE = 0;

    @(posedge PCLK);
    PENABLE = 1;

    @(posedge PCLK);
    PSEL    = 0;
    PENABLE = 0;
  end
  endtask

  // APB Read Task
  task apb_read(input [2:0] addr);
  begin
    @(posedge PCLK);
    PSEL    = 1;
    PWRITE  = 0;
    PADDR   = addr;
    PENABLE = 0;

    @(posedge PCLK);
    PENABLE = 1;

    @(posedge PCLK);
    PSEL    = 0;
    PENABLE = 0;
  end
  endtask

endmodule

