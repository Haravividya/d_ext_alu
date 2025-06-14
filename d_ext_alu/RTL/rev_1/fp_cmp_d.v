module fp_cmp_d (
    input [63:0] a,
    input [63:0] b,
    input [1:0] op,
    output reg result
);

// IEEE 754 decomposition
wire a_sign;
wire [10:0] a_exp;
wire [51:0] a_mant;
wire a_zero;
wire a_is_nan;

wire b_sign;
wire [10:0] b_exp;
wire [51:0] b_mant;
wire b_zero;
wire b_is_nan;

// Special case handling
wire either_nan;

// Magnitude comparison components
wire [62:0] a_abs;
wire [62:0] b_abs;

// Comparison logic wires
wire eq;
wire lt_sign;
wire same_sign;
wire lt_mag_pos;
wire lt_mag_neg;
wire lt;
wire le;

assign a_sign = a[63];
assign a_exp = a[62:52];
assign a_mant = a[51:0];
assign a_zero = (a_exp == 11'd0) && (a_mant == 52'd0);
assign a_is_nan = (a_exp == 11'h7FF) && (a_mant != 52'd0);

assign b_sign = b[63];
assign b_exp = b[62:52];
assign b_mant = b[51:0];
assign b_zero = (b_exp == 11'd0) && (b_mant == 52'd0);
assign b_is_nan = (b_exp == 11'h7FF) && (b_mant != 52'd0);

assign either_nan = a_is_nan | b_is_nan;

assign a_abs = {a_exp, a_mant};
assign b_abs = {b_exp, b_mant};

assign eq = (a == b) | (a_zero & b_zero);
assign lt_sign = a_sign & ~b_sign;
assign same_sign = (a_sign == b_sign);
assign lt_mag_pos = (a_abs < b_abs);
assign lt_mag_neg = (a_abs > b_abs);
assign lt = (a_sign != b_sign) ? lt_sign :
            same_sign & ~a_sign ? lt_mag_pos :
            same_sign &  a_sign ? lt_mag_neg :
            1'b0;
assign le = eq | lt;

always @* begin
    if (either_nan) begin
        result = 1'b0;
    end else begin
        case(op)
            2'b10: result = eq;
            2'b11: result = lt;
            2'b00: result = le;
            default: result = 1'b0;
        endcase
    end
end

endmodule
