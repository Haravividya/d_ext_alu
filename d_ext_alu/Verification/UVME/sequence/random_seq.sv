class random_seq extends uvm_sequence#(d_ext_alu_tx);
  //factory registration
  `uvm_object_utils(random_seq)
  //creating sequence item handle
   d_ext_alu_tx tx;
   randc [0:4]alu_op;

   int scenario;

  //constructor
   function new(string name="random_seq");
        super.new(name);
   endfunction
  
  //Build phase
  function build_phase(uvm_phase phase);
        tx = d_ext_alu_tx::type_id::create("tx");
  endfunction
  
  //task body
  task body();

         if (scenario == 1)
         for(int i=0;i<30;i++)
         begin

                `uvm_info (get_type_name(),"Starting Scenario 1:fixed value for all the instructions test case", UVM_LOW)
                `uvm_do_with(tx, {
                                    tx.alu_op inside {[0:32]}; 
                                    tx.rs1 == 64'h4000_0000_0000_0000; // 2.0
                                    tx.rs2 == 64'h4010_0000_0000_0000; // 4.0
                                    tx.rs3 == 64'h4010_0000_0000_0000;
                                    tx.fs_rs1 == 32'h40C00000; 
                                    tx.int_rs1 == 32'hFFFFFFFF;


                            })

                `uvm_info(get_type_name(), "Starting Scenario 1: fixed value for all the instructions test case done", UVM_LOW)
         end
         
  endtask
endclass  



