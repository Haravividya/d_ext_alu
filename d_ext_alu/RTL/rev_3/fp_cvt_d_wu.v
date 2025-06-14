module fp_cvt_d_wu(
    input [31:0] wu,
    output [63:0] d
);

    // IEEE 754 double precision parameters
    parameter NEXP = 11;
    parameter NSIG = 52;
    
    reg sign;
    reg [NEXP-1:0] exp;
    reg [NSIG-1:0] sig;
    reg [63:0] sig_temp;
    
    integer i, leading_zeros;
    
    always @(*) begin
        // For unsigned integer, sign is always 0
        sign = 1'b0;
        
        if (wu == 32'd0) begin
            // Special case: input is zero
            exp = {NEXP{1'b0}};
            sig = {NSIG{1'b0}};
        end else begin
            // Find position of most significant '1' bit
            leading_zeros = 0;
            sig_temp = {wu, 32'b0}; // Left-align the input in a 64-bit register
            
            // Normalize: find leading 1 and shift accordingly
            if (sig_temp[63:48] == 16'b0) begin
                sig_temp = sig_temp << 16;
                leading_zeros = leading_zeros + 16;
            end
            if (sig_temp[63:56] == 8'b0) begin
                sig_temp = sig_temp << 8;
                leading_zeros = leading_zeros + 8;
            end
            if (sig_temp[63:60] == 4'b0) begin
                sig_temp = sig_temp << 4;
                leading_zeros = leading_zeros + 4;
            end
            if (sig_temp[63:62] == 2'b0) begin
                sig_temp = sig_temp << 2;
                leading_zeros = leading_zeros + 2;
            end
            if (sig_temp[63] == 1'b0) begin
                sig_temp = sig_temp << 1;
                leading_zeros = leading_zeros + 1;
            end
            
            // Calculate exponent (bias = 1023 for double precision)
            // 31 - leading_zeros is the bit position of the most significant '1'
            exp = (31 - leading_zeros) + 1023;
            
            // Extract significand (excluding implied '1' bit)
            sig = sig_temp[62:11];
        end
    end
    
    // Combine sign, exponent, and significand to form IEEE 754 double
    assign d = {sign, exp, sig};

endmodule


