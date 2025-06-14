// fp_addsub_d.v
// Simplified 64-bit IEEE-754 double precision adder/subtractor
// op = 0 => addition, op = 1 => subtraction (by inverting b's sign)
// Note: This is a basic behavioral implementation and does not fully comply with IEEE-754.
module fp_addsub_d (
    input  [63:0] a,      // first double operand
    input  [63:0] b,      // second double operand
    input         op,     // operation: 0 for add, 1 for subtract
  //  input  [2:0]  rm,     // rounding mode (not used)
    output [63:0] result  // result of addition/subtraction
);

    // Extract sign, exponent, and fraction fields.
    // IEEE-754 double: [63] sign, [62:52] exponent, [51:0] fraction.
    wire        sign_a = a[63];
    wire [10:0] exp_a  = a[62:52];
    wire [51:0] frac_a = a[51:0];

    wire        sign_b = b[63];
    wire [10:0] exp_b  = b[62:52];
    wire [51:0] frac_b = b[51:0];

    // For normalized numbers, the implicit leading 1 is added.
    // For simplicity, denormalized numbers are treated as having a 0 leading bit.
    wire [52:0] sig_a = (exp_a != 0) ? {1'b1, frac_a} : {1'b0, frac_a};
    wire [52:0] sig_b = (exp_b != 0) ? {1'b1, frac_b} : {1'b0, frac_b};

    // For subtraction, invert the sign of b.
    wire effective_sign_b = op ? ~sign_b : sign_b;

    // Determine which operand has the larger exponent (or, if equal, larger significand).
    wire a_greater = (exp_a > exp_b) || ((exp_a == exp_b) && (sig_a >= sig_b));
    wire [10:0] exp_diff = a_greater ? (exp_a - exp_b) : (exp_b - exp_a);
    wire [52:0] sig_small = a_greater ? sig_b : sig_a;
    wire [52:0] sig_large = a_greater ? sig_a : sig_b;
    wire        sign_large = a_greater ? sign_a : effective_sign_b;

    // Align the smaller significand by shifting right.
    wire [52:0] sig_small_aligned = sig_small >> exp_diff;

    // Depending on the signs, either add or subtract the significands.
    // Extend one extra bit to capture possible carry.
    wire [53:0] sig_sum = (sign_a == effective_sign_b) ? 
                          ({1'b0, sig_large} + {1'b0, sig_small_aligned}) :
                          ({1'b0, sig_large} - {1'b0, sig_small_aligned});

    // Normalize the result.
    reg [10:0] final_exp;
    reg [52:0] final_sig;
    reg        final_sign;
    reg [53:0] norm;
    integer i;
    always @(*) begin
        if (sig_sum == 0) begin
            // Result is zero: force sign to positive (0)
            final_exp  = 0;
            final_sig  = 0;
            final_sign = 1'b0;
        end
        else if (sign_a == effective_sign_b) begin
            // Addition: if there is an extra carry out, shift right.
            if (sig_sum[53] == 1) begin
                final_sig = sig_sum[53:1];
                final_exp = (a_greater ? exp_a : exp_b) + 1;
            end
            else begin
                final_sig = sig_sum[52:0];
                final_exp = (a_greater ? exp_a : exp_b);
            end
            final_sign = sign_large;
        end
        else begin
            // Subtraction: normalize by left-shifting until MSB is 1.
            norm = sig_sum;
            final_exp = (a_greater ? exp_a : exp_b);
            for (i = 0; i < 54; i = i + 1) begin
                if (norm[52] == 1)
                    i = 54;  // break the loop
                else begin
                    norm = norm << 1;
                    final_exp = final_exp - 1;
                end
            end
            final_sig = norm[52:0];
            final_sign = sign_large;
        end
    end

    // Pack the final sign, exponent, and fraction back into IEEE-754 format.
    // For normalized numbers, the implicit leading 1 is not stored.
    assign result = {final_sign, final_exp, final_sig[51:0]};

endmodule

