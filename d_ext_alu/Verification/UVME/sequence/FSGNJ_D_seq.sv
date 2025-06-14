class FSGNJ_D_seq extends uvm_sequence#(d_ext_alu_tx);
  //factory registration
  `uvm_object_utils(FSGNJ_D_seq)
  //creating sequence item handle
   d_ext_alu_tx tx;

   int scenario;

  //constructor
   function new(string name="FSGNJ_D_seq");
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
                                    tx.alu_op == 5'b01001; 
                                    tx.rs1 == 64'hC008000000000000; //(-3.0))
                                    tx.rs2 == 64'h4000000000000000; //(2.0)    
                            })
                `uvm_info (get_type_name(),$sformatf("rs1=%h",tx.rs1), UVM_LOW)

                `uvm_info(get_type_name(), "Starting Scenario 1: fixed test case done", UVM_LOW)
         end
         
        if (scenario == 2)
       // repeat(10)
        for(int i=0;i<200;i++)

        begin

                `uvm_info(get_type_name(), "Starting Scenario 2: Random test case started", UVM_LOW)
                `uvm_do_with(tx, {
                                    tx.alu_op == 5'b01001;
                                    tx.rs1 inside {[64'h0000000000000000 : 64'hFFFFFFFFFFFFFFFF], 
                                                   [64'h8000000000000000 : 64'h7FFFFFFFFFFFFFFF]};
                                    tx.rs2 inside {[64'h0000000000000000 : 64'hFFFFFFFFFFFFFFFF], 
                                                   [64'h8000000000000000 : 64'h7FFFFFFFFFFFFFFF]};
 
                            })

                `uvm_info(get_type_name(), "Starting Scenario 2: Random test case done", UVM_LOW)
                
        end
       // ->seq_done;
  endtask
endclass  



