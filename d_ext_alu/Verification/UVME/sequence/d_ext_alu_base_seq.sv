class d_ext_alu_base_seq extends uvm_sequence#(d_ext_alu_tx);

  //factory registration
 `uvm_object_utils(d_ext_alu_base_seq)

  //creating sequence item handle
  d_ext_alu_tx tx;


  //constructor
  function new(string name="d_ext_alu_base_seq");
   super.new(name);
  endfunction

  //task body
  task body();
    start_item(tx);

   finish_item(tx);
  endtask

endclass
