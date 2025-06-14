class fcvt_sd_coverage_test extends d_ext_alu_base_test;

  // Factory registration
  `uvm_component_utils(fcvt_sd_coverage_test)
   fcvt_sd_covrage fcvt_seq;


  // Constructor
  function new(string name = "fcvt_sd_coverage_test", uvm_component parent = null);
    super.new(name, parent);
    fcvt_seq = fcvt_sd_coverage::type_id::create("fcvt_seq");
   // fcvt_seq1 = fcvt_sd_coverage::type_id::create("fcvt_seq1");
  endfunction

  // Build Phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  // Run Phase
  task run_phase(uvm_phase phase);
     phase.raise_objection(this);
     `uvm_info(get_full_name(), $sformatf("Inside the random sd test"), UVM_MEDIUM)
    // begin
     //fcvt_seq.scenario = 1;
      //fcvt_seq.start(env.agent.sequencer);
         // @(fcvt_seq.seq_done);
     //end
// #10;
   // repeat(10)begin
      fcvt_seq.scenario = 2;
      fcvt_seq.start(env.agent.sequencer);
      //  @(fcvt_seq.seq_done);
   // end
  
     `uvm_info(get_type_name(),$sformatf("random sd scenario 2 is completed"),UVM_MEDIUM)


     `uvm_info(get_full_name(), $sformatf("Inside therandom sd test done"), UVM_MEDIUM)
      #1000;
     phase.drop_objection(this);
    // uvm_test_done.set_drain_time(this,1000);
  endtask

endclass

