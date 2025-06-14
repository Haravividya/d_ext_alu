class FSQRT_D_Test extends d_ext_alu_base_test;

  // Factory registration
  `uvm_component_utils(FSQRT_D_Test)
   FSQRT_D_seq fsqrt_seq;


  // Constructor
  function new(string name = "FSQRT_D_Test", uvm_component parent = null);
    super.new(name, parent);
    fsqrt_seq = FSQRT_D_seq::type_id::create("fsqrt_seq");
  endfunction

  // Build Phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  // Run Phase
  task run_phase(uvm_phase phase);
      phase.raise_objection(this);
     `uvm_info(get_full_name(), $sformatf("Inside the fsqrt test"), UVM_MEDIUM)
    // begin
      //fsqrt_seq.scenario = 1;
      //fsqrt_seq.start(env.agent.sequencer);
         // @(fmul_seq.seq_done);
     //end
// #10;
   // repeat(10)begin
      fsqrt_seq.scenario = 2;
      fsqrt_seq.start(env.agent.sequencer);
      //  @(fmul_seq.seq_done);
   // end
  
     `uvm_info(get_type_name(),$sformatf("random sqrt scenario 2 is completed"),UVM_MEDIUM)
     `uvm_info(get_full_name(), $sformatf("Inside the sqrt test done"), UVM_MEDIUM)
      #200;
      phase.drop_objection(this);
  endtask

endclass

