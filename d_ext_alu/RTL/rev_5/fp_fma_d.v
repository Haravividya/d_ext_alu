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


