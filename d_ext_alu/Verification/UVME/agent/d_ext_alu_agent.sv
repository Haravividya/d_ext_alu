
class d_ext_alu_agent extends uvm_agent;

//declaring agent components
    d_ext_alu_driver    driver;
    d_ext_alu_sequencer sequencer;
    d_ext_alu_monitor   monitor;

// factory registration
    `uvm_component_utils(d_ext_alu_agent)

// new constructor
  	function new (string name="d_ext_alu_agent", uvm_component parent);
            super.new(name, parent);
  	endfunction 

// build_phase
  	function void build_phase(uvm_phase phase);
    		super.build_phase(phase);
      		driver    =  d_ext_alu_driver::type_id::create("driver", this);
      		sequencer =  d_ext_alu_sequencer::type_id::create("sequencer", this);
           	monitor   =  d_ext_alu_monitor::type_id::create("monitor", this);
    endfunction 


//connect phase
    function void connect_phase(uvm_phase phase);
            driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction

endclass
