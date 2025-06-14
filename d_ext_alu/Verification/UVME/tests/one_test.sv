class one_test extends d_ext_alu_base_test;

  // Factory registration
  `uvm_component_utils(one_test)
   one_seq oseq;


  // Constructor
  function new(string name = "one_test", uvm_component parent = null);
    super.new(name, parent);
    oseq = one_seq::type_id::create("oseq");
   // oseq1 = one_seq::type_id::create("oseq1");
  endfunction

  // Build Phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  // Run Phase
  task run_phase(uvm_phase phase);
     phase.raise_objection(this);
     `uvm_info(get_full_name(), $sformatf("Inside the one signals test"), UVM_MEDIUM)
     oseq.scenario = 1;
     oseq.start(env.agent.sequencer);
      


     `uvm_info(get_full_name(), $sformatf("Inside the one signals test done"), UVM_MEDIUM)
     #200;
     phase.drop_objection(this);
  endtask

endclass

