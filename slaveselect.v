module slaveselect (
    input         PCLK,
    input         PRESETn,
    input         mstr,
    input         spiswai,
    input  [1:0]  spi_mode,
    input         send_data,
    input  [15:0] BaudRateDivisor,
    output reg    tip,
    output reg    ss,
    output reg    receive_data
);

reg rcv;
reg [15:0] count;
reg [15:0] target;

// Update target from BaudRateDivisor
always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn)
        target <= 16'hFFFF;
    else
        target <= BaudRateDivisor;
end

// Output receive_data = rcv
always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn)
        receive_data <= 1'b0;
    else
        receive_data <= rcv;
end

// TIP = ~SS (slave selected = transfer in progress)
always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn)
        tip <= 1'b0;
    else
        tip <= ~ss;
end

// Main logic for slave select, receive control, and counter
always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn) begin
        ss    <= 1'b1;
        rcv   <= 1'b0;
        count <= 16'hFFFF;
    end else begin
        // Condition for SPI master mode and valid configuration
        if ((spi_mode == 2'b00 || spi_mode == 2'b01) && mstr && !spiswai) begin
            if (send_data) begin
                // Begin transmission
                ss    <= 1'b0;
                rcv   <= 1'b0;
                count <= 16'b0;
            end else if (count < target - 1) begin
                // Ongoing transfer
                count <= count + 1;
                rcv   <= 1'b0;
                ss    <= 1'b0;
            end else begin
                // Done transferring
                rcv   <= 1'b1;
                ss    <= 1'b1;
                count <= 16'hFFFF;
            end
        end else begin
            // Default/reset state if invalid SPI config
            ss    <= 1'b1;
            rcv   <= 1'b0;
            count <= 16'hFFFF;
        end
    end
end

endmodule

 

