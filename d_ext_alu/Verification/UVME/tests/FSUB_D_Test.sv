class FSUB_D_Test extends d_ext_alu_base_test;

  // Factory registration
  `uvm_component_utils(FSUB_D_Test)
   FSUB_D_seq fsub_seq;


  // Constructor
  function new(string name = "FSUB_D_Test", uvm_component parent = null);
    super.new(name, parent);
    fsub_seq = FSUB_D_seq::type_id::create("fsub_seq");
  endfunction

  // Build Phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  // Run Phase
  task run_phase(uvm_phase phase);
      phase.raise_objection(this);
     `uvm_info(get_full_name(), $sformatf("Inside the fsub test"), UVM_MEDIUM)
    // begin
      //fsub_seq.scenario = 1;
      //fsub_seq.start(env.agent.sequencer);
         // @(fsub_seq.seq_done);
     //end
// #10;
   // repeat(10)begin
      fsub_seq.scenario = 2;
      fsub_seq.start(env.agent.sequencer);
      //  @(fsub_seq.seq_done);
   // end
  
     `uvm_info(get_type_name(),$sformatf("random sub scenario 2 is completed"),UVM_MEDIUM)
     `uvm_info(get_full_name(), $sformatf("Inside the fsub test done"), UVM_MEDIUM)
      #200;
      phase.drop_objection(this);
  endtask

endclass

