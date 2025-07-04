module baudrate_generator (
    input        PCLK,
    input        PRESETn,
    input  [1:0] spi_mode,
    input        spiswai,
    input  [2:0] sppr,
    input  [2:0] spr,
    input        cpol,
    input        cpha,
    input        ss,
    output reg      sclk,flags_low,flag_low,flags_high,flag_high,
    output [11:0] BaudRateDivisor
);

reg  [11:0]   count_reg;
wire  [11:0]  count;

assign BaudRateDivisor = (sppr +1 ) * (1<<(spr+1));
wire enb = ((spi_mode == 2'b00 || spi_mode == 2'b01) && !ss && !spiswai);


    always @ (posedge PCLK or negedge PRESETn) begin
        if (!PRESETn)
            count_reg <= 0;
        else 
         if (!enb)
            count_reg <= 0;
        else 
         if (count_reg == BaudRateDivisor - 1)
            count_reg <= 0;
        else
            count_reg <= count_reg + 1;
    end
assign count=count_reg;
   always @ (posedge PCLK or negedge PRESETn) begin
        if (!PRESETn)
            sclk <= 0;
        else 
         if (!enb)
            sclk <= 0;
        else 
         if (count_reg == BaudRateDivisor - 1)
            sclk <= ~sclk;
       
    end

// code for flags 
always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn)
        flags_low <= 1'b0;
    else if (!(cpha ^ cpol)) begin
        if (sclk == 1'b1) begin
            flags_low <= 1'b0;
        end else if (count == BaudRateDivisor - 2) begin
            flags_low <= 1'b1;
        end else begin
            flags_low <= 1'b0;
        end
    end else begin
        flags_low <= 1'b0;
    end
end
always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn)
        flag_low <= 1'b0;
    else if (!(cpha ^ cpol)) begin
        if (sclk == 1'b1) begin
            flag_low <= 1'b0;
        end else if (count == BaudRateDivisor - 1) begin
            flag_low <= 1'b1;
        end else begin
            flag_low <= 1'b0;
        end
    end else begin
        flag_low <= 1'b0;
    end
end
always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn)
        flags_high <= 1'b0;
    else if ((cpha ^ cpol)) begin
        if (sclk == 1'b0) begin
            flags_high <= 1'b0;
        end else if (count == BaudRateDivisor - 2) begin
            flags_high <= 1'b1;
        end else begin
            flags_high <= 1'b0;
        end
    end else begin
        flags_high <= 1'b0;
    end
end
always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn)
        flag_high <= 1'b0;
    else if ((cpha ^ cpol)) begin
        if (sclk == 1'b0) begin
            flag_high <= 1'b0;
        end else if (count == BaudRateDivisor - 1) begin
            flag_high <= 1'b1;
        end else begin
            flag_high <= 1'b0;
        end
    end else begin
        flag_high <= 1'b0;
    end
end


        
       

endmodule
