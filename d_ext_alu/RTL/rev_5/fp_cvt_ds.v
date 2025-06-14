module fp_cvt_ds(
    input [63:0] d,         // Double-precision input
    output reg [31:0] s     // Single-precision output
);

    // Extract double-precision fields
    wire sign = d[63];
    wire [10:0] exp_d = d[62:52];
    wire [51:0] frac_d = d[51:0];
    
    // Intermediate signals
    reg [7:0] exp_s;
    reg [22:0] frac_s;
    reg [24:0] round_frac; // Extra bits for rounding
    reg guard, round_bit, sticky;
    
    always @(*) begin
        if (exp_d == 11'h7FF) begin
            // Handle NaN and Infinity cases
            if (frac_d != 0)
                s = {sign, 8'hFF, 23'h400000}; // Canonical NaN
            else
                s = {sign, 8'hFF, 23'b0};      // Infinity
        end else if (exp_d < 11'd896) begin
            // Too small for single precision - output zero
            s = {sign, 8'b0, 23'b0};
        end else if (exp_d > 11'd1150) begin
            // Too large for single precision - output infinity
            s = {sign, 8'hFF, 23'b0};
        end else begin
            // Normal case with proper rounding
            if (exp_d < 11'd1023) begin
                // Subnormal in single precision
                round_frac = {1'b0, frac_d[51:29]};
                round_frac = round_frac >> (1023 - exp_d);
                exp_s = 0;
            end else begin
                // Normal in single precision
                round_frac = {1'b1, frac_d[51:29]};
                exp_s = exp_d - 11'd896; // 1023 - 127
            end
            
            // Rounding bits
            guard = frac_d[28];
            round_bit = frac_d[27];
            sticky = |frac_d[26:0]; // OR reduction of remaining bits
            
            // Round to nearest even
            if (guard && (round_bit || sticky || round_frac[0])) begin
                round_frac = round_frac + 1;
                // Check for overflow after rounding
                if (round_frac[24]) begin
                    round_frac = round_frac >> 1;
                    exp_s = exp_s + 1;
                end
            end
            
            // Check for overflow in exponent
            if (exp_s >= 255) begin
                s = {sign, 8'hFF, 23'b0}; // Infinity
            end else begin
                frac_s = round_frac[22:0];
                s = {sign, exp_s, frac_s};
            end
        end
    end

endmodule
