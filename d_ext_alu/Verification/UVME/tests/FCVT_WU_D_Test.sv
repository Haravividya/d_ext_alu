class FCVT_WU_D_Test extends d_ext_alu_base_test;

  // Factory registration
     `uvm_component_utils(FCVT_WU_D_Test)
      FCVT_WU_D_seq fcvt_wu_d_seq;


  // Constructor
  function new(string name = "FCVT_WU_D_Test", uvm_component parent = null);
      super.new(name, parent);
    fcvt_wu_d_seq =  FCVT_WU_D_seq::type_id::create("fcvt_wu_d_seq");
  endfunction

  // Build Phase
  function void build_phase(uvm_phase phase);
      super.build_phase(phase);
  endfunction

  // Run Phase
  task run_phase(uvm_phase phase);
      phase.raise_objection(this);
     `uvm_info(get_full_name(), $sformatf("Inside the  fcvt_wu_d test"), UVM_MEDIUM)
    // begin
      //fcvt_wu_d_seq.scenario = 1;
      //fcvt_wu_d_seq.start(env.agent.sequencer);
         // @(fmul_seq.seq_done);
     //end
// #10;
   // repeat(10)begin
      fcvt_wu_d_seq.scenario = 2;
      fcvt_wu_d_seq.start(env.agent.sequencer);
      //  @(fmul_seq.seq_done);
   // end
  
     `uvm_info(get_type_name(),$sformatf("random fcvt_wu_d scenario 2 is completed"),UVM_MEDIUM)
     `uvm_info(get_full_name(), $sformatf("Inside the  fcvt_wu_d test done"), UVM_MEDIUM)
      #200;
      phase.drop_objection(this);
  endtask

endclass

