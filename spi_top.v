module spi_top(
    input         PCLK,
    input         PRESETn,
    input  [2:0]  PADDR,
    input         PWRITE,
    input         PSEL,
    input         PENABLE,
    input  [7:0]  PWDATA,
    input         miso,

    output        ss,
    output        sclk,
    output        spi_interrupt_request,
    output        mosi,
    output [7:0]  PRDATA,
    output        PREADY,
    output        PSLVERR
);

    // Internal signals
    wire [2:0]  sppr;
    wire [2:0]  spr;
    wire        cpol, cpha;
    wire        mstr;
    wire        lsbfe;
    wire        spiswai;
    wire [1:0]  spi_mode;
    wire        send_data;
    wire        receive_data;
    wire        tip;
    wire [7:0]  miso_data;
    wire        mosi_data;
    wire        flag_low, flag_high, flags_low, flags_high;
    wire [11:0] BaudRateDivisor;

    // APB Slave Interface
    apb_slave_interface u_apb_slave (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .PADDR(PADDR),
        .PWRITE(PWRITE),
        .PSEL(PSEL),
        .PENABLE(PENABLE),
        .PWDATA(PWDATA),
        .PRDATA(PRDATA),
        .PREADY(PREADY),
        .PSLVERR(PSLVERR),
        .ss(ss),
        .miso_data(miso_data),
        .receive_data(receive_data),
        .tip(tip),
        .mstr(mstr),
        .cpol(cpol),
        .cpha(cpha),
        .lsbfe(lsbfe),
        .spiswai(spiswai),
        .sppr(sppr),
        .spr(spr),
        .spi_interrupt_request(spi_interrupt_request),
        .send_data(send_data),
        .mosi_data(mosi_data),
        .spi_mode(spi_mode)
    );

    // Baudrate Generator
    baudrate_generator u_baudrate (
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
        .flags_low(flags_low),
        .flag_low(flag_low),
        .flags_high(flags_high),
        .flag_high(flag_high),
        .BaudRateDivisor(BaudRateDivisor)
    );

    // Shift Register
    shiftregister u_shift (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .ss(ss),
        .send_data(send_data),
        .lsbfe(lsbfe),
        .cpha(cpha),
        .cpol(cpol),
        .flag_low(flag_low),
        .flag_high(flag_high),
        .flags_low(flags_low),
        .flags_high(flags_high),
        .data_mosi(PWDATA),
        .miso(miso),
        .receive_data(receive_data),
        .mosi(mosi),
        .data_miso(miso_data)
    );

    // Slave Select
    slaveselect u_slave_select (
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

endmodule

