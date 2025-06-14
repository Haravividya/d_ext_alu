module fp_cvt_dw (
    input  [63:0] d,         // Double-precision input
    input         signed_op, // Signed conversion flag
    output reg [31:0] w      // 32-bit integer output
);

// IEEE 754 Double-Precision Format
wire        sign;
wire [10:0] exp;
wire [51:0] mantissa;
wire        is_zero, is_nan, is_inf;

// Internal registers
reg [52:0]  significand;
reg [11:0]  unbiased_exp;
reg [31:0]  unsigned_val;
integer     shift_amt;

assign sign = d[63];
assign exp = d[62:52];
assign mantissa = d[51:0];

// Special Case Detection
assign is_zero = (exp == 11'd0) && (mantissa == 52'd0);
assign is_nan = (exp == 11'h7FF) && (mantissa != 52'd0);
assign is_inf = (exp == 11'h7FF) && (mantissa == 52'd0);

// Conversion Logic
always @* begin
    casez ({is_nan, is_inf, is_zero})
        3'b1??:  w = signed_op ? 32'h80000000 : 32'd0;  // NaN
        3'b01?:  w = signed_op ? (sign ? 32'h80000000 : 32'h7FFFFFFF) : 
                      (sign ? 32'd0 : 32'hFFFFFFFF);     // Infinity
        3'b001:  w = 32'd0;                              // Zero
        default: begin
            significand = {1'b1, mantissa};
            unbiased_exp = exp - 1023;

            // Value < 1.0 case
            if ($signed(unbiased_exp) < 0) begin
                unsigned_val = 32'd0;
            end
            else begin
                shift_amt = unbiased_exp - 52;
                if (shift_amt >= 32) begin
                    unsigned_val = signed_op ? 32'h7FFFFFFF : 32'hFFFFFFFF;
                end
                else if (shift_amt >= 0) begin
                    unsigned_val = (significand << shift_amt) >> 32;
                end
                else begin
                    unsigned_val = significand >> (-shift_amt);
                end
            end

            // Sign handling
            if (signed_op) begin
                w = sign ? -unsigned_val : unsigned_val;
                if (~sign && unsigned_val > 32'h7FFFFFFF) 
                    w = 32'h7FFFFFFF;
                else if (sign && unsigned_val > 32'h80000000)
                    w = 32'h80000000;
            end
            else begin
                w = sign ? 32'd0 : unsigned_val;
                if (unsigned_val > 32'hFFFFFFFF)
                    w = 32'hFFFFFFFF;
            end
        end
    endcase
end

endmodule

