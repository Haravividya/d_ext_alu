class random_instruction_data_test extends d_ext_alu_base_test;

  // Factory registration
  `uvm_component_utils(random_instruction_data_test)
   random_instruction_data_seq riseq;


  // Constructor
  function new(string name = "random_instruction_data_test", uvm_component parent = null);
    super.new(name, parent);
    riseq = random_instruction_data_seq::type_id::create("riseq");
  endfunction

  // Build Phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  // Run Phase
  task run_phase(uvm_phase phase);
     phase.raise_objection(this);
     `uvm_info(get_full_name(), $sformatf("Inside the  random instruction data test"), UVM_MEDIUM)
     
     begin
       riseq.scenario = 1;
       riseq.start(env.agent.sequencer);
     end
  
     `uvm_info(get_type_name(),$sformatf("random  scenario 2 is completed"),UVM_MEDIUM)
     `uvm_info(get_full_name(), $sformatf("Inside the random instruction data test done"), UVM_MEDIUM)
      #1000;
     phase.drop_objection(this);
  endtask

endclass

