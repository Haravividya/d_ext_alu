class d_ext_alu_monitor extends uvm_monitor;

    `uvm_component_utils(d_ext_alu_monitor)

     virtual d_ext_alu_interface vif;  
     uvm_analysis_port#(d_ext_alu_tx) analysis_port;
    // d_ext_alu_tx tx;

  // Constructor
    function new(string name = "d_ext_alu_monitor", uvm_component parent = null);
         super.new(name, parent);
    endfunction

  // Build phase to configure the interface
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        analysis_port = new("analysis_port", this);

         if (!uvm_config_db#(virtual d_ext_alu_interface)::get(this, "", "d_ext_alu_interface", vif))
        `uvm_fatal("MON_ERR", "Virtual interface not set for monitor")
    endfunction

    task run_phase(uvm_phase phase);
    d_ext_alu_tx tx;


     //tx =  d_ext_alu_tx::type_id::create("tx");

     //forever begin
     for(int i=0;i<60000;i++)begin
     
     tx =  d_ext_alu_tx::type_id::create("tx");
       #1;
        tx.rs1         = vif.rs1;
       `uvm_info("MONITOR", $sformatf("Captured: rs1=%h",tx.rs1), UVM_MEDIUM)
       
        tx.rs2         = vif.rs2;
       `uvm_info("MONITOR", $sformatf("Captured: rs2=%h",tx.rs2), UVM_MEDIUM)
        
        tx.rs3         = vif.rs3;
        `uvm_info("MONITOR", $sformatf("Captured: rs3=%h",tx.rs3), UVM_MEDIUM)
        
        tx.alu_op      = vif.alu_op;
        `uvm_info("MONITOR", $sformatf("Captured: alu_op=%b",tx.alu_op), UVM_MEDIUM)
        
        tx.result      = vif.result;
        `uvm_info("MONITOR", $sformatf("Captured: result=%h",tx.result), UVM_MEDIUM)
       
        tx.fs_rs1      = vif.fs_rs1;
        `uvm_info("MONITOR", $sformatf("Captured: fs_rs1=%h",tx.fs_rs1), UVM_MEDIUM)
       
        tx.int_rs1     = vif.int_rs1;
        `uvm_info("MONITOR", $sformatf("Captured: int_rs1=%h",tx.int_rs1), UVM_MEDIUM)
        
        tx.fs_result   = vif.fs_result;
        `uvm_info("MONITOR", $sformatf("Captured: fs_result=%h",tx.fs_result), UVM_MEDIUM)
        
        tx.int_result  = vif.int_result;
       `uvm_info("MONITOR", $sformatf("Captured: int_result=%h",tx.int_result), UVM_MEDIUM)
        analysis_port.write(tx);
       //#1;
     end    
    endtask
endclass
