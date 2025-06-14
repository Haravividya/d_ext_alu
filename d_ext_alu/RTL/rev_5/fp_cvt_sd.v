module fp_cvt_sd(
    input  [31:0] s,      // 32-bit single precision input
   // input  [2:0]  rm,     // Rounding mode (not used)
    output reg [63:0] d   // 64-bit double precision output
);

    // Extract single precision fields.
    wire        sign    = s[31];
    wire [7:0]  exp_s   = s[30:23];
    wire [22:0] frac_s  = s[22:0];

    // Intermediate signals for double fields.
    reg  [10:0] exp_d;
    reg  [51:0] frac_d;

    always @(*) begin
        // Convert normalized single-precision input to double-precision format.
        exp_d  = exp_s + 11'd896;       // Adjust exponent bias (1023 - 127 = 896)
        frac_d = {frac_s, 29'b0};       // Shift single fraction to double fraction field

        // Combine sign, exponent, and fraction into the double-precision result.
        d = {sign, exp_d, frac_d};
    end

endmodule

