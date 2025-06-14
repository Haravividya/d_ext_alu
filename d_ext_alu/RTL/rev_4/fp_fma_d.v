
/*module fp_fma_d (
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


module fp_fma_d (
    input  [63:0] a,
    input  [63:0] b,
    input  [63:0] c,
    input  [1:0]  op,    // op encoding: 
                         // 00: FMADD (rs1*rs2 + rs3)
                         // 01: FMSUB (rs1*rs2 - rs3)
                         // 10: FNMADD (-(rs1*rs2) - rs3)
                         // 11: FNMSUB (-(rs1*rs2) + rs3)
    output [63:0] result
);

    wire [63:0] product;
    reg  [63:0] product_neg;
    reg  [63:0] addsub_a;
    reg  [63:0] addsub_b;
    wire        addsub_op; // 0: addition, 1: subtraction

    // Instantiate existing multiplier
    fp_mul_d u_mul (
        .a(a),
        .b(b),
        .result(product)
    );

    // Instantiate existing add/sub unit
    fp_addsub_d u_addsub (
        .a(addsub_a),
        .b(addsub_b),
        .op(addsub_op),        // Use corrected control signal
        .result(result)
    );

    // Combinational control logic
    always @* begin
        // Negate product's sign bit (flip sign bit only)
        product_neg = {~product[63], product[62:0]};
        
        // Select product or negated product:
        // For FNMADD (op == 2'b10) or FNMSUB (op == 2'b11) use negated product,
        // otherwise use the direct product.
        addsub_a = op[1] ? product_neg : product;
        
        // Direct connection for third operand
        addsub_b = c;
    end

    // Derive add/sub control:
    // For FMADD (00): op[0] is used (should be addition ¿ 0)
    // For FMSUB (01): op[0] is used (should be subtraction ¿ 1)
    // For FNMADD (10): we need subtraction regardless ¿ force 1
    // For FNMSUB (11): we need addition regardless ¿ force 0
    assign addsub_op = (op == 2'b10) ? 1'b1 :
                       (op == 2'b11) ? 1'b0 :
                       op[0];

endmodule
*/

module fp_fma_d (
    input [63:0] a,           // First operand
    input [63:0] b,           // Second operand
    input [63:0] c,           // Third operand
    input [1:0] op,           // Operation selector
                              // 00 -> FMADD: (a × b) + c
                              // 01 -> FMSUB: (a × b) - c
                              // 10 -> FNMADD: -(a × b) - c
                              // 11 -> FNMSUB: -(a × b) + c
    output [63:0] result      // Final result
);

    wire [63:0] product;      // Result of multiplication (a × b)
    wire [63:0] neg_product;  // Negated product (-product)
    wire [63:0] neg_c;        // Negated third operand (-c)
    
    reg [63:0] effective_a;   // First input to adder/subtractor
    reg [63:0] effective_b;   // Second input to adder/subtractor

    fp_mul_d multiplier (
        .a(a),
        .b(b),
        .result(product)
    );

    assign neg_product = {~product[63], product[62:0]};
    assign neg_c = {~c[63], c[62:0]};

    always @(*) begin
        case (op)
            2'b00: begin  // FMADD : (a × b) + c
                effective_a = product;
                effective_b = c;
            end
            2'b01: begin  // FMSUB : (a × b) - c
                effective_a = product;
                effective_b = neg_c;
            end
            2'b10: begin  // FNMADD : -(a × b) - c
                effective_a = neg_product;
                effective_b = neg_c;
            end
            2'b11: begin  // FNMSUB : -(a × b) + c
                effective_a = neg_product;
                effective_b = c;
            end
        endcase
    end

    fp_addsub_d adder (
        .a(effective_a),
        .b(effective_b),
        .op(1'b0),       // Always add after sign adjustments
        .result(result)
    );

endmodule


