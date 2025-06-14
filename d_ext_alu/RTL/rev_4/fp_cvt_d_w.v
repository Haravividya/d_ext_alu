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
    wire sign;
    wire [31:0] abs_w;
    reg [5:0] lz;
    reg [5:0] msb_index;
    reg [10:0] exponent;
    reg [51:0] mantissa;
    reg [63:0] result;
    integer i;  // For loop counter

    // Extract sign bit
    assign sign = w[31];
    
    // Compute absolute value
    assign abs_w = (sign) ? (~w + 32'h1) : w;

    // Count leading zeros in the always block
    always @(*) begin
        lz = 6'd0;
        for (i = 31; i >= 0; i = i - 1) begin
            if (!abs_w[i]) 
                lz = lz + 6'd1;
            else 
                i = -1;  // Exit loop
        end
        
        // Special case for zero
        if (lz == 6'd32)
            lz = 6'd32;
    end

    // Combinational logic for conversion
    always @(*) begin
        // Default values
        msb_index = 6'd0;
        exponent = 11'd0;
        mantissa = 52'd0;
        result = 64'd0;
        
        if (abs_w == 32'b0) begin
            // Handle zero separately
            result = {sign, 63'b0};
        end else begin
            // Find position of MSB
            msb_index = 6'd31 - lz;
            
            // Calculate exponent (bias 1023)
            exponent = msb_index + 11'd1023;
            
            // Prepare mantissa (52 bits)
            if (msb_index <= 6'd51) begin
                // For smaller numbers, shift left
                mantissa = {abs_w, 20'b0} << (51 - msb_index);
                // Remove implicit 1
                mantissa = mantissa & ~(52'h1 << 51);
            end else begin
                // For larger numbers, shift right
                mantissa = abs_w >> (msb_index - 51);
                // Remove implicit 1
                mantissa = mantissa & ~(52'h1 << 51);
            end
            
            // IEEE 754 Double-Precision Format: Sign | Exponent | Mantissa
            result = {sign, exponent, mantissa};
        end
    end

    // Output assignment
    assign d = result;

endmodule

