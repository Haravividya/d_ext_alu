module fp_cvt_ld (
    input [63:0] d,      // Double-precision input
    input signed_ctrl,
    output reg [63:0] l  // 64-bit signed integer output
);

    // Extract IEEE 754 fields
    wire        sign     = d[63];
    wire [10:0] exp      = d[62:52];
    wire [51:0] mantissa = d[51:0];

    // Special case detection
    wire is_nan    = (exp == 11'h7FF) && (mantissa != 0);
    wire is_inf    = (exp == 11'h7FF) && (mantissa == 0);
    wire is_zero   = (exp == 0) && (mantissa == 0);

    // Internal signals
    reg [63:0]  unsigned_val;
    reg [10:0]  unbiased_exp;
    reg [52:0]  significand; // 53-bit (1 + 52-bit mantissa)
    integer     shift_amt;

    always @(*) begin
        if (is_nan) begin
            l = 64'h8000000000000000; // NaN ? minimum value
        end else if (is_inf) begin
            l = sign ? 64'h8000000000000000 : 64'h7FFFFFFFFFFFFFFF; // ±inf clamp
        end else if (is_zero) begin
            l = 64'b0; // Zero ? 0
        end else begin
            // Calculate unbiased exponent and significand
            unbiased_exp = exp - 11'd1023; // Remove bias
            significand = {1'b1, mantissa}; // Add implicit leading 1

            if ($signed(unbiased_exp) < 0) begin
                // Value < 1.0 ? truncate to 0
                unsigned_val = 64'b0;
            end else if (unbiased_exp >= 11'd64) begin
                // Exceeds 64-bit range ? clamp
                unsigned_val = 64'h7FFFFFFFFFFFFFFF;
            end else begin
                // Calculate shift amount
                shift_amt = unbiased_exp - 11'd52;
                
                if (shift_amt >= 0) begin
                    // Left shift for integer part
                    unsigned_val = significand << shift_amt;
                end else begin
                    // Right shift for fractional truncation
                    unsigned_val = significand >> (-shift_amt);
                end
            end

            // Apply sign and clamp
            if (signed_ctrl && sign) begin
                l = (unsigned_val > 64'h8000000000000000) ? 
                    64'h8000000000000000 : 
                    ~unsigned_val + 1; // Two's complement
            end else begin
                l = (unsigned_val > 64'h7FFFFFFFFFFFFFFF) ? 
                    64'h7FFFFFFFFFFFFFFF : 
                    unsigned_val;
            end
        end
    end

endmodule
