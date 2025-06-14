module fp_class_d (
    input [63:0] d,
    output reg [63:0] flags
);

// IEEE 754 decomposition
wire        sign = d[63];
wire [10:0] exp  = d[62:52];
wire [51:0] mant = d[51:0];

// Special value detection
wire is_zero     = (exp == 11'd0) && (mant == 52'd0);
wire is_subnorm  = (exp == 11'd0) && (mant != 52'd0);
wire is_normal   = (exp != 11'h7FF) && (exp != 11'd0);
wire is_infinite = (exp == 11'h7FF) && (mant == 52'd0);
wire is_nan      = (exp == 11'h7FF) && (mant != 52'd0);
wire is_snan     = is_nan && (mant[51] == 1'b0);  // Signaling NaN
wire is_qnan     = is_nan && (mant[51] == 1'b1);  // Quiet NaN

always @* begin
    flags = 64'd0;
    
    // Negative Classifications
    if (sign) begin
        if (is_infinite)        flags[0] = 1'b1;  // -8
        else if (is_normal)      flags[1] = 1'b1;  // -normal
        else if (is_subnorm)     flags[2] = 1'b1;  // -subnormal
        else if (is_zero)        flags[3] = 1'b1;  // -0
    end
    // Positive Classifications
    else begin
        if (is_zero)            flags[4] = 1'b1;  // +0
        else if (is_subnorm)     flags[5] = 1'b1;  // +subnormal
        else if (is_normal)      flags[6] = 1'b1;  // +normal
        else if (is_infinite)    flags[7] = 1'b1;  // +8
    end
    
    // NaN Classifications (sign irrelevant)
    if (is_snan)                 flags[8] = 1'b1;  // Signaling NaN
    else if (is_qnan)             flags[9] = 1'b1;  // Quiet NaN
end

endmodule
