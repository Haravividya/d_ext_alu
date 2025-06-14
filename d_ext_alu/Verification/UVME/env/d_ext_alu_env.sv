class d_ext_alu_env extends uvm_env;	
	d_ext_alu_agent agent;
  	d_ext_alu_sbd   sbd;
	d_ext_alu_cov   cov;

//factory registration
    `uvm_component_utils(d_ext_alu_env)

//new constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction 

//build phase
	function void build_phase(uvm_phase phase);
    		super.build_phase(phase);
		    agent = 	d_ext_alu_agent::type_id::create("agent", this);
    	    sbd    =    d_ext_alu_sbd::type_id::create("sbd", this);
		    cov    =   	d_ext_alu_cov::type_id::create("cov",this);
    endfunction 

//connect_phase - connecting monitor and scoreboard port
  
  	function void connect_phase(uvm_phase phase);
    	   	agent.monitor.analysis_port.connect(sbd.item_collected_export.analysis_export);

    	   	agent.monitor.analysis_port.connect(sbd.expected_transaction_fifo.analysis_export);
            agent.monitor.analysis_port.connect(cov.analysis_export); 
  	endfunction 	
endclass
