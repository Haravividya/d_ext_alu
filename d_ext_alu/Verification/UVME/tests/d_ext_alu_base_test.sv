class d_ext_alu_base_test extends uvm_test;
    d_ext_alu_env env;
    d_ext_alu_base_seq base_seq;

     // factory registration 
   int  error_count;
   int  fatal_count;
   string test_name;
//factory registration
    `uvm_component_utils(d_ext_alu_base_test)
	
//new construct
	function new(string name="d_ext_alu_base_test",uvm_component parent=null);
		super.new(name,parent);
	endfunction

//build phase
	function void build_phase(uvm_phase phase);
        super.build_phase(phase);
               
		env=d_ext_alu_env::type_id::create("env",this);
    	base_seq=d_ext_alu_base_seq::type_id::create("base_seq",this);
    endfunction

//end of elaboration phase
	function void end_of_elaboration_phase(uvm_phase phase);
		uvm_top.print_topology();
    endfunction

task run_phase(uvm_phase phase);
    phase.raise_objection(this);
      #1000;
   `uvm_info(get_name(),$sformatf("inside the base test"),UVM_MEDIUM)
    phase.drop_objection(this);
  endtask
 function void print_test_status();
        uvm_report_server server;
        
        // Get the report server instance
        server = uvm_report_server::get_server();
        
        // Get error and fatal counts
        error_count = server.get_severity_count(UVM_ERROR);
        fatal_count = server.get_severity_count(UVM_FATAL);
        
        // Get test name
        test_name = get_type_name();
        
        // Print test results
        $display("============================================================");
        if(!error_count && !fatal_count) begin
            $display("[%s] STATUS    : PASSED", test_name);
        end
        else begin
            $display("[%s] STATUS    : FAILED", test_name);
            $display("ERRORS:%0d, FATAL:%0d", error_count, fatal_count);
        end
        $display("============================================================");
    endfunction

    //------------------------------------------------------
    // Final Phase: Print test status - GUARANTEED TO EXECUTE
    //------------------------------------------------------
    virtual function void final_phase(uvm_phase phase);
        super.final_phase(phase);
        print_test_status();
    endfunction
    endclass 

