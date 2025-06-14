module fp_cvt_wd(
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

