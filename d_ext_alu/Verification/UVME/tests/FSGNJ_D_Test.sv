class FSGNJ_D_Test extends d_ext_alu_base_test;

  // Factory registration
     `uvm_component_utils(FSGNJ_D_Test)
      FSGNJ_D_seq fsgnj_seq;


  // Constructor
  function new(string name = "FSGNJ_D_Test", uvm_component parent = null);
      super.new(name, parent);
      fsgnj_seq = FSGNJ_D_seq::type_id::create("fsgnj_seq");
  endfunction

  // Build Phase
  function void build_phase(uvm_phase phase);
      super.build_phase(phase);
  endfunction

  // Run Phase
  task run_phase(uvm_phase phase);
      phase.raise_objection(this);
     `uvm_info(get_full_name(), $sformatf("Inside the  sign injection test test"), UVM_MEDIUM)
    // begin
      //fsgnj_seq.scenario = 1;
      //fsgnj_seq.start(env.agent.sequencer);
         // @(fmul_seq.seq_done);
     //end
// #10;
   // repeat(10)begin
      fsgnj_seq.scenario = 2;
      fsgnj_seq.start(env.agent.sequencer);
      //  @(fmul_seq.seq_done);
   // end
  
     `uvm_info(get_type_name(),$sformatf("random sign injection scenario 2 is completed"),UVM_MEDIUM)
     `uvm_info(get_full_name(), $sformatf("Inside the sign injection test  test done"), UVM_MEDIUM)
      #200;
      phase.drop_objection(this);
  endtask

endclass

