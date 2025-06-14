module fp_minmax_d(
    input [63:0] a,     // First operand (IEEE-754 double-precision format)
    input [63:0] b,     // Second operand (IEEE-754 double-precision format)
    input minmax,       // Selector: 0 for min, 1 for max
    output reg [63:0] result // Result of min or max operation
);

    wire sign_a, sign_b;
    wire [10:0] exp_a, exp_b;
    wire [51:0] frac_a, frac_b;
    wire a_is_nan, b_is_nan, a_is_zero, b_is_zero;

    assign sign_a = a[63];
    assign sign_b = b[63];
    assign exp_a = a[62:52];
    assign exp_b = b[62:52];
    assign frac_a = a[51:0];
    assign frac_b = b[51:0];

    assign a_is_nan = (exp_a == 11'h7FF) && (frac_a != 0);
    assign b_is_nan = (exp_b == 11'h7FF) && (frac_b != 0);
    assign a_is_zero = (exp_a == 11'h00) && (frac_a == 52'b00);
    assign b_is_zero = (exp_b == 11'h00) && (frac_b == 52'b00);

    //  logic for a_less_than_b
    wire a_less_than_b =
        (sign_a && !sign_b) || // a is negative, b is positive
        (!sign_a && !sign_b && ((exp_a < exp_b) || ((exp_a == exp_b) && frac_a < frac_b))) || // Both positive, compare normally
        (sign_a && sign_b && ((exp_a > exp_b) || ((exp_a == exp_b) && frac_a > frac_b))); // Both negative, reverse comparison

    always @(*) begin
        if (a_is_nan && b_is_nan) 
            result = 64'h7FF8000000000000; // Canonical NaN
        else if (a_is_nan)
            result = b; // If only a is NaN, return b
        else if (b_is_nan)
            result = a; // If only b is NaN, return a
        else if (a_is_zero && b_is_zero) 
            result = (minmax == 1'b1) ? 64'h0000000000000000 : 64'h8000000000000000; // fmin(-0,+0) -> -0, fmax(-0,+0) -> +0
        else if ((minmax == 1'b0 && a_less_than_b) || (minmax == 1'b1 && !a_less_than_b)) 
            result = a; // Min: if a < b, return a. Max: if a > b, return a.
        else
            result = b;
    end

endmodule

