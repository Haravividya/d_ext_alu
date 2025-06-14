class FLT_D_Test extends d_ext_alu_base_test;

  // Factory registration
     `uvm_component_utils(FLT_D_Test)
      FLT_D_seq flt_seq;


  // Constructor
  function new(string name = "FLT_D_Test", uvm_component parent = null);
      super.new(name, parent);
      flt_seq = FLT_D_seq::type_id::create("flt_seq");
  endfunction

  // Build Phase
  function void build_phase(uvm_phase phase);
      super.build_phase(phase);
  endfunction

  // Run Phase
  task run_phase(uvm_phase phase);
      phase.raise_objection(this);
     `uvm_info(get_full_name(), $sformatf("Inside the  flt test"), UVM_MEDIUM)
    // begin
      //flt_seq.scenario = 1;
      //flt_seq.start(env.agent.sequencer);
         // @(fmul_seq.seq_done);
     //end
// #10;
   // repeat(10)begin
      flt_seq.scenario = 2;
      flt_seq.start(env.agent.sequencer);
      //  @(fmul_seq.seq_done);
   // end
  
     `uvm_info(get_type_name(),$sformatf("random flt scenario 2 is completed"),UVM_MEDIUM)
     `uvm_info(get_full_name(), $sformatf("Inside the  flt test done"), UVM_MEDIUM)
      #200;
      phase.drop_objection(this);
  endtask

endclass

