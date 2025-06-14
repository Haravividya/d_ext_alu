class FMIN_D_Test extends d_ext_alu_base_test;

  // Factory registration
     `uvm_component_utils(FMIN_D_Test)
      FMIN_D_seq fmin_seq;


  // Constructor
  function new(string name = "FMIN_D_Test", uvm_component parent = null);
      super.new(name, parent);
      fmin_seq = FMIN_D_seq::type_id::create("fmin_seq");
  endfunction

  // Build Phase
  function void build_phase(uvm_phase phase);
      super.build_phase(phase);
  endfunction

  // Run Phase
  task run_phase(uvm_phase phase);
      phase.raise_objection(this);
     `uvm_info(get_full_name(), $sformatf("Inside the fmin test"), UVM_MEDIUM)
    // begin
      //fmin_seq.scenario = 1;
      //fmin_seq.start(env.agent.sequencer);
         // @(fmul_seq.seq_done);
     //end
// #10;
   // repeat(10)begin
      fmin_seq.scenario = 2;
      fmin_seq.start(env.agent.sequencer);
      //  @(fmul_seq.seq_done);
   // end
  
     `uvm_info(get_type_name(),$sformatf("random fmin scenario 2 is completed"),UVM_MEDIUM)
     `uvm_info(get_full_name(), $sformatf("Inside the    fmin test done"), UVM_MEDIUM)
      #200;
      phase.drop_objection(this);
  endtask

endclass

