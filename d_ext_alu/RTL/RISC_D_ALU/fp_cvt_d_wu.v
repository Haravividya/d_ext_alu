module fp_cvt_d_wu(
    input  [31:0] wu,    // 32-bit unsigned integer input
    output [63:0] d      // 64-bit double output (IEEE 754)
);

    // Internal signals
    reg [4:0] lz;            // Leading zero count
    reg [4:0] msb_index;     // Position of most significant '1'
    reg [10:0] exponent;     // IEEE 754 exponent field
    reg [63:0] mantissa;     // Mantissa field
    reg [63:0] normalized;   // Normalized shifted value

    integer i;               // Loop variable for combinational logic

    // Combinational logic to count leading zeros and calculate msb_index
    always @(*) begin
        lz = 5'd0;
        if (wu == 32'b0) begin
            lz = 5'd32;
        end else begin
            for (i = 31; i >= 0; i = i - 1) begin
                if (wu[i]) begin
                    lz = 31 - i;
                end
            end
        end
        msb_index = 5'd31 - lz;
    end

    // Calculate exponent and normalize input
    always @(*) begin
        if (wu == 32'b0) begin
            exponent = 11'd0;
            normalized = 64'b0;
        end else begin
            // Calculate exponent field (bias = 1023)
            exponent = msb_index + 11'd1023;

            // Normalize the input by left-shifting it so the MSB aligns at bit position 52
            normalized = wu << (52 - msb_index);
        end

        // Extract mantissa (lower 52 bits of the normalized value)
        mantissa = normalized[51:0];
    end

    // Assemble the final IEEE 754 double-precision result:
    assign d = (wu == 32'b0) ? 64'b0 : {1'b0, exponent, mantissa};

endmodule


