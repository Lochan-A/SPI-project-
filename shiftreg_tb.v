`timescale 1ns / 1ps

module shiftreg_tb;

  // Inputs
  reg        PCLK;
  reg        PRESETn;
  reg        ss;
  reg        send_data;
  reg        lsbfe;
  reg        cpha, cpol;
  reg        flag_low, flag_high, flags_low, flags_high;
  reg  [7:0] data_mosi;
  reg        miso;
  reg        receive_data;

  // Outputs
  wire       mosi;
  wire [7:0] data_miso;

  // Instantiate DUT
  shiftregister uut (
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
    .data_mosi(data_mosi),
    .miso(miso),
    .receive_data(receive_data),
    .mosi(mosi),
    .data_miso(data_miso)
  );

  // Generate Clock
  initial PCLK = 0;
  always #5 PCLK = ~PCLK;  // 100 MHz clock (10ns period)

  // VCD for GTKWave or Vivado
  initial begin
    $dumpfile("shiftregister.vcd");
    $dumpvars(0, shiftreg_tb);
  end

  initial begin
    // ========== Initialization ==========
    PRESETn = 0; ss = 1; send_data = 0; receive_data = 0;
    lsbfe = 1;  // LSB first
    cpha = 0; cpol = 0;
    flag_low = 0; flag_high = 0;
    flags_low = 0; flags_high = 0;
    data_mosi = 8'b10101010; // Data to send
    miso = 0;

    // ========== Reset ==========
    #10 PRESETn = 1;
    #10;

    // ========== Start SPI Transaction ==========
    ss = 0;
    send_data = 1; #10; send_data = 0;

    // ========== Enable Receive ==========
    receive_data = 1;

    // ========== Begin 8-bit Shift ==========
    repeat (8) begin
      #5 miso = $random % 2;  // Random bit on MISO line

      flag_low = 1; flags_low = 1;
      #10;
      flag_low = 0; flags_low = 0;

      #10;
    end

    receive_data = 0;
    ss = 1;

    #20;
    $display("Final data_miso = %b", data_miso);
    $finish;
  end

endmodule

