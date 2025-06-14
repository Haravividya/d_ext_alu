class d_ext_alu_tx extends uvm_sequence_item;

    rand bit [63:0] rs1, rs2, rs3;
    rand bit [31:0] fs_rs1;
    rand bit [63:0] int_rs1;
    rand bit [4:0]  alu_op;
         bit [63:0] result;
         bit [31:0] fs_result;
         bit [63:0] int_result;
 
 
//factory registration
    `uvm_object_utils_begin(d_ext_alu_tx)
        `uvm_field_int(rs1, UVM_ALL_ON)  // Stores 64-bit floating-point as hex
        `uvm_field_int(rs2, UVM_ALL_ON)
        `uvm_field_int(rs3, UVM_ALL_ON)
        `uvm_field_int(fs_rs1, UVM_ALL_ON)
        `uvm_field_int(int_rs1,UVM_ALL_ON)
        `uvm_field_int(alu_op, UVM_ALL_ON)
        `uvm_field_int(result, UVM_ALL_ON)
        `uvm_field_int(fs_result,UVM_ALL_ON)
        `uvm_field_int(int_result,UVM_ALL_ON)
    `uvm_object_utils_end

//new constructor
    function new(string name="d_ext_alu_tx");
        super.new(name);
  	endfunction




endclass
