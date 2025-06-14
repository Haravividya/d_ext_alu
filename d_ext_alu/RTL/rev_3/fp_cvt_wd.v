/*module fp_cvt_wd(
    input  [31:0] w,       // 32-bit integer input
    input         signed_ctrl, // Indicates whether the input is signed or unsigned
   // input  [2:0]  rm,       // Rounding mode (not used)
    output reg [63:0] d     // 64-bit double precision output
);

    // Extract sign and absolute value of the integer
    wire sign = signed_ctrl ? w[31] : 1'b0; // Signed input uses MSB as the sign bit
    wire [31:0] abs_w = signed_ctrl && sign ? (~w + 1) : w; // Compute absolute value for signed inputs

    // Intermediate signals for exponent and fraction
    reg [10:0] exp_d;
    reg [51:0] frac_d;
    reg [31:0] normalized_w;
    reg [4:0] shift;

    always @(*) begin
        if (w == 32'd0) begin
            // Case: Zero input
            exp_d  = 11'd0;
            frac_d = 52'd0;
        end else begin
            // Normalize the integer by finding the leading one
            normalized_w = abs_w;
            shift = 0;

            while (normalized_w[31] == 1'b0) begin
                normalized_w = normalized_w << 1;
                shift = shift + 1;
            end

            // Compute exponent and fraction for double-precision format
            exp_d = 11'd1023 + (31 - shift); // Exponent bias for double precision is 1023
            frac_d = {normalized_w[30:0], 21'b0}; // Place normalized value in fraction field (truncate lower bits)
        end

        // Combine sign, exponent, and fraction into the double-precision result
        d = {sign, exp_d, frac_d};
    end

endmodule

*/

/*module fp_cvt_wd(
    input [31:0] w,         // Signed integer input
    input signed_ctrl,      // Indicates whether the input is signed or unsigned
    output reg [63:0] d     // Double-precision floating-point output
);

    wire sign = signed_ctrl ? w[31] : 1'b0; // Extract sign bit for signed integers
    wire [31:0] abs_w = signed_ctrl && sign ? (~w + 1) : w; // Compute absolute value for signed inputs

    reg [10:0] exp_d;      // Exponent field for double precision
    reg [51:0] frac_d;     // Fraction field for double precision
    reg [31:0] normalized_w; // Normalized shifted value
    reg [4:0] shift;       // Shift count for normalization

    always @(*) begin
        if (w == 32'd0) begin
            // Handle zero input case directly
            exp_d = 11'd0;
            frac_d = 52'd0;
            d = {sign, exp_d, frac_d};
        end else begin
            // Initialize normalization variables
            normalized_w = abs_w;
            shift = 5'b0;

            // Normalize the integer by finding the leading one position
            while (normalized_w[31] == 1'b0) begin
                normalized_w = normalized_w << 1;
                shift = shift + 1;
            end

            if (shift > 31) begin
                // Overflow case: Set exponent to maximum value (Infinity)
                exp_d = 11'h7FF;
                frac_d = 52'b0;
            end else begin
                // Normal case: Calculate exponent and mantissa fields with rounding logic added
                exp_d = 11'd1023 + (31 - shift); 
                frac_d = {normalized_w[30:0], 21'b0} + normalized_w[31]; 
            end

            d = {sign, exp_d, frac_d}; // Combine sign, exponent, and fraction into IEEE-754 format result
        end 
    end

endmodule 
*/

module fp_cvt_wd(
    input [63:0] d,         // Double-precision floating-point input
    input signed_ctrl,      // Indicates whether the conversion is signed or unsigned
    output reg [31:0] w     // Signed 32-bit integer output
);

    // Extract fields from the double-precision input
    wire sign = d[63];
    wire [10:0] exp_d = d[62:52];  // Exponent field
    wire [51:0] frac_d = d[51:0]; // Fraction field

    // Intermediate signals
    reg [63:0] mantissa;          // Mantissa with implied leading 1 for normalized numbers
    reg [31:0] shifted_mantissa;  // Mantissa shifted based on exponent
    reg [10:0] effective_exp;     // Effective exponent after bias adjustment

    always @(*) begin
        if (exp_d == 11'h7FF) begin
            // Handle special cases (NaN or Infinity)
            w = 32'h00000000; // Return 0 for NaN or Infinity (can be customized)
        end else if (exp_d == 11'h000) begin
            // Handle subnormal numbers or zero
            w = 32'h00000000; // Return 0 for subnormal numbers or zero
        end else begin
            // Normalized case: Adjust exponent and compute integer value
            effective_exp = exp_d - 11'd1023; // Adjust exponent bias for double precision

            if (effective_exp > 31) begin
                // Overflow case: Exponent too large to fit in 32 bits
                w = signed_ctrl ? (sign ? 32'h80000000 : 32'h7FFFFFFF) : 32'hFFFFFFFF;
            end else if (effective_exp < 0) begin
                // Underflow case: Exponent too small to represent as an integer
                w = 32'h00000000;
            end else begin
                // Normal case: Compute integer value from mantissa and exponent
                mantissa = {1'b1, frac_d}; // Add implicit leading 1 for normalized numbers
                shifted_mantissa = mantissa >> (52 - effective_exp); // Right-shift mantissa

                if (signed_ctrl && sign) begin
                    w = ~shifted_mantissa + 1; // Apply two's complement for negative values
                end else begin
                    w = shifted_mantissa[31:0]; // Truncate to 32 bits for unsigned values
                end
            end
        end
    end

endmodule

