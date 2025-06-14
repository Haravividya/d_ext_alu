class FDIV_D_Test extends d_ext_alu_base_test;

  // Factory registration
  `uvm_component_utils(FDIV_D_Test)
   FDIV_D_seq fdiv_seq;


  // Constructor
  function new(string name = "FDIV_D_Test", uvm_component parent = null);
    super.new(name, parent);
    fdiv_seq = FDIV_D_seq::type_id::create("fdiv_seq");
  endfunction

  // Build Phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  // Run Phase
  task run_phase(uvm_phase phase);
      phase.raise_objection(this);
     `uvm_info(get_full_name(), $sformatf("Inside the fdiv test"), UVM_MEDIUM)
    // begin
      //fdiv_seq.scenario = 1;
      //fdiv_seq.start(env.agent.sequencer);
         // @(fmul_seq.seq_done);
     //end
// #10;
   // repeat(10)begin
      fdiv_seq.scenario = 2;
      fdiv_seq.start(env.agent.sequencer);
      //  @(fmul_seq.seq_done);
   // end
  
     `uvm_info(get_type_name(),$sformatf("random div scenario 2 is completed"),UVM_MEDIUM)
     `uvm_info(get_full_name(), $sformatf("Inside the div test done"), UVM_MEDIUM)
      #200;
      phase.drop_objection(this);
  endtask

endclass

