/* module fp_cvt_d_w(
    input  [31:0] w,    // 32-bit signed integer input
    output [63:0] d     // 64-bit double output (IEEE 754)
);

    // Internal signals
    wire [31:0] abs_w;
    reg [4:0] lz;
    reg [4:0] msb_index;
    reg [10:0] exponent;
    reg [63:0] shifted;
    reg [63:0] result;

    // Compute the absolute value of w
    assign abs_w = (w[31]) ? (~w + 1) : w;

    // Function to count leading zeros (implemented as a task in pure Verilog)
    task count_leading_zeros;
        input [31:0] in;
        output [4:0] count;
        integer i;
    begin
        count = 5'd0;
        for (i = 31; i >= 0; i = i - 1) begin
            if (in[i]) begin
                count = 31 - i;
                i = -1; // Break out of the loop
            end
        end
    end
    endtask

    // Combinational logic for conversion
    always @(*) begin
        if (abs_w == 32'b0) begin
            result = 64'b0;
        end else begin
            count_leading_zeros(abs_w, lz);
            msb_index = 5'd31 - lz;
            exponent = msb_index + 11'd1023;
            
            shifted = abs_w;
            shifted = shifted << (52 - msb_index);
            
            result = {w[31], exponent, shifted[51:0]};
        end
    end

    // Output assignment
    assign d = result;

endmodule
*/

module fp_cvt_d_w(
    input  [31:0] w,    // 32-bit signed integer input
    output [63:0] d     // 64-bit double output (IEEE 754)
);

    // Internal signals
    wire        sign;
    wire [31:0] abs_w;
    reg  [5:0]  lz;
    reg  [5:0]  msb_index;
    reg  [10:0] exponent;
    reg  [51:0] mantissa;
    reg  [63:0] result;
    integer     i;  // loop index for counting lz

    // Additional signals for rounding (used if msb_index > 51)
    reg [5:0]  shift_amt;  // amount to shift right
    reg [63:0] extended;
    reg        guard, round_bit, sticky;
    reg [51:0] prelim;
    integer    j;        // loop index for sticky calculation

    // Extract sign bit
    assign sign = w[31];
    
    // Compute absolute value (two's complement if negative)
    assign abs_w = (sign) ? (~w + 32'h1) : w;

    // Count leading zeros in abs_w
    always @(*) begin
        lz = 6'd0;
        for (i = 31; i >= 0; i = i - 1) begin
            if (abs_w[i] == 1'b0)
                lz = lz + 6'd1;
            else
                i = -1; // exit loop early
        end
        // Special case: if abs_w is zero
        if (abs_w == 32'b0)
            lz = 6'd32;
    end

    // Combinational logic for conversion
    always @(*) begin
        msb_index = 6'd0;
        exponent  = 11'd0;
        mantissa  = 52'd0;
        result    = 64'd0;
        
        if (abs_w == 32'b0) begin
            // Zero: output sign bit and all zeros
            result = {sign, 63'b0};
        end else begin
            // Determine the position of the most-significant 1:
            msb_index = 6'd31 - lz;
            
            // Compute biased exponent: (unbiased exponent + bias)
            exponent = msb_index + 11'd1023;
            
            // Form the 52-bit fraction field.
            // We want to represent the number as: 1.M x 2^(msb_index)
            // with the "1." implicit.
            if (msb_index <= 6'd51) begin
                // For numbers small enough: shift left.
                // Extend abs_w to 52 bits by concatenating zeros.
                mantissa = {abs_w, 20'b0} << (6'd51 - msb_index);
                // Clear the implicit bit (bit 51)
                mantissa = mantissa & ~(52'h1 << 51);
            end else begin
                // For numbers needing right-shift.
                shift_amt = msb_index - 6'd51;
                // Extend abs_w to 64 bits by appending 32 zeros.
                extended = {abs_w, 32'b0};
                prelim = extended >> shift_amt;
                
                // Compute guard bit: the bit immediately below the LSB of prelim.
                guard = extended[shift_amt - 1];
                // Compute round_bit (if shift_amt > 1)
                if (shift_amt > 1)
                    round_bit = extended[shift_amt - 2];
                else
                    round_bit = 1'b0;
                // Compute sticky bit by ORing all bits from 0 to shift_amt-3.
                sticky = 1'b0;
                if (shift_amt > 2) begin
                    for (j = 0; j < shift_amt - 2; j = j + 1) begin
                        if (extended[j] == 1'b1)
                            sticky = 1'b1;
                    end
                end else begin
                    sticky = 1'b0;
                end

                // Implement Round-To-Nearest, ties-to-even:
                // If guard is 1 and (round_bit OR sticky OR LSB of prelim is 1), round up.
                if (guard && (round_bit || sticky || prelim[0]))
                    prelim = prelim + 1;
                
                // Remove the implicit bit.
                mantissa = prelim & ~(52'h1 << 51);
            end
            
            // Assemble the final IEEE 754 double:
            result = {sign, exponent, mantissa};
        end
    end

    // Output assignment
    assign d = result;

endmodule

