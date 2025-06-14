module fp_sqrt_d (
    input  [63:0] a,       // Input operand (IEEE-754 double)
    output [63:0] result   // Square root result
);

// IEEE-754 decomposition
wire        sign     = 1'b0;        // Square root of negative numbers invalid
wire [10:0] exponent = a[62:52];
wire [51:0] mantissa = a[51:0];

// Exponent processing
wire [11:0] exp_unbiased = exponent - 1023;  // Remove bias
wire        exp_odd      = exp_unbiased[0];
wire [10:0] exp_new      = (exp_unbiased >> 1) + 1023; // New exponent

// Mantissa processing
wire [53:0] mant_adjusted = {1'b1, mantissa, exp_odd}; // 54-bit (1.xx + exp_odd)

// Non-restoring square root algorithm
reg  [55:0] x;  // Fixed-point representation (54 bits + fractional)
reg  [55:0] q;   // Result accumulator
reg  [55:0] r;   // Remainder

integer i;

always @(*) begin
    x = {mant_adjusted, 54'b0}; // Assign dynamically in procedural block
    q = 0;
    r = 0;
    
    // Perform non-restoring square root algorithm for 54 iterations
    for (i = 0; i < 54; i = i + 1) begin
        if ($signed(r) >= 0) begin
            r = (r << 2) | (x[55:54]); // Shift remainder and bring down bits from x
            r = r - ((q << 2) | 1);    // Subtract trial divisor
        end else begin
            r = (r << 2) | (x[55:54]); // Shift remainder and bring down bits from x
            r = r + ((q << 2) | 3);    // Add trial divisor if remainder is negative
        end
        
        q = (q << 1) | (~r[55]);       // Update quotient with new bit from remainder
        x = x << 2;                    // Shift x to bring down next two bits
    end
end

// Assemble result (truncate without rounding)
wire [51:0] sqrt_mant = q[53:2]; // Discard LSBs beyond precision
assign result = {sign, exp_new, sqrt_mant};

endmodule

