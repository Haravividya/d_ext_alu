module RISCV_D_ALU(
    input [63:0] rs1, rs2, rs3,
    input [31:0] fs_rs1,
    input [63:0] int_rs1,
    input [4:0] alu_op,
    output reg [63:0] result,
    output reg [31:0] fs_result,
    output reg [63:0] int_result
);

// Functional Units
wire [63:0] fadd_out; // Wire to hold the result of addition/subtraction
wire [63:0] fmul_out; // Wire to hold the result of multiplication
wire [63:0] fdiv_out; // Wire to hold the result of division
wire [63:0] fsqrt_out; // Wire to hold the result of square root
wire [63:0] fma_out;  // Wire to hold the result of fused multiply-add
wire [63:0] fsgnj_out; // Wire to hold the result of sign injection
wire [63:0] fmin_out, fmax_out; // Wires for min and max operations
wire comparision_out; // Wires for comparison operations
wire [63:0] fcvt_sd_out; //Wire for float - float conversion
wire [31:0] fcvt_ds_out; // Wires for float-to-float conversions

wire [63:0] fcvt_d_w_out;  // 32-bit signed integer ? double-precision float
wire [63:0] fcvt_d_wu_out; // 32-bit unsigned integer ? double-precision float
wire [31:0] fcvt_wd_out;   // Double-precision float ? 32-bit signed integer
wire [31:0] fcvt_wu_d_out; // Double-precision float ? 32-bit unsigned integer


// RV64-Specific Conversion Outputs
wire [63:0] fcvt_d_l_out;   // 64-bit signed integer ? double-precision float
wire [63:0] fcvt_d_lu_out;  // 64-bit unsigned integer ? double-precision float
wire [63:0] fcvt_ld_out;    // Double-precision float ? 64-bit signed integer
wire [63:0] fcvt_lu_d_out;  // Double-precision float ? 64-bit unsigned integer

wire [63:0] fclass_out; // Wire for classification result


