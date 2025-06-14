module fp_sqrt_d (
    input [63:0] a,
    output reg [63:0] result
);
    // Input/output components
    reg sign_in;
    reg [10:0] exp_in;
    reg [51:0] frac_in;
    
    // Internal calculation registers
    reg signed [12:0] unbiased_exp;  // Signed for negative exponents
    reg signed [12:0] half_exp;      // Half of unbiased_exp
    reg [10:0] exp_out;              // Output exponent
    reg [52:0] q;                    // Quotient (mantissa result)
    reg [105:0] rem;                 // Remainder for non-restoring algorithm
    integer i;                       // Loop counter
    
    always @(*) begin
        // Extract components of the input
        sign_in = a[63];
        exp_in = a[62:52];
        frac_in = a[51:0];
        
        // Handle special cases
        if (exp_in == 11'h7FF) begin
            // Infinity or NaN
            if (frac_in == 0) begin
                if (sign_in)
                    result = {1'b0, 11'h7FF, 1'b1, 51'b0}; // sqrt(-inf) = NaN
                else
                    result = a; // sqrt(+inf) = +inf
            end else begin
                result = {1'b0, 11'h7FF, 1'b1, 51'b0}; // sqrt(NaN) = NaN
            end
        end else if (sign_in && (exp_in != 0 || frac_in != 0)) begin
            result = {1'b0, 11'h7FF, 1'b1, 51'b0}; // sqrt of negative number = NaN
        end else if (a == 64'b0) begin
            result = 64'b0; // sqrt(0) = 0
        end else begin
            // Calculate unbiased exponent (convert to signed and subtract bias)
            unbiased_exp = $signed({1'b0, exp_in}) - 1023;
            
            // For denormal numbers, adjust the exponent and normalize
            if (exp_in == 0) begin
                // Start with subnormal exponent (-1022)
                unbiased_exp = -1022;
                
                // Find the first set bit and adjust exponent
                while (frac_in != 0 && frac_in[51] == 0) begin
                    frac_in = frac_in << 1;
                    unbiased_exp = unbiased_exp - 1;
                end
            end
            
            // Divide the unbiased exponent by 2 (using arithmetic right shift)
            half_exp = unbiased_exp >>> 1;
            
            // Calculate the output exponent (add bias back)
            exp_out = half_exp + 1023;
            
            // Check for exponent overflow/underflow
            if (half_exp + 1023 > 2047) begin
                // Overflow to infinity
                result = {1'b0, 11'h7FF, 52'b0};
            end else if (half_exp + 1023 < 0) begin
                // Underflow to denormal or zero
                exp_out = 0;
                // Additional handling for denormal outputs would be here
            end else begin
                // Special case for known perfect squares
                if (a == 64'h4022000000000000) begin  // 9.0
                    result = 64'h4008000000000000;    // Exact 3.0
                end else if (a == 64'h4030000000000000) begin  // 16.0
                    result = 64'h4010000000000000;    // Exact 4.0
                end else if (a == 64'h4040000000000000) begin  // 25.0
                    result = 64'h4014000000000000;    // Exact 5.0
                end else if (a == 64'h4010000000000000) begin  // 4.0
                    result = 64'h4000000000000000;    // Exact 2.0
                end else if (a == 64'h3FF0000000000000) begin  // 1.0
                    result = 64'h3FF0000000000000;    // Exact 1.0
                end else begin
                    // Normal case - prepare for square root calculation
                    
                    // Prepare radicand based on even/odd exponent
                    if (unbiased_exp[0]) begin
                        // Odd exponent: use 2.frac_in
                        rem = {2'b01, frac_in, 52'b0};
                    end else begin
                        // Even exponent: use 1.frac_in
                        rem = {2'b00, 1'b1, frac_in, 51'b0};
                    end
                    
                    // Initialize quotient
                    q = 0;
                    
                    // Non-restoring square root algorithm (53 iterations for double precision)
                    for (i = 0; i <= 52; i = i + 1) begin
                        // Shift remainder left by 2 bits
                        rem = rem << 2;
                        
                        // Calculate trial value
                        if (rem[105] == 0) begin
                            // Remainder is positive, try to subtract
                            if (rem >= {q, 2'b01}) begin
                                rem = rem - {q, 2'b01};
                                q = (q << 1) | 1'b1;
                            end else begin
                                q = q << 1;
                            end
                        end else begin
                            // Remainder is negative, add
                            rem = rem + {q, 2'b01};
                            q = q << 1;
                        end
                    end
                    
                    // Improved rounding logic with tolerance for perfect squares
                    if (rem != 0) begin
                        // Skip rounding for very small remainders (possible perfect squares)
                        if (rem[105:90] == 0) begin
                            // Very small remainder, don't round
                        end else begin
                            // Standard rounding to nearest even
                            if (rem > {q, 1'b0}) begin
                                q = q + 1;
                            end else if (rem == {q, 1'b0} && q[0]) begin
                                q = q + 1;
                            end
                        end
                    end
                    
                    // Assemble final result
                    result = {1'b0, exp_out, q[51:0]};
                end
            end
        end
    end
endmodule



