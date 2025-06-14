class FEQ_D_Test extends d_ext_alu_base_test;

  // Factory registration
     `uvm_component_utils(FEQ_D_Test)
      FEQ_D_seq feq_seq;


  // Constructor
  function new(string name = "FEQ_D_Test", uvm_component parent = null);
      super.new(name, parent);
      feq_seq = FEQ_D_seq::type_id::create("feq_seq");
  endfunction

  // Build Phase
  function void build_phase(uvm_phase phase);
      super.build_phase(phase);
  endfunction

  // Run Phase
  task run_phase(uvm_phase phase);
      phase.raise_objection(this);
     `uvm_info(get_full_name(), $sformatf("Inside the  feq test"), UVM_MEDIUM)
    // begin
      //feq_seq.scenario = 1;
      //feq_seq.start(env.agent.sequencer);
         // @(fmul_seq.seq_done);
     //end
// #10;
   // repeat(10)begin
      feq_seq.scenario = 2;
      feq_seq.start(env.agent.sequencer);
      //  @(fmul_seq.seq_done);
   // end
  
     `uvm_info(get_type_name(),$sformatf("random feq scenario 2 is completed"),UVM_MEDIUM)
     `uvm_info(get_full_name(), $sformatf("Inside the  feq test done"), UVM_MEDIUM)
      #200;
      phase.drop_objection(this);
  endtask

endclass

