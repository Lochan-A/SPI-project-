module shiftregister (
    input        PCLK,
    input        PRESETn,
    input        ss,
    input        send_data,
    input        lsbfe,
    input        cpha, cpol,
    input        flag_low, flag_high, flags_low, flags_high,
    input  [7:0] data_mosi,
    input        miso,
    input        receive_data,
    output reg   mosi,
    output reg [7:0] data_miso
);

    // Internal registers
    reg [7:0] shift_register;  // For transmission (MOSI)
    reg [7:0] temp_reg;        // For reception (MISO)

    reg [2:0] count0;  // Transmit LSB-first
    reg [2:0] count1;  // Transmit MSB-first
    reg [2:0] count2;  // Receive LSB-first
    reg [2:0] count3;  // Receive MSB-first

    // ==========================================
    // Load shift register when send_data is high
    // ==========================================
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            shift_register <= 8'd0;
            count0 <= 3'd0;
            count1 <= 3'd7;
        end else if (send_data && !ss) begin
            shift_register <= data_mosi;
            count0 <= 3'd0;
            count1 <= 3'd7;
        end
    end

    // ==========================================
    // Transmit Logic (MOSI)
    // ==========================================
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            mosi <= 1'b0;
        end else if (!ss) begin
            if ((cpha ^ cpol) && flags_high) begin
                if (lsbfe) begin
                    if (count0 <= 3'd7) begin
                        mosi <= shift_register[count0];
                        count0 <= count0 + 1;
                    end
                end else begin
                    if (count1 > 3'd0) begin
                        mosi <= shift_register[count1];
                        count1 <= count1 - 1;
                    end else if (count1 == 3'd0) begin
                        mosi <= shift_register[count1];
                    end
                end
            end else if (!(cpha ^ cpol) && flags_low) begin
                if (lsbfe) begin
                    if (count0 <= 3'd7) begin
                        mosi <= shift_register[count0];
                        count0 <= count0 + 1;
                    end
                end else begin
                    if (count1 > 3'd0) begin
                        mosi <= shift_register[count1];
                        count1 <= count1 - 1;
                    end else if (count1 == 3'd0) begin
                        mosi <= shift_register[count1];
                    end
                end
            end
        end
    end

    // ==========================================
    // Receive Logic (MISO ? temp_reg)
    // ==========================================
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            temp_reg <= 8'd0;
            count2 <= 3'd0;
            count3 <= 3'd7;
        end else if (receive_data && !ss) begin
            if ((cpha ^ cpol) && flag_high) begin
                if (lsbfe) begin
                    if (count2 <= 3'd7) begin
                        temp_reg[count2] <= miso;
                        count2 <= count2 + 1;
                    end
                end else begin
                    if (count3 > 3'd0) begin
                        temp_reg[count3] <= miso;
                        count3 <= count3 - 1;
                    end else if (count3 == 3'd0) begin
                        temp_reg[count3] <= miso;
                    end
                end
            end else if (!(cpha ^ cpol) && flag_low) begin
                if (lsbfe) begin
                    if (count2 <= 3'd7) begin
                        temp_reg[count2] <= miso;
                        count2 <= count2 + 1;
                    end
                end else begin
                    if (count3 > 3'd0) begin
                        temp_reg[count3] <= miso;
                        count3 <= count3 - 1;
                    end else if (count3 == 3'd0) begin
                        temp_reg[count3] <= miso;
                    end
                end
            end
        end
    end

    // ==========================================
    // Output received data
    // ==========================================
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            data_miso <= 8'd0;
        end else if (!ss && (count2 == 3'd7 || count3 == 3'd0)) begin
            data_miso <= temp_reg;
        end
    end

endmodule

