
module fp_cvt_d_l (
input [63:0] l,
output reg [63:0] d
);

reg sign;
reg [63:0] abs_value;
reg [10:0] exponent;
reg [51:0] mantissa;
integer msb_index;

always @* begin
// Determine sign and absolute value
sign = l[63];
abs_value = sign ? (~l + 1) : l;

// Find most significant '1' bit
msb_index = 63;
while (msb_index >= 0 && !abs_value[msb_index])
msb_index = msb_index - 1;

if (msb_index == -1) begin
// Input is zero
d = 64'b0;
end else begin
// Calculate exponent
exponent = msb_index + 1023;

// Extract mantissa
if (msb_index >= 52)
mantissa = abs_value >> (msb_index - 52);
else
mantissa = abs_value << (52 - msb_index);

// Remove implicit leading '1'
mantissa = mantissa & 52'h000fffffffffffff;

// Assemble IEEE 754 double-precision result
d = {sign, exponent[10:0], mantissa[51:0]};
end
end

endmodule

