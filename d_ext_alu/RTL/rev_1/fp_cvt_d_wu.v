module fp_cvt_d_wu(
    input [31:0] wu,         // Unsigned integer input
    output reg  [63:0] d      // Double-precision floating-point output
);

    // Internal signals
    reg [4:0] lz;            // Leading zero count (adjusted for 32-bit inputs)
    reg [10:0] exponent;     // IEEE-754 exponent field
    reg [51:0] mantissa;     // Mantissa field for double precision
    reg [63:0] normalized;   // Normalized shifted value

    integer i;               // Loop variable for combinational logic

    always @(*) begin
        lz = 5'd0;
        
        if (wu == 32'b0) begin
            // Handle zero input case directly
            d = 64'b0;
        end else begin
            // Find leading one position and calculate leading zero count
            for (i = 31; i >= 0; i = i - 1) begin
                if (wu[i] && (lz == 0)) begin // Only set lz on the first '1'
                    lz = 31 - i;
                end
            end

            // Calculate exponent field (bias = 1023)
            exponent = (31 - lz) + 11'd1023;

            // Normalize the input by left-shifting it so the MSB aligns at bit position 52
            normalized = wu << (52 - (31 - lz));

            // Extract mantissa (lower 52 bits of the normalized value)
            mantissa = normalized[51:0];

            // Assemble IEEE-754 double-precision result with sign=0 since input is unsigned
            d = {1'b0, exponent, mantissa};
        end
    end

endmodule

