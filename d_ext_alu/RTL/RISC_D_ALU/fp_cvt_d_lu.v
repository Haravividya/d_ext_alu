module fp_cvt_d_lu(
    input  [63:0] lu,   // 64-bit unsigned integer input
    output [63:0] d     // 64-bit double output (IEEE 754)
);

    // Internal signals
    reg [5:0] msb_index;      // Position of most significant '1'
    reg [63:0] shifted;       // Normalized value
    reg [10:0] exponent;      // IEEE 754 exponent field
    reg [51:0] mantissa;      // IEEE 754 mantissa field
    integer i;                // Declare loop variable outside the loop

    // Combinational logic to count leading zeros and calculate msb_index
    always @(*) begin
        msb_index = 6'd0;
        if (lu == 64'b0) begin
            msb_index = 6'd0;
        end else begin
            for (i = 63; i >= 0; i = i - 1) begin
                if (lu[i]) begin
                    msb_index = 6'd63 - i;
                end
            end
        end
    end

    // Calculate exponent (bias = 1023)
    always @(*) begin
        if (lu == 64'b0) begin
            exponent = 11'd0;
        end else begin
            exponent = msb_index + 11'd1023;
        end
    end

    // Normalize input to fit into IEEE 754 format
    always @(*) begin
        if (msb_index > 6'd52) begin
            shifted = lu >> (msb_index - 6'd52);
        end else begin
            shifted = lu << (6'd52 - msb_index);
        end
    end

    // Extract mantissa (lower 52 bits of normalized value)
    always @(*) begin
        mantissa = shifted[51:0];
    end

    // Form the IEEE 754 double-precision result:
    assign d = (lu == 64'b0) ? 64'b0 : {1'b0, exponent, mantissa};

endmodule

