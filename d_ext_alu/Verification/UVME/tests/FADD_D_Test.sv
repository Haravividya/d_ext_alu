class FADD_D_Test extends d_ext_alu_base_test;

  // Factory registration
  `uvm_component_utils(FADD_D_Test)
   FADD_D_seq fadd_seq;


  // Constructor
  function new(string name = "FADD_D_Test", uvm_component parent = null);
    super.new(name, parent);
    fadd_seq = FADD_D_seq::type_id::create("fadd_seq");
   // fadd_seq1 = FADD_D_seq::type_id::create("fadd_seq1");
  endfunction

  // Build Phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  // Run Phase
  task run_phase(uvm_phase phase);
     phase.raise_objection(this);
     `uvm_info(get_full_name(), $sformatf("Inside the fadd test"), UVM_MEDIUM)
    // begin
     //fadd_seq.scenario = 1;
      //fadd_seq.start(env.agent.sequencer);
         // @(fadd_seq.seq_done);
     //end
// #10;
   // repeat(10)begin
      fadd_seq.scenario = 2;
      fadd_seq.start(env.agent.sequencer);
      //  @(fadd_seq.seq_done);
   // end
  
     `uvm_info(get_type_name(),$sformatf("random add scenario 2 is completed"),UVM_MEDIUM)


     `uvm_info(get_full_name(), $sformatf("Inside the fadd test done"), UVM_MEDIUM)
      #1000;
     phase.drop_objection(this);
    // uvm_test_done.set_drain_time(this,1000);
  endtask

endclass

