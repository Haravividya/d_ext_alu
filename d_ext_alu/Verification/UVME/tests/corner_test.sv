class corner_test extends d_ext_alu_base_test;

  // Factory registration
  `uvm_component_utils(corner_test)
   corner_seq cseq;


  // Constructor
  function new(string name = "corner_test", uvm_component parent = null);
    super.new(name, parent);
    cseq = corner_seq::type_id::create("cseq");
   // cseq1 = corner_seq::type_id::create("cseq1");
  endfunction

  // Build Phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  // Run Phase
  task run_phase(uvm_phase phase);
     phase.raise_objection(this);
     `uvm_info(get_full_name(), $sformatf("Inside the corner signals test"), UVM_MEDIUM)
     cseq.scenario = 1;
     cseq.start(env.agent.sequencer);
      


     `uvm_info(get_full_name(), $sformatf("Inside thecorner signals test done"), UVM_MEDIUM)
     #200;
     phase.drop_objection(this);
  endtask

endclass

