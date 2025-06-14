class d_ext_alu_cov extends uvm_subscriber#(d_ext_alu_tx);
    d_ext_alu_tx tx;

//factory registration
    `uvm_component_utils(d_ext_alu_cov)

covergroup alu_io_cg();
                 // Input Ports Coverage
                 rs1_cp: coverpoint tx.rs1 {
                          option.auto_bin_max = 64; // Covers all 64-bit values
                 }

                 rs2_cp: coverpoint tx.rs2 {
                          option.auto_bin_max = 64;

                 }

                 rs3_cp: coverpoint tx.rs3 {
                          option.auto_bin_max = 64;

                 }

                 fs_rs1_cp: coverpoint tx.fs_rs1 {
                          option.auto_bin_max = 32;
                          
                 }

                 int_rs1_cp: coverpoint tx.int_rs1 {
                          option.auto_bin_max = 64; // Covers 64-bit integer inputs


                 }

                 alu_op_cp: coverpoint tx.alu_op {
                          bins fadd_d     = {5'b00000}; // Double-precision Addition
                          bins fsub_d     = {5'b00001}; // Double-precision Subtraction
                          bins fmul_d     = {5'b00010}; // Double-precision Multiplication
                          bins fdiv_d     = {5'b00011}; // Double-precision Division
                          bins fsqrt_d    = {5'b00100}; // Double-precision Square Root
                          bins fmadd_d    = {5'b00101}; // Fused Multiply-Add
                          bins fmsub_d    = {5'b00110}; // Fused Multiply-Subtract
                          bins fnmadd_d   = {5'b00111}; // Negated Fused Multiply-Add
                          bins fnmsub_d   = {5'b01000}; // Negated Fused Multiply-Subtract
                          bins fsgnj_d    = {5'b01001}; // Sign Injection
                          bins fsgnjn_d   = {5'b01010}; // Negated Sign Injection
                          bins fsgnjx_d   = {5'b01011}; // XOR Sign Injection
                          bins fmin_d     = {5'b01100}; // Double-precision Minimum
                          bins fmax_d     = {5'b01101}; // Double-precision Maximum
                          bins feq_d      = {5'b01110}; // Equality Comparison
                          bins flt_d      = {5'b01111}; // Less Than Comparison
                          bins fle_d      = {5'b10000}; // Less Than or Equal Comparison
                          bins fcvt_s_d   = {5'b10001}; // Convert Double to Single Precision
                          bins fcvt_d_s   = {5'b10010}; // Convert Single to Double Precision
                          bins fcvt_d_w   = {5'b10011}; // Convert 32-bit Integer to Double
                          bins fcvt_d_wu  = {5'b10100}; // Convert 32-bit Unsigned Int to Double
                          bins fcvt_w_d   = {5'b10101}; // Convert Double to 32-bit Integer
                          bins fcvt_wu_d  = {5'b10110}; // Convert Double to 32-bit Unsigned Int
                          bins fcvt_d_l   = {5'b10111}; // Convert 64-bit Integer to Double
                          bins fcvt_d_lu  = {5'b11000}; // Convert 64-bit Unsigned Int to Double
                          bins fcvt_l_d   = {5'b11001}; // Convert Double to 64-bit Integer
                          bins fcvt_lu_d  = {5'b11010}; // Convert Double to 64-bit Unsigned Int
                          bins fclass_d   = {5'b11011}; // Classify Floating-Point Number
                          bins fmv_x_d    = {5'b11100}; // Move Double to Integer Register
                          bins fmv_d_x    = {5'b11101}; // Move Integer to Double Register
                 }

//////////////////////////////////////////////////////////////////////////////////////////////////////////
                 // Output Ports Coverage
                 result_cp: coverpoint tx.result {
                          option.auto_bin_max = 64; // Covers all 64-bit results

                 }

                 fs_result_cp: coverpoint tx.fs_result {
                         option.auto_bin_max = 16; // Covers all 32-bit single-precision results


                 }

                 int_result_cp: coverpoint tx.int_result {
                         option.auto_bin_max = 64; // Covers all 64-bit integer results



                 }

                 // Cross Coverage
                 //result_vs_rs1_rs2_rs3: cross  rs1_cp,rs2_cp,rs3_cp;
                 //fs_result_vs_rs1: cross  rs1_cp,fs_result_cp ;
                 //  int_result_vs_rs1: cross rs1_cp ,int_result_cp;

endgroup
///////////////////////////////////////////////////////////////////////////////////////////////////////////
       
    function new(string name,uvm_component parent);
        super.new(name,parent);
        alu_io_cg  = new();
    endfunction
    

    virtual function void write(d_ext_alu_tx t);
        this.tx = t;

        if (t != null) begin
            alu_io_cg.sample();
            `uvm_info("COVERAGE",$sformatf("alu_op=%b",tx.alu_op),UVM_LOW)
        end
    endfunction

endclass
