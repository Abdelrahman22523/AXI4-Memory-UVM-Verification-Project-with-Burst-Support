`ifndef AXI4_SEQUENCE_SVH
`define AXI4_SEQUENCE_SVH

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "axi4_transaction.sv"
`include "common_cfg.sv"
`include "axi4_sequencer.sv"

class axi4_sequence extends uvm_sequence #(axi4_transaction);

	`uvm_object_utils(axi4_sequence)

	int transaction_count = 0;

	common_cfg m_cfg;

	function new(string name = "axi4_sequence");
	begin

		super.new(name);
		`uvm_info("axi4_sequence", "INSIDE NEW SEQUENCE CLASS", UVM_LOW)
	end
	endfunction  


	task body();

	axi4_transaction req;
	axi4_sequencer sqr; 
        
        $cast(sqr, m_sequencer); 
        m_cfg = sqr.m_cfg;      

	repeat(500000) 
	begin
		transaction_count++;  // Increment counter
		req = axi4_transaction::type_id::create("req");
		req.all_data.delete();  

		start_item(req);
		assert(req.randomize())
		   else `uvm_fatal(get_type_name(), "Transaction randomization failed")

		// Debug: Print what operation was generated
		/*`uvm_info(get_type_name(),$sformatf("Transaction %0d: OPERATION = %0d (%s)", 
		transaction_count, 
		req.OPERATION,
		(req.OPERATION == 2'd1) ? "WRITE" : "READ"), 
		UVM_LOW)*/
		
		finish_item(req);

		@ (m_cfg.monitor_sent_e);

		//`uvm_info(get_type_name(), $sformatf("Transaction %0d completed", transaction_count), UVM_LOW)
	end

	`uvm_info(get_type_name(), $sformatf("Sequence completed - Generated %0d transactions", transaction_count), UVM_LOW)

	endtask 


endclass

`endif

