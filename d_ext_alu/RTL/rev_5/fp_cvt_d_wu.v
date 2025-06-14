/*module fp_cvt_d_wu(
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

*/



module fp_cvt_d_wu(
    input  [31:0] wu,
    output [63:0] d
);

    // IEEE 754 double-precision parameters
    parameter NEXP = 11;
    parameter NSIG = 52;
    
    reg         sign;
    reg [NEXP-1:0] exp;
    reg [NSIG-1:0] sig;
    reg [63:0] sig_temp;
    
    integer i, shift_count;
    
    // We'll extract extra bits for rounding: guard, round, and sticky.
    // In our case, we extract 3 bits: G, R, and S.
    reg [2:0] extra;
    reg sticky;
    
    always @(*) begin
        // For an unsigned integer, sign is 0.
        sign = 1'b0;
        
        if (wu == 32'd0) begin
            // Zero case.
            exp = {NEXP{1'b0}};
            sig = {NSIG{1'b0}};
        end else begin
            // Left-align the 32-bit input into a 64-bit register.
            sig_temp = {wu, 32'b0};
            shift_count = 0;
            
            // Normalize: shift left until bit 63 becomes 1.
            // (We can do this by a loop or fixed shifts; here we use fixed shifts.)
            if (sig_temp[63:48] == 16'b0) begin
                sig_temp = sig_temp << 16;
                shift_count = shift_count + 16;
            end
            if (sig_temp[63:56] == 8'b0) begin
                sig_temp = sig_temp << 8;
                shift_count = shift_count + 8;
            end
            if (sig_temp[63:60] == 4'b0) begin
                sig_temp = sig_temp << 4;
                shift_count = shift_count + 4;
            end
            if (sig_temp[63:62] == 2'b0) begin
                sig_temp = sig_temp << 2;
                shift_count = shift_count + 2;
            end
            if (sig_temp[63] == 1'b0) begin
                sig_temp = sig_temp << 1;
                shift_count = shift_count + 1;
            end
            
            // The highest set bit in the original 32-bit number was at position:
            // (31 - shift_count)
            // Thus the unbiased exponent is (31 - shift_count)
            exp = (31 - shift_count) + 1023;
            
            // After normalization, bit 63 is the implicit '1'. We need the next 52 bits for the fraction.
            // To round properly, we also take 3 extra bits:
            //    - Bit 10: Guard (G)
            //    - Bit 9:  Round (R)
            //    - Bits [8:0]: Sticky (S) = OR of all bits below bit 9.
            //
            // Here, our normalized sig_temp is 64 bits. The fraction field comes from bits [62:11].
            // We'll then take:
            //    extra[2] = sig_temp[10]   (Guard)
            //    extra[1] = sig_temp[9]    (Round)
            //    extra[0] = |sig_temp[8:0] (Sticky: OR of bits 8 down to 0)
            
            sig = sig_temp[62:11];  // 52-bit fraction field.
            extra[2] = sig_temp[10];
            extra[1] = sig_temp[9];
            extra[0] = |sig_temp[8:0];
            
            // Rounding: round-to-nearest, ties to even.
            // Form the 4-bit value: {extra, 0} essentially represents the bits beyond the 52 bits.
            // We round up if:
            //   (guard==1 and (round or sticky or LSB of sig==1))
            if ( (extra[2] && (extra[1] || extra[0] || sig[0])) ) begin
                sig = sig + 1;
                // If this rounding produces an overflow of the significand (i.e. all bits become zero),
                // then we must increment the exponent and reset the significand.
                if (sig == {NSIG{1'b0}}) begin
                    exp = exp + 1;
                end
            end
        end
    end

    // Pack sign, exponent, and significand into the final 64-bit word.
    assign d = {sign, exp, sig};

endmodule

