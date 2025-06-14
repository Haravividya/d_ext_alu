class FMSUB_D_Test extends d_ext_alu_base_test;

  // Factory registration
  `uvm_component_utils(FMSUB_D_Test)
   FMSUB_D_seq fmsub_seq;


  // Constructor
  function new(string name = "FMSUB_D_Test", uvm_component parent = null);
    super.new(name, parent);
    fmsub_seq = FMSUB_D_seq::type_id::create("fmsub_seq");
  endfunction

  // Build Phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  // Run Phase
  task run_phase(uvm_phase phase);
      phase.raise_objection(this);
     `uvm_info(get_full_name(), $sformatf("Inside the fmsub test"), UVM_MEDIUM)
    // begin
      //fmsub_seq.scenario = 1;
      //fmsub_seq.start(env.agent.sequencer);
         // @(fmul_seq.seq_done);
     //end
// #10;
   // repeat(10)begin
      fmsub_seq.scenario = 2;
      fmsub_seq.start(env.agent.sequencer);
      //  @(fmul_seq.seq_done);
   // end
  
     `uvm_info(get_type_name(),$sformatf("random fmsub scenario 2 is completed"),UVM_MEDIUM)
     `uvm_info(get_full_name(), $sformatf("Inside the fmsub test done"), UVM_MEDIUM)
      #200;
      phase.drop_objection(this);
  endtask

endclass

