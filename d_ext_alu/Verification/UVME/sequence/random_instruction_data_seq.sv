class random_instruction_data_seq extends uvm_sequence#(d_ext_alu_tx);
  //factory registration
  `uvm_object_utils(random_instruction_data_seq)
  //creating sequence item handle
   d_ext_alu_tx tx;
   randc [0:4]alu_op;

   int scenario;

  //constructor
   function new(string name="random_instruction_data_seq");
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
                                    tx.alu_op inside  {[0:32]};
                                    tx.rs1 inside     {[64'h0000000000000000 : 64'hFFFFFFFFFFFFFFFF], 
                                                      [64'h8000000000000000 : 64'h7FFFFFFFFFFFFFFF]};
                                    tx.rs2 inside     {[64'h0000000000000000 : 64'hFFFFFFFFFFFFFFFF], 
                                                      [64'h8000000000000000 : 64'h7FFFFFFFFFFFFFFF]};
                                    tx.rs3 inside     {[64'h0000000000000000 : 64'hFFFFFFFFFFFFFFFF], 
                                                      [64'h8000000000000000 : 64'h7FFFFFFFFFFFFFFF]};
                                    tx.int_rs1 inside {[64'h0000_0000_0000_0000 : 64'h0000_0000_FFFF_FFFF]};
                                    tx.fs_rs1 inside  {[32'h00000000 : 32'hFFFFFFFF],[32'h80000000 : 32'h7FFFFFFF] }; 


                                                               })

                `uvm_info(get_type_name(), "Starting Scenario 1: fixed value for all the instructions test case done", UVM_LOW)
         end
         
  endtask
endclass  

