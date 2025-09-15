`ifndef COMMON_CFG_SVH
`define COMMON_CFG_SVH


`include "uvm_macros.svh"
import uvm_pkg::*;

`include "axi4_transaction.sv"



class common_cfg extends uvm_object;

	`uvm_object_utils(common_cfg)

	event stimulus_sent_e;
	event monitor_sent_e;
	
	axi4_transaction current_tr;

	function new(string name = "common_cfg");
		super.new(name);
		`uvm_info("common_cfg", "INSIDE NEW COMMON_CFG CLASS", UVM_LOW)
	endfunction 

endclass
`endif