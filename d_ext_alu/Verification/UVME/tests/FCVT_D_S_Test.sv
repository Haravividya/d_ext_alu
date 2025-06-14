class FCVT_D_S_Test extends d_ext_alu_base_test;

  // Factory registration
     `uvm_component_utils(FCVT_D_S_Test)
      FCVT_D_S_seq fcvt_d_s_seq;


  // Constructor
  function new(string name = "FCVT_D_S_Test", uvm_component parent = null);
      super.new(name, parent);
      fcvt_d_s_seq = FCVT_D_S_seq::type_id::create("fcvt_d_s_seq");
  endfunction

  // Build Phase
  function void build_phase(uvm_phase phase);
      super.build_phase(phase);
  endfunction

  // Run Phase
  task run_phase(uvm_phase phase);
      phase.raise_objection(this);
     `uvm_info(get_full_name(), $sformatf("Inside the  fcvt_d_s test"), UVM_MEDIUM)
    // begin
      //fcvt_d_s_seq.scenario = 1;
      //fcvt_d_s_seq.start(env.agent.sequencer);
         // @(fmul_seq.seq_done);
     //end
// #10;
   // repeat(10)begin
      fcvt_d_s_seq.scenario = 2;
      fcvt_d_s_seq.start(env.agent.sequencer);
      //  @(fmul_seq.seq_done);
   // end
  
     `uvm_info(get_type_name(),$sformatf("random fcvt_d_s scenario 2 is completed"),UVM_MEDIUM)
     `uvm_info(get_full_name(), $sformatf("Inside the  fcvt_d_s test done"), UVM_MEDIUM)
      #200;
      phase.drop_objection(this);
  endtask

endclass

