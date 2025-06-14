class one_seq extends uvm_sequence#(d_ext_alu_tx);
  //factory registration
  `uvm_object_utils(one_seq)
  //creating sequence item handle
   d_ext_alu_tx tx;

   int scenario;
  // event seq_done;

  //constructor
   function new(string name="one_seq");
        super.new(name);
   endfunction
  
  //Build phase
  function build_phase(uvm_phase phase);
        tx = d_ext_alu_tx::type_id::create("tx");
  endfunction
  
  //task body
  task body();

 
         

         if (scenario == 1) 
         begin

                `uvm_info (get_type_name(),"Starting Scenario 1:one teste test case", UVM_LOW)
                `uvm_do_with(tx, {
                                    tx.alu_op == 5'b11111; 
                                    tx.rs1 == 64'hffff_ffff_ffff_ffff; // 2.0
                                    tx.rs2 == 64'hffff_ffff_ffff_ffff; // 4.0
                                    tx.rs3 == 64'hffff_ffff_ffff_ffff;
                                    tx.fs_rs1 == 32'hffff_ffff;
                                    tx.int_rs1 ==  64'hffff_ffff_ffff_ffff;

                            })

                `uvm_info(get_type_name(), "Starting Scenario 1: one test case done", UVM_LOW)

         end

         


  endtask
endclass  



