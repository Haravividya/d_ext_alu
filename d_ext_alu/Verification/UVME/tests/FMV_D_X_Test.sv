class FMV_D_X_Test extends d_ext_alu_base_test;

  // Factory registration
     `uvm_component_utils(FMV_D_X_Test)
      FMV_D_X_seq fmv_d_x_seq;


  // Constructor
  function new(string name = "FMV_D_X_Test", uvm_component parent = null);
      super.new(name, parent);
    fmv_d_x_seq =  FMV_D_X_seq::type_id::create("fmv_d_x_seq");
  endfunction

  // Build Phase
  function void build_phase(uvm_phase phase);
      super.build_phase(phase);
  endfunction

  // Run Phase
  task run_phase(uvm_phase phase);
      phase.raise_objection(this);
     `uvm_info(get_full_name(), $sformatf("Inside the  fmv_d_x test"), UVM_MEDIUM)
    // begin
      //fmv_d_x_seq.scenario = 1;
      //fmv_d_x_seq.start(env.agent.sequencer);
         // @(fmul_seq.seq_done);
     //end
// #10;
   // repeat(10)begin
      fmv_d_x_seq.scenario = 2;
      fmv_d_x_seq.start(env.agent.sequencer);
      //  @(fmul_seq.seq_done);
   // end
  
     `uvm_info(get_type_name(),$sformatf("random fmv_d_x scenario 2 is completed"),UVM_MEDIUM)
     `uvm_info(get_full_name(), $sformatf("Inside the fmv_d_x test done"), UVM_MEDIUM)
      #200;
      phase.drop_objection(this);
  endtask

endclass

