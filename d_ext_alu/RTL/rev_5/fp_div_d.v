/*module fp_div_d (
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
*/

module fp_div_d (
    input  wire [63:0] a,       // Operand A: 64-bit IEEE-754 double-precision value
    input  wire [63:0] b,       // Operand B: 64-bit IEEE-754 double-precision value
    output wire [63:0] result   // Result: 64-bit IEEE-754 double-precision quotient
);

    // ------------------------------------------------------------
    // Extract sign, exponent, and fraction fields from operand A.
    // ------------------------------------------------------------
    wire         sign_a  = a[63];      
    wire [10:0]  exp_a   = a[62:52];   
    wire [51:0]  frac_a  = a[51:0];    

    // ------------------------------------------------------------
    // Extract sign, exponent, and fraction fields from operand B.
    // ------------------------------------------------------------
    wire         sign_b  = b[63];      
    wire [10:0]  exp_b   = b[62:52];   
    wire [51:0]  frac_b  = b[51:0];    

    // ------------------------------------------------------------
    // Determine if operands are normalized.
    // ------------------------------------------------------------
    wire a_normal = (exp_a != 11'd0);
    wire b_normal = (exp_b != 11'd0);

    // ------------------------------------------------------------
    // Construct 53-bit significands by appending the implicit 1 for normalized numbers.
    // For denormals, the leading bit is 0.
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
    // Compute the result's sign.
    // ------------------------------------------------------------
    wire sign_res = sign_a ^ sign_b;

    // ------------------------------------------------------------
    // Compute unbiased exponents for operands.
    // For normalized numbers: unbiased exponent = exponent - 1023.
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
    // ------------------------------------------------------------
    wire [104:0] numerator = mant_a << 52;  // 53 bits shifted left by 52 = 105 bits.
    wire [52:0] q = numerator / mant_b;       // Quotient is 53 bits wide.

    // ------------------------------------------------------------
    // Normalize the quotient:
    // The normalized significand must have its MSB (bit 52) set to 1.
    // If not, shift left and adjust exponent.
    // ------------------------------------------------------------
    wire is_normal = q[52];
    wire [52:0] norm_q = is_normal ? q : (q << 1);
    wire signed [12:0] norm_adjust = is_normal ? 13'sd0 : -13'sd1;
    wire signed [12:0] final_exp = exp_prelim + norm_adjust;

    // ------------------------------------------------------------
    // Check for overflow.
    // ------------------------------------------------------------
    wire exp_overflow  = (final_exp >= 13'sd2047);

    // ------------------------------------------------------------
    // Rounding function: round-to-nearest (ties to even).
    // This function shifts an extended significand right by a given amount and rounds.
    // ------------------------------------------------------------
    function [63:0] round_shift;
      input [63:0] ext_sig;
      input integer shift_amt;
      reg   [63:0] shifted;
      reg   [63:0] lost;
      begin
        shifted = ext_sig >> shift_amt;
        lost = ext_sig & ((64'd1 << shift_amt) - 64'd1);
        if (shift_amt > 0) begin
          if (lost > (64'd1 << (shift_amt - 1)))
             shifted = shifted + 64'd1;
          else if (lost == (64'd1 << (shift_amt - 1)))
             if (shifted[0] == 1'b1)
                shifted = shifted + 64'd1;
        end
        round_shift = shifted;
      end
    endfunction

    // ------------------------------------------------------------
    // Final result packaging with round-to-nearest and subnormal support.
    // For normalized numbers, we round the 53-bit significand to 52 bits.
    // For underflow (final_exp <= 0), we shift the significand right by (1 - final_exp)
    // extra bits (in addition to the normal 11-bit shift) to produce a subnormal number.
    // ------------------------------------------------------------
    reg [63:0] fp_result;
    integer shift_amt;
    reg [63:0] ext_sig;   // Extended version of norm_q for rounding.
    reg [51:0] frac_round;
    
    always @(*) begin
        if (a_nan || b_nan) begin
            // Canonical quiet NaN.
            fp_result = {1'b0, 11'h7FF, 52'h8000000000000};
        end else if ((a_inf && b_inf) || (a_zero && b_zero)) begin
            // Indeterminate: NaN.
            fp_result = {1'b0, 11'h7FF, 52'h8000000000000};
        end else if (b_zero) begin
            // Division by zero yields infinity.
            fp_result = {sign_res, 11'h7FF, 52'd0};
        end else if (a_inf) begin
            fp_result = {sign_res, 11'h7FF, 52'd0};
        end else if (a_zero) begin
            fp_result = {sign_res, 11'd0, 52'd0};
        end else if (exp_overflow) begin
            fp_result = {sign_res, 11'h7FF, 52'd0};
        end else if (final_exp <= 0) begin
            // Subnormal result:
            // Shift additional bits = (1 - final_exp) in addition to the normal 11-bit shift.
            shift_amt = 11 + (1 - final_exp);
            // Extend norm_q to 64 bits.
            ext_sig = {norm_q, 11'd0};  // 53+11 = 64 bits.
            ext_sig = round_shift(ext_sig, shift_amt);
            frac_round = ext_sig[51:0];
            fp_result = {sign_res, 11'd0, frac_round};
        end else begin
            // Normalized result:
            ext_sig = {norm_q, 11'd0};  // 64 bits.
            ext_sig = round_shift(ext_sig, 11);
            frac_round = ext_sig[51:0];
            fp_result = {sign_res, final_exp[10:0], frac_round};
        end
    end

    // ------------------------------------------------------------
    // Drive the module output.
    // ------------------------------------------------------------
    assign result = fp_result;

endmodule