// FMA Operation Decoder
wire [1:0] fma_op =
    (alu_op == 5'b00101) ? 2'b00 : // FMADD.D: (rs1 * rs2) + rs3
    (alu_op == 5'b00110) ? 2'b01 : // FMSUB.D: (rs1 * rs2) - rs3
    (alu_op == 5'b00111) ? 2'b10 : // FNMADD.D: -(rs1 * rs2) - rs3
    (alu_op == 5'b01000) ? 2'b11 : // FNMSUB.D: -(rs1 * rs2) + rs3
    2'b00;

// Instantiation of addition/subtraction module
fp_addsub_d u_addsub (
    .a(rs1),
    .b(rs2),
    .op(alu_op[0]),
    .result(fadd_out)
);

// Instantiation of multiplication module
fp_mul_d u_mul (
    .a(rs1),
    .b(rs2),
    .result(fmul_out)
);

// Instantiation of division module
fp_div_d u_div (
    .a(rs1),
    .b(rs2),
    .result(fdiv_out)
);

// Instantiation of square root module
fp_sqrt_d u_sqrt (
    .a(rs1),
    .result(fsqrt_out)
);

// Instantiation of fused multiply-add module
fp_fma_d u_fma (
    .a(rs1),
    .b(rs2),
    .c(rs3),
    .op(fma_op),
    .result(fma_out)
);

// Instantiation of sign injection module
fp_signinj_d u_sgnj (
    .a(rs1),
    .b(rs2),
    .op(alu_op[1:0]),
    .result(fsgnj_out)
);

// Instantiation of min/max modules
fp_minmax_d u_min (
    .a(rs1),
    .b(rs2),
    .minmax(1'b0), // Min operation selector (minmax = 0 for minimum)
    .result(fmin_out)
);

fp_minmax_d u_max (
    .a(rs1),
    .b(rs2),
    .minmax(1'b1), // Max operation selector (minmax = 1 for maximum)
    .result(fmax_out)
);

// Instantiation of comparison modules
fp_cmp_d u_cmp (
    .a(rs1),
    .b(rs2),
    .op(alu_op[1:0]), // Comparison operation selector (FEQ.D, FLT.D, FLE.D)
    .result (comparision_out)
);


// Instantiation of precision conversion modules

// Float-to-float conversions (single-to-double and double-to-single precision)
fp_cvt_sd u_cvt_sd (
    .s(fs_rs1),       // Single-precision input
    .d(fcvt_sd_out)   // Double-precision output
);

fp_cvt_ds u_cvt_ds (
    .d(rs1),          // Double-precision input
    .s(fcvt_ds_out)   // Single-precision output
);



// Integer-to-Float Conversions (Signed and Unsigned Integers)

// Convert 32-bit signed integer to double-precision float (FCVT.D.W)
fp_cvt_d_w u_cvt_d_w (
    .w(int_rs1[31:0]),   // Input 32-bit signed integer
    .d(fcvt_d_w_out)     // Output double-precision float
);

// Convert 32-bit unsigned integer to double-precision float (FCVT.D.WU)
fp_cvt_d_wu u_cvt_d_wu (
    .wu(int_rs1[31:0]),  // Input 32-bit unsigned integer
    .d(fcvt_d_wu_out)     // Output double-precision float
);

fp_cvt_wd u_cvt_wd (
    .d(rs1),             //  double-precision floating-point input (rs1)
    .signed_ctrl(alu_op[0]), // Signed/unsigned control based on ALU operation code
    .w(fcvt_wd_out)      // Output signed integer value (32 bits)
);

// Convert double-precision float to 32-bit unsigned integer (FCVT.WU.D)
fp_cvt_wu_d u_cvt_wu_d (
    .d(rs1),             // Input double-precision float
    .wu(fcvt_wu_d_out)   // Output 32-bit unsigned integer
);

// Instantiation of RV64-Specific Conversion Modules

// Convert 64-bit signed integer to double-precision float (FCVT.D.L)
fp_cvt_d_l u_cvt_d_l (
    .l(int_rs1),       // Input 64-bit signed integer
    .d(fcvt_d_l_out)   // Output double-precision float
);

// Convert 64-bit unsigned integer to double-precision float (FCVT.D.LU)
fp_cvt_d_lu u_cvt_d_lu (
    .lu(int_rs1),      // Input 64-bit unsigned integer
    .d(fcvt_d_lu_out)  // Output double-precision float
);

// Convert double-precision float to 64-bit signed integer (FCVT.L.D)
fp_cvt_ld u_cvt_ld (
    .d(rs1),           // Input double-precision float
    .signed_ctrl(alu_op[0]),
    .l(fcvt_ld_out)    // Output 64-bit signed integer
);

// Convert double-precision float to 64-bit unsigned integer (FCVT.LU.D)
fp_cvt_lu_d u_cvt_lu_d (
    .d(rs1),           // Input double-precision float
    .lu(fcvt_lu_d_out) // Output 64-bit unsigned integer
);


// Instantiation of Classification module
fp_class_d u_class (
    .d(rs1),           // Input double-precision float
    .flags(fclass_out) // Output classification flags
);



// Main ALU control logic
always @* begin
    result = 64'b0;
    fs_result = 32'b0;
    int_result = 64'b0;

    case(alu_op)
        5'b00000: result = fadd_out;   // FADD.D
        5'b00001: result = fadd_out;   // FSUB.D
        5'b00010: result = fmul_out;   // FMUL.D
        5'b00011: result = fdiv_out;   // FDIV.D
        5'b00100: result = fsqrt_out;  // FSQRT.D

        // Fused operations (RISC-V F extension)
        5'b00101: result = fma_out;   // FMADD.D
        5'b00110: result = fma_out;   // FMSUB.D
        5'b00111: result = fma_out;   // FNMADD.D
        5'b01000: result = fma_out;   // FNMSUB.D

        // Sign injection operations
        5'b01001: result = fsgnj_out; // FSGNJ.D
        5'b01010: result = fsgnj_out; // FSGNJN.D
        5'b01011: result = fsgnj_out; // FSGNJX.D

        // Min-Max Operations
        5'b01100: result = fmin_out;   // FMIN.D
        5'b01101: result = fmax_out;   // FMAX.D

        // Comparison operations (FEQ, FLT, FLE)
        5'b01110: int_result = {63'b0, comparision_out};   // FEQ.D (Equal comparison)
        5'b01111: int_result = {63'b0, comparision_out};   // FLT.D (Less-than comparison)
        5'b10000: int_result = {63'b0, comparision_out};   // FLE.D (Less-than-or-equal comparison)

        //Precision conversion operations
        5'b10001: fs_result = fcvt_ds_out;   // FCVT.S.D (Double to Single Precision Conversion)
        5'b10010: result = fcvt_sd_out;           // FCVT.D.S (Single to Double Precision Conversion)

        // Integer ? Float Conversions 
        5'b10011: result = fcvt_d_w_out;      /* FCVT.D.W */
        5'b10100: result = fcvt_d_wu_out;     /* FCVT.D.WU */
        5'b10101: int_result = {{32{fcvt_wd_out[31]}}, fcvt_wd_out}; /* Sign-extend fcvt_wd_out to 64 bits */
        5'b10110: int_result = {32'b0, fcvt_wu_d_out};               /* FCVT.WU.D */
        
        // RV64-Specific Conversions
        5'b10111: result = fcvt_d_l_out;   /* FCVT.D.L */
        5'b11000: result = fcvt_d_lu_out; /* FCVT.D.LU */
        5'b11001: int_result = fcvt_ld_out; /* FCVT.L.D */
        5'b11010: int_result = fcvt_lu_d_out; /* FCVT.LU.D */

        // Classification and moves 
        5'b11011: int_result = fclass_out;   // FCLASS.D
        5'b11100: int_result = rs1;          // FMV.X.D
        5'b11101: result = int_rs1;          // FMV.D.X

        default: begin
            result = 64'b0;
            fs_result = 32'b0;
            int_result = 64'b0;
        end
    endcase
end

endmodule

