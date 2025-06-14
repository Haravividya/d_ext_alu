module fp_cvt_lu_d(
    input  [63:0] d,
    output reg [63:0] lu
);

    // IEEE 754 double-precision parameters
    localparam EXP_BITS  = 11;
    localparam FRAC_BITS = 52;
    localparam BIAS      = 11'd1023;

    // Extract fields from the double-precision input
    wire         sign;
    wire [EXP_BITS-1:0] exponent;
    wire [FRAC_BITS-1:0] fraction;

    assign sign     = d[63];
    assign exponent = d[62:52];
    assign fraction = d[51:0];

    // Create the normalized mantissa (53 bits: implicit 1 + fraction)
    wire [FRAC_BITS:0] mantissa;
    assign mantissa = {1'b1, fraction};

    // Combinational conversion
    // We use an integer variable to compute the unbiased exponent (i.e., exponent - bias)
    integer exp_int;
    reg [63:0] result;

    always @(*) begin
        // Default result is zero
        result = 64'd0;
        // Handle negative numbers, denormal numbers, and special cases (Inf/NaN)
        if (sign == 1'b1 || exponent == 11'd0 || exponent == 11'h7FF) begin
            result = 64'd0;
        end else begin
            // Compute unbiased exponent
            exp_int = exponent - BIAS;
            // If the unbiased exponent is negative, the absolute value is less than 1
            if (exp_int < 0)
                result = 64'd0;
            // If the value is too large to fit into 64 bits, saturate the result
            else if (exp_int > 63)
                result = 64'hFFFFFFFFFFFFFFFF;
            else begin
                // For conversion, shift the normalized mantissa appropriately.
                // When exp_int is less than 52, we perform a right shift.
                if (exp_int < 52)
                    result = mantissa >> (52 - exp_int);
                // When exp_int is 52 or greater, a left shift is needed.
                else
                    result = mantissa << (exp_int - 52);
            end
        end
        // Drive the output
        lu = result;
    end

endmodule

