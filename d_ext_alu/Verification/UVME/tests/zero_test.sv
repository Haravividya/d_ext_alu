class zero_test extends d_ext_alu_base_test;

  // Factory registration
  `uvm_component_utils(zero_test)
   zero_seq zseq;


  // Constructor
  function new(string name = "zero_test", uvm_component parent = null);
    super.new(name, parent);
    zseq = zero_seq::type_id::create("zseq");
   // zseq1 = zero_seq::type_id::create("zseq1");
  endfunction

  // Build Phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  // Run Phase
  task run_phase(uvm_phase phase);
     phase.raise_objection(this);
     `uvm_info(get_full_name(), $sformatf("Inside the zero signals test"), UVM_MEDIUM)
    // begin
     zseq.scenario = 1;
     zseq.start(env.agent.sequencer);
         // @(zseq.seq_done);
     //end
// #10;
   // repeat(10)begin
      zseq.scenario = 2;
      zseq.start(env.agent.sequencer);
      //  @(zseq.seq_done);
   // end
  
     `uvm_info(get_type_name(),$sformatf("random zero scenario 2 is completed"),UVM_MEDIUM)


     `uvm_info(get_full_name(), $sformatf("Inside the zero signals test done"), UVM_MEDIUM)
     #200;
     phase.drop_objection(this);
  endtask

endclass

