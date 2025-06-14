


class d_ext_alu_sbd extends uvm_scoreboard;
 `uvm_component_utils(d_ext_alu_sbd)

  // Transaction queues
  uvm_tlm_analysis_fifo #(d_ext_alu_tx) item_collected_export;
  uvm_tlm_analysis_fifo #(d_ext_alu_tx) expected_transaction_fifo;

  // Constructor
  function new(string name, uvm_component parent);
         super.new(name, parent);
         item_collected_export = new("item_collected_export", this);
         expected_transaction_fifo = new("expected_transaction_fifo", this);
  endfunction

  // Checker: Compare actual and expected results
  virtual task run_phase(uvm_phase phase);
    d_ext_alu_tx tx, expected_tx;

    super.run_phase(phase);

    forever begin
             // Get transaction from monitor
             item_collected_export.get(tx);

             // Calculate expected results
             calculate_expected_result(tx);

             // Get expected transaction
             expected_transaction_fifo.get(expected_tx);

             // Compare results for all instructions
             if ((tx.result !== expected_tx.result) ||
                 (tx.int_result !== expected_tx.int_result) ||
                 (tx.fs_result !== expected_tx.fs_result)) begin
               `uvm_error("SCOREBOARD", $sformatf("Mismatch: Expected {result=0x%0h, int=0x%0h, fs=0x%0h}, Got {result=0x%0h, int=0x%0h, fs=0x%0h}",
                           expected_tx.result, expected_tx.int_result, expected_tx.fs_result,
                           tx.result, tx.int_result, tx.fs_result))
             end else begin
               `uvm_info("SCOREBOARD", $sformatf("Match: Instruction=%d, Result=0x%0h, Int=0x%0h, FS=0x%0h", tx.alu_op, tx.result, tx.int_result, tx.fs_result), UVM_LOW)
             end
    end
  endtask

  // Enhanced reference model with edge-case handling
  virtual function void calculate_expected_result(d_ext_alu_tx tx);
            d_ext_alu_tx expected_tx = d_ext_alu_tx::type_id::create("expected_tx");
            expected_tx.copy(tx);

    case (tx.alu_op)
             5'b00000: expected_tx.result = $signed(tx.rs1) + $signed(tx.rs2);  // FADD.D
             5'b00001: expected_tx.result = $signed(tx.rs1) - $signed(tx.rs2);  // FSUB.D
             5'b00010: expected_tx.result = $signed(tx.rs1) * $signed(tx.rs2);  // FMUL.D
             5'b00011: expected_tx.result = (tx.rs2 != 0) ? ($signed(tx.rs1) / $signed(tx.rs2)) : 64'h0; // FDIV.D (handles div by zero)
             5'b00100: expected_tx.result = $sqrt(tx.rs1);   // FSQRT.D (simplified approximation)
             5'b00101: expected_tx.result = $signed(tx.rs1) * $signed(tx.rs2) + $signed(tx.rs3);  // FMADD.D
             5'b00110: expected_tx.result = $signed(tx.rs1) * $signed(tx.rs2) - $signed(tx.rs3);  // FMSUB.D
             5'b00111: expected_tx.result = -($signed(tx.rs1) * $signed(tx.rs2)) + $signed(tx.rs3); // FNMADD.D
             5'b01000: expected_tx.result = -($signed(tx.rs1) * $signed(tx.rs2)) - $signed(tx.rs3); // FNMSUB.D
             5'b01001: expected_tx.result = {tx.rs2[63], tx.rs1[62:0]}; // FSGNJ.D
             5'b01010: expected_tx.result = {~tx.rs2[63], tx.rs1[62:0]}; // FSGNJN.D
             5'b01011: expected_tx.result = {tx.rs1[63] ^ tx.rs2[63], tx.rs1[62:0]}; // FSGNJX.D
             5'b01100: expected_tx.result = (tx.rs1 < tx.rs2) ? tx.rs1 : tx.rs2; // FMIN.D
             5'b01101: expected_tx.result = (tx.rs1 > tx.rs2) ? tx.rs1 : tx.rs2; // FMAX.D
             5'b01110: expected_tx.int_result = (tx.rs1 == tx.rs2) ? 64'h1 : 64'h0; // FEQ.D
             5'b01111: expected_tx.int_result = (tx.rs1 < tx.rs2) ? 64'h1 : 64'h0;  // FLT.D
             5'b10000: expected_tx.int_result = (tx.rs1 <= tx.rs2) ? 64'h1 : 64'h0; // FLE.D
             5'b10001: expected_tx.fs_result = tx.rs1[31:0];       // FCVT.S.D
             5'b10010: expected_tx.result = {32'b0, tx.fs_rs1};    // FCVT.D.S
             5'b10011: expected_tx.result = tx.int_rs1;            // FCVT.D.W
             5'b10100: expected_tx.result = tx.int_rs1;            // FCVT.D.WU
             5'b10101: expected_tx.int_result = {{32{tx.rs1[31]}}, tx.rs1[31:0]}; // FCVT.W.D (Sign extend)
             5'b10110: expected_tx.int_result = {32'b0, tx.rs1[31:0]}; // FCVT.WU.D
             5'b10111: expected_tx.result = tx.int_rs1;            // FCVT.D.L
             5'b11000: expected_tx.result = tx.int_rs1;            // FCVT.D.LU
             5'b11001: expected_tx.int_result = tx.rs1;            // FCVT.L.D
             5'b11010: expected_tx.int_result = tx.rs1;            // FCVT.LU.D
             5'b11011: expected_tx.int_result = 64'h1;             // FCLASS.D (dummy value for now)
             5'b11100: expected_tx.int_result = tx.rs1;            // FMV.X.D
             5'b11101: expected_tx.result = tx.int_rs1;            // FMV.D.X
             default: `uvm_error("SCOREBOARD", $sformatf("Unknown operation 0x%0h", tx.alu_op))
    endcase

            expected_transaction_fifo.write(expected_tx);
  endfunction

endclass

