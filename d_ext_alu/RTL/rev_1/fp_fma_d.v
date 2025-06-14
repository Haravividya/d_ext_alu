
module fp_fma_d (
    input [63:0] a,
    input [63:0] b,
    input [63:0] c,
    input [1:0] op,
    output [63:0] result
);

wire [63:0] product;
reg [63:0] product_neg;
reg [63:0] addsub_a;
reg [63:0] addsub_b;

// Instantiate existing multiplier
fp_mul_d u_mul (
    .a(a),
    .b(b),
           // Rounding mode bypass
    .result(product)
);

// Instantiate existing add/sub unit
fp_addsub_d u_addsub (
    .a(addsub_a),
    .b(addsub_b),
    .op(op[0]),        // Add/sub control
           // Rounding mode bypass
    .result(result)
);

// Combinational control logic
always @* begin
    // Negate product's sign bit
    product_neg = {~product[63], product[62:0]};
    
    // Select product or negated product
    addsub_a = op[1] ? product_neg : product;
    
    // Direct connection for third operand
    addsub_b = c;
end

endmodule

