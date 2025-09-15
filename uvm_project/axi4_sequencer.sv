`ifndef AXI4_SEQUENCER_SVH
`define AXI4_SEQUENCER_SVH

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "axi4_transaction.sv"
`include "common_cfg.sv"


class axi4_sequencer extends uvm_sequencer #(axi4_transaction);

	`uvm_component_utils(axi4_sequencer)

	common_cfg m_cfg;

	function new (string name = "axi4_sequencer", uvm_component parent = null);
		super.new(name,parent);
		`uvm_info("axi4_drive", "INSIDE NEW DRIVER CLASS", UVM_LOW)
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		if(!uvm_config_db#(common_cfg)::get(this, "*", "m_cfg", m_cfg))
	        `uvm_fatal(get_full_name(), "Failed to get common_cfg from config DB")
	    else
	        $display("common_cfg retrieved successfully in sequencer");

		`uvm_info(get_type_name(), "axi4 sequencer build phase", UVM_LOW)
	endfunction

endclass 
`endif