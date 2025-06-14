//------------------------------------------------------------------------------
// fp_mul_d.v
// Double-precision floating-point multiplier (IEEE 754)
// This module multiplies two 64-bit double-precision operands,
// implementing round-to-nearest even (default rounding).
//------------------------------------------------------------------------------

// Note: The IEEE 754 double format:
//   [63]     : Sign
//   [62:52]  : Exponent (11 bits), bias = 1023
//   [51:0]   : Fraction (mantissa bits); for normalized numbers an implicit "1" is assumed.

module fp_mul_d (
    input  wire [63:0] a,     // operand A (double-precision)
    input  wire [63:0] b,     // operand B (double-precision)
    output wire [63:0] result // result (double-precision)
);

    //--------------------------------------------------------------------------
    // Extract sign, exponent and fraction fields
    //--------------------------------------------------------------------------
    wire         sign_a = a[63];
    wire [10:0]  exp_a  = a[62:52];
    wire [51:0]  frac_a = a[51:0];

    wire         sign_b = b[63];
    wire [10:0]  exp_b  = b[62:52];
    wire [51:0]  frac_b = b[51:0];

    // Determine whether inputs are normalized (nonzero exponent) or denormal
    wire         a_normal = |exp_a;
    wire         b_normal = |exp_b;

    // For normalized numbers, the 53-bit significand includes the hidden bit.
    wire [52:0]  mant_a = a_normal ? {1'b1, frac_a} : {1'b0, frac_a};
    wire [52:0]  mant_b = b_normal ? {1'b1, frac_b} : {1'b0, frac_b};

    //--------------------------------------------------------------------------
    // Special-case detection (zero, infinity, NaN)
    //--------------------------------------------------------------------------
    wire a_zero = (exp_a == 11'd0) && (frac_a == 52'd0);
    wire b_zero = (exp_b == 11'd0) && (frac_b == 52'd0);

    wire a_inf  = (exp_a == 11'h7FF) && (frac_a == 52'd0);
    wire b_inf  = (exp_b == 11'h7FF) && (frac_b == 52'd0);
    wire a_nan  = (exp_a == 11'h7FF) && (frac_a != 52'd0);
    wire b_nan  = (exp_b == 11'h7FF) && (frac_b != 52'd0);

    // Compute the sign of the product
    wire sign_res = sign_a ^ sign_b;

    //--------------------------------------------------------------------------
    // Exponent calculation
    // For normalized numbers, the unbiased exponent is (exp - bias).
    // For denormals, treat exponent as 1-bias (i.e. –1022).
    //--------------------------------------------------------------------------
    // The bias for double precision is 1023.
    wire signed [12:0] exp_a_unb = a_normal ? ($signed({1'b0, exp_a}) - 13'sd1023)
                                             : (13'sd1 - 13'sd1023);
    wire signed [12:0] exp_b_unb = b_normal ? ($signed({1'b0, exp_b}) - 13'sd1023)
                                             : (13'sd1 - 13'sd1023);

    // When multiplying, the new (unbiased) exponent is sum of exponents.
    // Then add back the bias.
    wire signed [12:0] exp_sum = exp_a_unb + exp_b_unb + 13'sd1023;

    //--------------------------------------------------------------------------
    // Mantissa multiplication (53x53 -> 106 bits)
    //--------------------------------------------------------------------------
    wire [105:0] mant_product = mant_a * mant_b;

    //--------------------------------------------------------------------------
    // Normalization:
    // The product may be in the range [1.0,4.0). If the top bit (bit 105) is 1,
    // then the result is [2.0,4.0) – shift right by one and increment exponent.
    // Otherwise, leave the product as is.
    //--------------------------------------------------------------------------
    wire product_norm = mant_product[105]; // If set, the product is >= 2.0.
    wire [105:0] shifted_product = mant_product; // alias for clarity

    // Choose the raw (unrounded) mantissa:
    // If product_norm == 1, take the upper 53 bits [105:53];
    // else take bits [104:52].
    wire [52:0] raw_mantissa = product_norm ? shifted_product[105:53]
                                            : shifted_product[104:52];

    // Adjust exponent according to normalization: if shifted, increment exponent.
    wire [12:0] adjusted_exp = product_norm ? (exp_sum + 13'd1) : exp_sum;

    //--------------------------------------------------------------------------
    // Rounding (round-to-nearest even)
    // Use the next two bits plus the OR of lower bits (sticky ­– all for tie breaking).
    //--------------------------------------------------------------------------
    // Identify guard, round and sticky bits.
    // For product_norm==1, guard is bit 52; round is bit 51; sticky = OR of bits [50:0].
    // For product_norm==0, guard is bit 51; round is bit 50; sticky = OR of bits [49:0].
    wire guard_bit = product_norm ? shifted_product[52] : shifted_product[51];
    wire round_bit = product_norm ? shifted_product[51] : shifted_product[50];
    wire sticky_bit = product_norm ? (|shifted_product[50:0]) : (|shifted_product[49:0]);

    // Decide whether to round up.
    // (Round-to-nearest even) Increment if guard is 1 and any of (round, sticky, or LSB=1) is true.
   // wire round_inc = guard_bit && (round_bit || sticky_bit || raw_mantissa[0]);
   wire round_inc = guard_bit && (round_bit || sticky_bit || 
                              (!round_bit && !sticky_bit && raw_mantissa[0]));

    // Add round increment (giving one extra bit in case of carry out)
    wire [53:0] mantissa_rounded = {1'b0, raw_mantissa} + round_inc;

    // If rounding causes an overflow (i.e. a carry into bit 53), then renormalize:
    wire round_overflow = mantissa_rounded[53];

    // Select final 53-bit mantissa and adjust exponent if necessary.
    wire [52:0] final_mantissa = round_overflow ? mantissa_rounded[53:1] : mantissa_rounded[52:0];
    wire [12:0] final_exp      = round_overflow ? (adjusted_exp + 13'd1) : adjusted_exp;

    //--------------------------------------------------------------------------
    // Check for exponent overflow/underflow
    // If final_exp is too high, output infinity.
    // If too low, output zero (for simplicity, subnormals are rounded to zero).
    //--------------------------------------------------------------------------
    wire exp_overflow  = (final_exp >= 13'd2047); // exponent field is 11 bits (max=2047)
    wire exp_underflow = (final_exp <= 13'd0);

    //--------------------------------------------------------------------------
    // Pack the result 
    // Special cases are handled first.
    //--------------------------------------------------------------------------
    reg [63:0] fp_result;
    always @(*) begin
        if (a_nan || b_nan) begin
            // If either operand is a NaN, return a canonical quiet NaN.
            fp_result = {1'b0, 11'h7FF, 52'h8000000000000};
        end else if ((a_inf && b_zero) || (b_inf && a_zero)) begin
            // Infinity * Zero is an invalid operation.
            fp_result = {1'b0, 11'h7FF, 52'h8000000000000}; // return a NaN
        end else if (a_inf || b_inf) begin
            // If either operand is infinity, return infinity with the correct sign.
            fp_result = {sign_res, 11'h7FF, 52'd0};
        end else if (a_zero || b_zero) begin
            // If either operand is zero, the result is zero (with correct sign).
            fp_result = {sign_res, 11'd0, 52'd0};
        end else if (exp_overflow) begin
            // Exponent overflow—return infinity.
            fp_result = {sign_res, 11'h7FF, 52'd0};
        end else if (exp_underflow) begin
            // Exponent underflow—return zero (or could generate a subnormal, if desired).
            fp_result = {sign_res, 11'd0, 52'd0};
        end else begin
            // Normal multiplication result.
            fp_result = {sign_res, final_exp[10:0], final_mantissa[51:0]};
        end
    end

    assign result = fp_result;

endmodule

