module fp_div_d (
    input  wire [63:0] a,       // Operand A: 64-bit IEEE-754 double-precision value
    input  wire [63:0] b,       // Operand B: 64-bit IEEE-754 double-precision value
    output wire [63:0] result   // Result: 64-bit IEEE-754 double-precision quotient
);

    // ------------------------------------------------------------
    // Extract sign, exponent, and fraction fields from operand A.
    // ------------------------------------------------------------
    wire         sign_a  = a[63];      // Sign bit of A
    wire [10:0]  exp_a   = a[62:52];   // Exponent field of A
    wire [51:0]  frac_a  = a[51:0];    // Fraction field (mantissa) of A

    // ------------------------------------------------------------
    // Extract sign, exponent, and fraction fields from operand B.
    // ------------------------------------------------------------
    wire         sign_b  = b[63];      // Sign bit of B
    wire [10:0]  exp_b   = b[62:52];   // Exponent field of B
    wire [51:0]  frac_b  = b[51:0];    // Fraction field (mantissa) of B

    // ------------------------------------------------------------
    // Determine if operands are normalized; nonzero exponent indicates a normalized value.
    // ------------------------------------------------------------
    wire a_normal = (exp_a != 11'd0);
    wire b_normal = (exp_b != 11'd0);

    // ------------------------------------------------------------
    // Construct 53-bit significands by appending the implicit leading 1 for normalized numbers.
    // For denormals the leading bit is 0.
    // ------------------------------------------------------------
    wire [52:0] mant_a = a_normal ? {1'b1, frac_a} : {1'b0, frac_a};
    wire [52:0] mant_b = b_normal ? {1'b1, frac_b} : {1'b0, frac_b};

    // ------------------------------------------------------------
    // Special-case detection for zeros, infinities, and NaNs.
    // ------------------------------------------------------------
    wire a_zero = (exp_a == 11'd0) && (frac_a == 52'd0);
    wire b_zero = (exp_b == 11'd0) && (frac_b == 52'd0);

    wire a_inf  = (exp_a == 11'h7FF) && (frac_a == 52'd0);
    wire b_inf  = (exp_b == 11'h7FF) && (frac_b == 52'd0);

    wire a_nan  = (exp_a == 11'h7FF) && (frac_a != 52'd0);
    wire b_nan  = (exp_b == 11'h7FF) && (frac_b != 52'd0);

    // ------------------------------------------------------------
    // Compute the result's sign by XORing the input sign bits.
    // ------------------------------------------------------------
    wire sign_res = sign_a ^ sign_b;

    // ------------------------------------------------------------
    // Compute unbiased exponents for operands.
    // For normalized numbers, unbiased exponent = exponent - 1023.
    // For denormals, use -1022.
    // ------------------------------------------------------------
    wire signed [12:0] exp_a_unb = a_normal ? ($signed({1'b0, exp_a}) - 13'sd1023) : -13'sd1022;
    wire signed [12:0] exp_b_unb = b_normal ? ($signed({1'b0, exp_b}) - 13'sd1023) : -13'sd1022;

    // ------------------------------------------------------------
    // Compute the preliminary (unadjusted) exponent for the quotient.
    // For division: final_exponent = (exp_a_unb - exp_b_unb) + 1023.
    // ------------------------------------------------------------
    wire signed [12:0] exp_prelim = exp_a_unb - exp_b_unb + 13'sd1023;

    // ------------------------------------------------------------
    // Divide the significands.
    // To maintain precision, shift the numerator (mant_a) left by 52 bits.
    // This produces a 105-bit numerator which divided by a 53-bit significand yields a 53-bit quotient.
    // ------------------------------------------------------------
    wire [104:0] numerator = mant_a << 52;  // 53 bits shifted left by 52 equals 105 bits.
    wire [52:0] q = numerator / mant_b;       // Quotient is 53 bits wide (truncated division).

    // ------------------------------------------------------------
    // Normalize the quotient:
    // The normalized significand must have its MSB (bit 52) set to 1.
    // If not already normalized, shift left by one and adjust exponent accordingly.
    // ------------------------------------------------------------
    wire is_normal = q[52];               // true if quotient is already normalized.
    wire [52:0] norm_q = is_normal ? q : (q << 1);  // Shift left if not normalized.
    wire signed [12:0] norm_adjust = is_normal ? 13'sd0 : -13'sd1;  // Decrement exponent if shifted.

    // ------------------------------------------------------------
    // Compute the final exponent after normalization adjustment.
    // ------------------------------------------------------------
    wire signed [12:0] final_exp = exp_prelim + norm_adjust;

    // ------------------------------------------------------------
    // Check for exponent overflow/underflow using signed constants.
    // If final_exp is >= 2047, it is an overflow; if <= 0 then it underflows.
    // (For simplicity, underflows are rounded to zero; subnormals are not handled.)
    // ------------------------------------------------------------
    wire exp_overflow  = (final_exp >= 13'sd2047);
    wire exp_underflow = (final_exp <= 13'sd0);

    // ------------------------------------------------------------
    // Pack the final result, handling special cases first.
    // ------------------------------------------------------------
    reg [63:0] fp_result;
    always @(*) begin
        if (a_nan || b_nan) begin
            // Return canonical quiet NaN if either input is NaN.
            fp_result = {1'b0, 11'h7FF, 52'h8000000000000};
        end else if ((a_inf && b_inf) || (a_zero && b_zero)) begin
            // Infinity divided by infinity or zero divided by zero: return NaN.
            fp_result = {1'b0, 11'h7FF, 52'h8000000000000};
        end else if (b_zero) begin
            // Division by zero: yield infinity with the proper sign.
            fp_result = {sign_res, 11'h7FF, 52'd0};
        end else if (a_inf) begin
            // Infinity divided by a finite number yields infinity.
            fp_result = {sign_res, 11'h7FF, 52'd0};
        end else if (a_zero) begin
            // Zero divided by any nonzero finite number yields zero.
            fp_result = {sign_res, 11'd0, 52'd0};
        end else if (exp_overflow) begin
            // Exponent overflow: return infinity.
            fp_result = {sign_res, 11'h7FF, 52'd0};
        end else if (exp_underflow) begin
            // Exponent underflow: return zero (subnormals are not handled).
            fp_result = {sign_res, 11'd0, 52'd0};
        end else begin
            // Normalized result: pack sign, final exponent (lower 11 bits), and fraction (lower 52 bits).
            fp_result = {sign_res, final_exp[10:0], norm_q[51:0]};
        end
    end

    // ------------------------------------------------------------
    // Drive the module output.
    // ------------------------------------------------------------
    assign result = fp_result;

endmodule

