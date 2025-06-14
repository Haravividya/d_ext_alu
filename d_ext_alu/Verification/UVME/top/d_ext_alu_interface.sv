interface d_ext_alu_interface();	                 

          logic [63:0] rs1, rs2, rs3;
          //$display("rs1 in interface: %h", vif.rs1);

          logic [31:0] fs_rs1;
          logic [63:0] int_rs1;
          logic [4:0]  alu_op;
          logic [63:0] result;
          logic [31:0] fs_result;
          logic [63:0] int_result;
 

      
      /*always @(rs1) begin
        $display("INTERFACE: rs1 = %h", rs1);
    end*/

endinterface

