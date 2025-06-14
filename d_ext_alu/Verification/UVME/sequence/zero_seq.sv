class zero_seq extends uvm_sequence#(d_ext_alu_tx);
  //factory registration
  `uvm_object_utils(zero_seq)
  //creating sequence item handle
   d_ext_alu_tx tx;

   int scenario;
  // event seq_done;

  //constructor
   function new(string name="zero_seq");
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

                `uvm_info (get_type_name(),"Starting Scenario 1:zero teste test case", UVM_LOW)
                `uvm_do_with(tx, {
                                    tx.alu_op == 5'b00000; 
                                    tx.rs1 == 64'h0000_0000_0000_0000; // 2.0
                                    tx.rs2 == 64'h0000_0000_0000_0000; // 4.0
                                    tx.rs3 == 64'h0000_0000_0000_0000;
                                    tx.fs_rs1 == 32'h0000_0000;
                                    tx.int_rs1 ==  64'h0000_0000_0000_0000;

                            })

                `uvm_info(get_type_name(), "Starting Scenario 1: zero test case done", UVM_LOW)

         end


         if (scenario == 2) 
         begin

                `uvm_info (get_type_name(),"Starting Scenario 1:zero teste test case", UVM_LOW)
                `uvm_do_with(tx, {
                                    tx.alu_op == 5'b11111; 
                                    tx.rs1 == 64'h1111_1111_1111_1111; // 2.0
                                    tx.rs2 == 64'h1111_1111_1111_1111; // 4.0
                                    tx.rs3 == 64'h1111_1111_1111_1111;
                                    tx.fs_rs1 == 32'h1111_1111;
                                    tx.int_rs1 ==  64'h1111_1111_1111_1111;

                            })

                `uvm_info(get_type_name(), "Starting Scenario 1: zero test case done", UVM_LOW)

         end

         


  endtask
endclass  



