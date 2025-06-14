module fp_cvt_ds(
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

