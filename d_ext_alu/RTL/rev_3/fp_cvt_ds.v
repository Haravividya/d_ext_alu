/*module fp_cvt_ds(
    input  [63:0] d,      // 64-bit double precision input
  //  input  [2:0]  rm,     // Rounding mode (not used)
    output reg [31:0] s   // 32-bit single precision output
);

    // Extract double precision fields.
    wire        sign    = d[63];
    wire [10:0] exp_d   = d[62:52];
    wire [51:0] frac_d  = d[51:0];

    // Intermediate signals for single precision fields.
    reg  [7:0]  exp_s;
    reg  [22:0] frac_s;

    always @(*) begin
        // Convert normalized double-precision input to single-precision format.
        exp_s  = exp_d - 11'd896;       // Adjust exponent bias (127 - 1023 = -896)
        frac_s = frac_d[51:29];         // Truncate the fraction to fit into single-precision

        // Combine sign, exponent, and fraction into the single-precision result.
        s = {sign, exp_s, frac_s};
    end

endmodule
*/

/*module fp_cvt_ds(
    input [63:0] d,         // Double-precision input
    output reg [31:0] s     // Single-precision output
);

    // Extract double-precision fields
    wire sign = d[63];
    wire [10:0] exp_d = d[62:52];
    wire [51:0] frac_d = d[51:0];

    // Intermediate signals for single precision fields
    reg [7:0] exp_s;
    reg [22:0] frac_s;

    always @(*) begin
        if (exp_d == 11'h7FF) begin
            // Handle NaN and Infinity
            if (frac_d != 0)
                s = {sign, 8'hFF, 23'h400000}; // Canonical NaN for single precision
            else
                s = {sign, 8'hFF, 23'b0};      // Infinity
        end else if (exp_d == 0) begin
            // Handle subnormal numbers or zero
            s = {sign, 8'b0, frac_d[51:29]};
        end else begin
            // Normal case: Adjust exponent and truncate fraction with rounding logic
            exp_s = exp_d - 11'd896;          // Adjust exponent bias (127 - 1023)
            frac_s = frac_d[51:29] + frac_d[28]; // Round-to-nearest using next bit
            s = {sign, exp_s, frac_s};
        end
    end

endmodule
*/

module fp_cvt_ds(
    input [63:0] d,         // Double-precision input
    output reg [31:0] s     // Single-precision output
);

    // Extract double-precision fields
    wire sign = d[63];
    wire [10:0] exp_d = d[62:52];
    wire [51:0] frac_d = d[51:0];

    // Intermediate signals for single precision fields
    reg [7:0] exp_s;
    reg [22:0] frac_s;
    integer shift_amt;  // Declare integer variable for shifting

    always @(*) begin
        if (exp_d == 11'h7FF) begin
            // Handle NaN and Infinity cases
            if (frac_d != 0)
                s = {sign, 8'hFF, 23'h400000}; // Canonical NaN for single precision
            else
                s = {sign, 8'hFF, 23'b0};      // Infinity
        end else if (exp_d < 11'd896) begin
            // Handle underflow: Too small to be represented in single-precision
            s = {sign, 8'b0, 23'b0}; // Force zero
        end else if (exp_d < 11'd1023) begin
            // Handle subnormal numbers in single precision
            shift_amt = 11'd1023 - exp_d; // Compute shift amount
            frac_s = (frac_d >> (shift_amt + 1)) + ((frac_d >> shift_amt) & 1); // Round-to-nearest
            s = {sign, 8'b0, frac_s}; // Subnormal single-precision number
        end else begin
            // Normal case: Adjust exponent and truncate fraction with rounding logic
            exp_s = exp_d - 11'd896; // Adjust exponent bias (127 - 1023)
            frac_s = frac_d[51:29] + frac_d[28]; // Round-to-nearest using next bit

            // Handle rounding overflow
            if (frac_s == 23'b10000000000000000000000) begin  // Corrected 23-bit check
                exp_s = exp_s + 1;
                frac_s = 23'b0;
            end

            s = {sign, exp_s, frac_s};
        end
    end

endmodule

