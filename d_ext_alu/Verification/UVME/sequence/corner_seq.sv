class corner_seq extends uvm_sequence#(d_ext_alu_tx);
  //factory registration
  `uvm_object_utils(corner_seq)
  //creating sequence item handle
   d_ext_alu_tx tx;

   int scenario;
  // event seq_done;

  //constructor
   function new(string name="corner_seq");
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

                `uvm_info (get_type_name(),"Starting Scenario 1:corner teste test case", UVM_LOW)
                `uvm_do_with(tx, {
                                    tx.alu_op inside {[0:32]};
                                    tx.rs1 inside {64'h0000000000000001,64'h1111111111111111,64'hAAAAAAAAAAAAAAAA};
                                    tx.rs2 inside {64'h123456789ABCDEF0,64'h0,64'hFFFFFFFF00000000};
                                    tx.rs3 inside {64'h0000000000000000,64'hFEDCBA9876543210};
                                    tx.fs_rs1 inside {64'h3F800000,64'hBF800000};
                                    tx.int_rs1 inside {64'h7FFFFFFF,64'h80000000};

                            })

                `uvm_info(get_type_name(), "Starting Scenario 1: corner test case done", UVM_LOW)

         end

         


  endtask
endclass  



