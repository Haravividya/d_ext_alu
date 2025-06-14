class FMUL_D_Test extends d_ext_alu_base_test;

  // Factory registration
  `uvm_component_utils(FMUL_D_Test)
   FMUL_D_seq fmul_seq;


  // Constructor
  function new(string name = "FMUL_D_Test", uvm_component parent = null);
    super.new(name, parent);
    fmul_seq = FMUL_D_seq::type_id::create("fmul_seq");
  endfunction

  // Build Phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  // Run Phase
  task run_phase(uvm_phase phase);
      phase.raise_objection(this);
     `uvm_info(get_full_name(), $sformatf("Inside the fmul test"), UVM_MEDIUM)
    // begin
      //fmul_seq.scenario = 1;
      //fmul_seq.start(env.agent.sequencer);
         // @(fmul_seq.seq_done);
     //end
// #10;
   // repeat(10)begin
      fmul_seq.scenario = 2;
      fmul_seq.start(env.agent.sequencer);
      //  @(fmul_seq.seq_done);
   // end
  
     `uvm_info(get_type_name(),$sformatf("random mul scenario 2 is completed"),UVM_MEDIUM)
     `uvm_info(get_full_name(), $sformatf("Inside the mul test done"), UVM_MEDIUM)
      #200;
      phase.drop_objection(this);
  endtask

endclass

