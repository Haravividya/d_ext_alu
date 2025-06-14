class random_test extends d_ext_alu_base_test;

  // Factory registration
  `uvm_component_utils(random_test)
   random_seq rseq;


  // Constructor
  function new(string name = "random_test", uvm_component parent = null);
    super.new(name, parent);
    rseq = random_seq::type_id::create("rseq");
  endfunction

  // Build Phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  // Run Phase
  task run_phase(uvm_phase phase);
     phase.raise_objection(this);
     `uvm_info(get_full_name(), $sformatf("Inside the  random test"), UVM_MEDIUM)
     
     begin
       rseq.scenario = 1;
       rseq.start(env.agent.sequencer);
     end
  
     `uvm_info(get_type_name(),$sformatf("random  scenario 2 is completed"),UVM_MEDIUM)
     `uvm_info(get_full_name(), $sformatf("Inside the random test done"), UVM_MEDIUM)
      #1000;
     phase.drop_objection(this);
  endtask

endclass

