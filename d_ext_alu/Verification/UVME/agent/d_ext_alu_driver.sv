class d_ext_alu_driver extends uvm_driver #(d_ext_alu_tx);
    `uvm_component_utils(d_ext_alu_driver)

  // Interface handle
    virtual  d_ext_alu_interface vif;
    //time timeout;
  // Constructor
    function new(string name = "d_ext_alu_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

  // Build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
       // timeout = 99000000000000;
        if (!uvm_config_db #(virtual d_ext_alu_interface)::get(this, "", "d_ext_alu_interface", vif)) begin
          `uvm_fatal("NOVIF", "Virtual interface not set for driver")
        end
        else begin
          `uvm_info("TEST", "Virtual interface successfully assigned", UVM_MEDIUM)
        end
    endfunction

  // Run phase
    task run_phase(uvm_phase phase);
         d_ext_alu_tx tx;
                 vif.rs1     = 0;
                 vif.rs2     =0;
                 vif.rs3     =0;
                 vif.fs_rs1  =0;
                 vif.int_rs1 =0; 
                 vif.alu_op  =0;

         if (vif == null) begin
            `uvm_fatal("DRV", "Virtual interface is NULL!")
        end

         forever begin
             seq_item_port.get_next_item(tx);
                 vif.rs1     = tx.rs1;
                 vif.rs2     = tx.rs2;
                 vif.rs3     = tx.rs3;
                 vif.fs_rs1  = tx.fs_rs1;
                 vif.int_rs1 = tx.int_rs1;
                 vif.alu_op  = tx.alu_op;
                 #1;
             seq_item_port.item_done();
         end      
    endtask
endclass
