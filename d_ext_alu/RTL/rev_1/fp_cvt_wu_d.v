module fp_cvt_wu_d (
    input [63:0] d,       // Double-precision input
    output reg [31:0] wu  // 32-bit unsigned integer output
);

    // Extract IEEE 754 fields
    wire        sign;
    wire [10:0] exp;
    wire [51:0] mantissa;
    wire is_nan_or_inf;
    wire is_zero;
    
    // Verilog-compatible declarations
    reg [52:0] significand;
    reg [10:0] e;
    reg [31:0] shifted_val;
    integer shift_amt;

    assign sign = d[63];
    assign exp = d[62:52];
    assign mantissa = d[51:0];
    assign is_nan_or_inf = (exp == 11'h7FF);
    assign is_zero = (exp == 0) && (mantissa == 0);

    always @(*) begin
        if (sign) begin
            wu = 32'b0;
        end else if (is_nan_or_inf) begin
            wu = 32'hFFFFFFFF;
        end else if (is_zero) begin
            wu = 32'b0;
        end else begin
            // Verilog-compatible exponent calculation
            e = exp - 11'd1023;
            significand = {1'b1, mantissa};

            if ($signed(e) < 0) begin
                wu = 32'b0;
            end else if (e >= 11'd32) begin
                wu = 32'hFFFFFFFF;
            end else begin
                shift_amt = 11'd52 - e;
                shifted_val = significand >> shift_amt;
                wu = shifted_val[31:0];
            end
        end
    end

endmodule

