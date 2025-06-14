class FLE_D_Test extends d_ext_alu_base_test;

  // Factory registration
     `uvm_component_utils(FLE_D_Test)
      FLE_D_seq fle_seq;


  // Constructor
  function new(string name = "FLE_D_Test", uvm_component parent = null);
      super.new(name, parent);
      fle_seq = FLE_D_seq::type_id::create("fle_seq");
  endfunction

  // Build Phase
  function void build_phase(uvm_phase phase);
      super.build_phase(phase);
  endfunction

  // Run Phase
  task run_phase(uvm_phase phase);
      phase.raise_objection(this);
     `uvm_info(get_full_name(), $sformatf("Inside the  fle test"), UVM_MEDIUM)
    // begin
      //fle_seq.scenario = 1;
      //fle_seq.start(env.agent.sequencer);
         // @(fmul_seq.seq_done);
     //end
// #10;
   // repeat(10)begin
      fle_seq.scenario = 2;
      fle_seq.start(env.agent.sequencer);
      //  @(fmul_seq.seq_done);
   // end
  
     `uvm_info(get_type_name(),$sformatf("random fle scenario 2 is completed"),UVM_MEDIUM)
     `uvm_info(get_full_name(), $sformatf("Inside the  fle test done"), UVM_MEDIUM)
      #200;
      phase.drop_objection(this);
  endtask

endclass

