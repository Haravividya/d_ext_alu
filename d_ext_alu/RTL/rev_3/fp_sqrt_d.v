module fp_sqrt_d (
    a,
    result
);
    input [63:0] a;
    output reg [63:0] result;

    reg sign_in;
    reg [10:0] exp_in;
    reg [51:0] frac_in;
    reg [10:0] exp_out;
    reg [51:0] sqrt_mantissa;
    reg [52:0] remainder, divisor;
    integer i, norm_shift;

    always @(*) begin
        sign_in = a[63];
        exp_in  = a[62:52];
        frac_in = a[51:0];

        if (exp_in == 11'h7FF) begin
            if (frac_in == 0) begin
                result = a;
            end else begin
                result = {1'b0, 11'h7FF, frac_in | (1'b1 << 51)};
            end
        end else if (sign_in == 1'b1 && (exp_in != 0 || frac_in != 0)) begin
            result = {1'b0, 11'h7FF, 1'b1, 51'b0};
        end else if (a == 64'b0) begin
            result = 64'b0;
        end else begin
            if (exp_in == 0) begin
                norm_shift = 0;
                frac_in = {frac_in, 1'b0};
                while (frac_in[51] == 0) begin
                    frac_in = frac_in << 1;
                    norm_shift = norm_shift + 1;
                end
                exp_in = 1023 - norm_shift;
            end

            if (exp_in[0] == 1) begin
                exp_out = ((exp_in - 1023) >> 1) + 1023;
                frac_in = frac_in << 1;
            end else begin
                exp_out = ((exp_in - 1023) >> 1) + 1023;
            end

            sqrt_mantissa = 0;
            remainder = 0;
            divisor = 0;
            
            for (i = 52; i >= 0; i = i - 1) begin
                remainder = (remainder << 2) | (frac_in[51:50]);
                frac_in = frac_in << 2;
                divisor = (sqrt_mantissa << 2) | 1;
                
                if (remainder >= divisor) begin
                    remainder = remainder - divisor;
                    sqrt_mantissa = (sqrt_mantissa << 1) | 1;
                end else begin
                    sqrt_mantissa = (sqrt_mantissa << 1);
                end
            end

            if (remainder != 0) begin
                sqrt_mantissa = sqrt_mantissa + 1;
            end

            result = {1'b0, exp_out, sqrt_mantissa};
        end
    end
endmodule

