


class d_ext_alu_sequencer extends uvm_sequencer#(d_ext_alu_tx);
 
    //factory registration
    `uvm_component_utils(d_ext_alu_sequencer)

//new constructor
  	function new(string name="d_ext_alu_sequencer", uvm_component parent);
    		super.new(name,parent);
  	endfunction


endclass
