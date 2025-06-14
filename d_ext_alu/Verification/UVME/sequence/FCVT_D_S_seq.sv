class FCVT_D_S_seq extends uvm_sequence#(d_ext_alu_tx);
  //factory registration
  `uvm_object_utils(FCVT_D_S_seq)
  //creating sequence item handle
   d_ext_alu_tx tx;

   int scenario;

  //constructor
   function new(string name="FCVT_D_S_seq");
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

                `uvm_info (get_type_name(),"Starting Scenario 1:fixed value test case", UVM_LOW)
                `uvm_do_with(tx, {
                                    tx.alu_op == 5'b10010; 
                                    tx.fs_rs1 == 32'h40C00000; //(6.0);
                                    
                            })
                `uvm_info (get_type_name(),$sformatf("fs_rs1=%h",tx.fs_rs1), UVM_LOW)

                `uvm_info(get_type_name(), "Starting Scenario 1: fixed test case done", UVM_LOW)
         end
         
        if (scenario == 2)
       for(int i=0;i<200;i++)
        begin

                `uvm_info(get_type_name(), "Starting Scenario 2: Random test case started", UVM_LOW)
                `uvm_do_with(tx, {
                                    tx.alu_op == 5'b10010;
                                    tx.fs_rs1 inside  {[32'h00000000 : 32'hFFFFFFFF],[32'h80000000 : 32'h7FFFFFFF] }; 


                            })

                `uvm_info(get_type_name(), "Starting Scenario 2: Random test case done", UVM_LOW)
                
        end
  endtask
endclass  



