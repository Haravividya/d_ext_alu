module d_ext_alu_top;

    import uvm_pkg::*;
    import test_pkg::*;
    
        
    d_ext_alu_interface vif();


//dut instantiation
RISCV_D_ALU  dut (  .rs1(vif.rs1),
                   .rs2(vif.rs2),
                   .rs3(vif.rs3),
                   .fs_rs1(vif.fs_rs1),
                   .int_rs1(vif.int_rs1),
                   .alu_op(vif.alu_op),
                   .result(vif.result),
                   .fs_result(vif.fs_result),
                   .int_result(vif.int_result));


                        
initial begin
    uvm_config_db#(virtual d_ext_alu_interface)::set(null,"*","d_ext_alu_interface",vif);
end

//Run the test
initial begin
    run_test("d_ext_alu_base_test");
end
 
//wavedump
initial begin
    $shm_open("wave.shm");
    $shm_probe("AS");
end




endmodule 			          
