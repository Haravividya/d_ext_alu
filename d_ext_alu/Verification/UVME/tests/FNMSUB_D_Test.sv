class FNMSUB_D_Test extends d_ext_alu_base_test;

  // Factory registration
  `uvm_component_utils(FNMSUB_D_Test)
   FNMSUB_D_seq fnmsub_seq;


  // Constructor
  function new(string name = "FNMSUB_D_Test", uvm_component parent = null);
    super.new(name, parent);
    fnmsub_seq = FNMSUB_D_seq::type_id::create("fnmsub_seq");
  endfunction

  // Build Phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  // Run Phase
  task run_phase(uvm_phase phase);
      phase.raise_objection(this);
     `uvm_info(get_full_name(), $sformatf("Inside the nagetd fused multiply-sub test"), UVM_MEDIUM)
    // begin
      //fnmsub_seq.scenario = 1;
      //fnmsub_seq.start(env.agent.sequencer);
         // @(fmul_seq.seq_done);
     //end
// #10;
   // repeat(10)begin
      fnmsub_seq.scenario = 2;
      fnmsub_seq.start(env.agent.sequencer);
      //  @(fmul_seq.seq_done);
   // end
  
     `uvm_info(get_type_name(),$sformatf("random  nagetd fused multiply-sub  scenario 2 is completed"),UVM_MEDIUM)
     `uvm_info(get_full_name(), $sformatf("Inside the   nagetd fused multiply-sub test done"), UVM_MEDIUM)
      #200;
      phase.drop_objection(this);
  endtask

endclass

