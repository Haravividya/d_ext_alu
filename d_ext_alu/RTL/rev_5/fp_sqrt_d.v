/*module fp_sqrt_d (a, result);
  input  [63:0] a;
  output reg [63:0] result;
  integer i, j;
  
  // Module level register declarations
  reg [51:0] a_mantissa;
  reg [10:0] a_exponent;
  reg        a_sign;
  reg [51:0] result_mantissa;
  reg [10:0] result_exponent;
  reg        result_sign;
  reg [54:0] ix;
  
  // Working registers for the algorithm
  reg [109:0] a_acc;
  reg [109:0] r;
  reg [110:0] rt;
  reg [54:0]  biti;
  reg [11:0]  unbiased_exp;
  
  // Additional registers needed for bit2bit_sq functionality
  reg [109:0] bit2bit_value;
  reg [54:0] bit2bit_input;

  always @(a) begin
    a_mantissa = a[51:0];
    a_exponent = a[62:52];
    a_sign     = a[63];
    result_sign = 1'b0;

    // Special cases handling
    if(a_exponent == 11'b0 && a_mantissa == 52'b0) begin
      // Zero input
      result_sign = a_sign;
      result_exponent = 11'b0;
      result_mantissa = 52'b0;
    end
    else if(a_exponent == 11'b11111111111) begin
      // NaN or infinity
      if (a_mantissa != 52'b0 || a_sign) begin
        result_sign = 1'b0;
        result_exponent = 11'b11111111111;
        result_mantissa = {1'b1, 51'b0}; // Canonical NaN
      end
      else begin
        result_sign = 1'b0;
        result_exponent = 11'b11111111111;
        result_mantissa = 52'b0; // Infinity
      end
    end
    else if(a_sign) begin
      // Negative input
      result_sign = 1'b0;
      result_exponent = 11'b11111111111;
      result_mantissa = {1'b1, 51'b0}; // NaN
    end
    else begin
      // Normal positive number
      
      // Calculate unbiased exponent
      unbiased_exp = a_exponent - 11'd1023;
      
      // Calculate result exponent - careful with the division
      result_exponent = (unbiased_exp >> 1) + 11'd1023;
      
      // Prepare significand differently based on exponent parity
      if(unbiased_exp[0]) begin
        // Odd exponent - effectively multiply by 2
        ix = {1'b1, a_mantissa, 2'b0};
      end
      else begin
        // Even exponent
        ix = {2'b01, a_mantissa, 1'b0};
      end
      
      // Initialize algorithm
      a_acc = 110'b0;
      biti = {1'b1, 54'b0};
      r = {ix, 55'b0};
      
      // Square root digit recurrence algorithm
      for(i = 54; i >= 0; i = i - 1) begin
        // Calculate bit2bit_sq inline instead of using a function
        bit2bit_value = 0;
        bit2bit_input = biti;
        for(j = 54; j >= 0; j = j - 1) begin
          bit2bit_value[2*j] = bit2bit_input[j];
          bit2bit_value[2*j+1] = 1'b0;
        end
        
        // Compute trial remainder
        rt = {r[109:0], 1'b0} - {a_acc, 3'b01} - bit2bit_value;
        
        if(rt[110] == 1'b0) begin
          // Remainder is non-negative, bit is 1
          r = rt[109:0];
          a_acc = {a_acc[108:0], 1'b1};
        end
        else begin
          // Remainder is negative, bit is 0
          r = {r[109:0], 1'b0};
          a_acc = {a_acc[108:0], 1'b0};
        end
        
        biti = {biti[53:0], 1'b0};
      end
      
      // Extract result mantissa (no implicit bit)
      result_mantissa = a_acc[51:0];
    end
    
    // Assemble final result
    result = {result_sign, result_exponent, result_mantissa};
  end
endmodule

*/

// fp_sqrt_newton.v
// 64-bit IEEE-754 double-precision square root using Newton-Raphson method

