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
    wire [31:0] abs_w;
    reg [4:0] lz;
    reg [4:0] msb_index;
    reg [10:0] exponent;
    reg [51:0] mantissa;
    reg [63:0] result;

    // Compute absolute value
    assign abs_w = (w[31]) ? (~w + 1) : w;

    // Function to count leading zeros
    function [4:0] count_leading_zeros(input [31:0] in);
        integer i;
        begin
            count_leading_zeros = 5'd31;  // Default to max leading zeros
            for (i = 31; i >= 0; i = i - 1) begin
                if (in[i]) begin
                    count_leading_zeros = 31 - i;
                    i = -1;  // Break loop
                end
            end
        end
    endfunction

    // Combinational logic for conversion
    always @(*) begin
        if (abs_w == 32'b0) begin
            result = 64'b0;  // Handle zero separately
        end else begin
            lz = count_leading_zeros(abs_w);
            msb_index = 5'd31 - lz;
            exponent = msb_index + 11'd1023;

            // Normalize mantissa by shifting
            if (msb_index > 23) begin
                mantissa = abs_w >> (msb_index - 23);
            end else begin
                mantissa = abs_w << (23 - msb_index);
            end

            // Remove implicit leading 1 and fit into 52 bits
            mantissa = mantissa[22:0] << 29;

            // IEEE 754 Double-Precision Format: Sign | Exponent | Mantissa
            result = {1'b0, exponent, mantissa};
        end
    end

    // Output assignment
    assign d = result;

endmodule

