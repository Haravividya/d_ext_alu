module fp_signinj_d(
    input  [63:0] a,   // First double-precision operand (sign, exponent, mantissa)
    input  [63:0] b,   // Second double-precision operand (from which sign is extracted)
    input  [1:0]  op,  // Operation select:
                       //  2'b00: FSGNJ.D -> copy sign from b to a
                       //  2'b01: FSGNJN.D -> copy inverted sign from b to a
                       //  2'b10: FSGNJX.D -> result sign is a[63] XOR b[63]
    output reg [63:0] result  // Resulting double: same exponent and mantissa as a; sign modified per op
);

    // Combinational logic to perform sign injection
    always @(*) begin
        case(op)
            2'b00: result = { b[63], a[62:0] };    // FSGNJ.D: Use sign from b
            2'b01: result = { ~b[63], a[62:0] };   // FSGNJN.D: Use inverted sign from b
            2'b10: result = { a[63] ^ b[63], a[62:0] };  // FSGNJX.D: XOR of a and b sign bits
            default: result = { b[63], a[62:0] };   // Default behavior: same as FSGNJ.D
        endcase
    end

endmodule