module fp_sqrt_d(
    input  [63:0] a,       // 64-bit IEEE-754 input
    output reg [63:0] result  // 64-bit IEEE-754 result (square root)
);

  //---------------------------------------------------------------------
  // Parameter and Register Declarations
  //---------------------------------------------------------------------
  parameter ITERATIONS = 3; // Number of Newton-Raphson iterations

  reg [51:0] a_mantissa;    // Mantissa of input
  reg [10:0] a_exponent;    // Exponent of input
  reg        a_sign;        // Sign of input

  reg [51:0] result_mantissa; // Mantissa of result
  reg [10:0] result_exponent; // Exponent of result
  reg        result_sign;     // Sign of result

  reg [63:0] x;              // Current approximation of reciprocal sqrt
  reg [63:0] val;            // Normalized input value for iterations
  reg [63:0] temp;           // Temporary variable for intermediate results

  integer i;

  //---------------------------------------------------------------------
  // Main Processing Block
  //---------------------------------------------------------------------
  always @(a) begin
    //-----------------------------------------------------------------
    // Extract fields from input
    //-----------------------------------------------------------------
    a_mantissa = a[51:0];
    a_exponent = a[62:52];
    a_sign     = a[63];

    //-----------------------------------------------------------------
    // Special Case Handling
    //-----------------------------------------------------------------
    if (a_exponent == 11'd0 && a_mantissa == 52'd0) begin
      result = a; // Zero input, return zero.
    end else if (a_exponent == 11'b11111111111) begin
      result_sign     = 1'b0;
      result_exponent = a_exponent;
      result_mantissa = (a_mantissa != 52'd0) ? 52'd1 : 52'd0;
      result = {result_sign, result_exponent, result_mantissa};
    end else if (a_sign == 1'b1) begin
      result_sign     = 1'b0;
      result_exponent = 11'b11111111111;
      result_mantissa = 52'd1;
      result = {result_sign, result_exponent, result_mantissa}; // NaN for negative inputs.
    end else begin
      //-----------------------------------------------------------------
      // Normalize Input for Iterations
      //-----------------------------------------------------------------
      
      // Adjust exponent to make the mantissa normalized between [1,4)
      if (a_exponent[0]) begin
        val = {1'b1, a_mantissa};   // Odd exponent normalization.
        a_exponent = a_exponent - 1;
      end else begin
        val = {2'b01, a_mantissa}; // Even exponent normalization.
      end

      //-----------------------------------------------------------------
      // Initial Guess for Reciprocal Square Root (x_0)
      //-----------------------------------------------------------------
      x = {11'b01111111111, {52{1'b0}}}; // Initial guess: x_0 ˜ 1.0

      //-----------------------------------------------------------------
      // Newton-Raphson Iterations to Refine Approximation
      //-----------------------------------------------------------------
      for (i = 0; i < ITERATIONS; i = i + 1) begin
        temp = val * x >> 52;               // Compute val * x_n (scale down)
        temp = temp * x >> 52;             // Compute (val * x_n) * x_n
        temp = (64'h3FF0000000000000 - temp) >> 1; // Compute (1.5 - ...)
        x = x * temp >> 52;                // Update x_{n+1} = x_n * (...)
      end

      //-----------------------------------------------------------------
      // Compute Final Square Root from Reciprocal Square Root
      //-----------------------------------------------------------------
      temp = val * x >> 52;                // Compute sqrt(val) ˜ val * (1/sqrt(val))

      //-----------------------------------------------------------------
      // Adjust Exponent and Assemble Result
      //-----------------------------------------------------------------
      
      if (a_exponent[10]) begin            // If exponent was odd initially...
        result_exponent = (a_exponent >> 1) + 1023;
        temp = temp >> 1;                  // Adjust mantissa for odd exponent.
      end else begin                       // If exponent was even initially...
        result_exponent = (a_exponent >> 1) + 1023;
      end

      result_sign     = 1'b0;
      result_mantissa = temp[51:0];        // Extract final mantissa.
      
      result          = {result_sign, result_exponent, result_mantissa};
    end
  end

endmodule



