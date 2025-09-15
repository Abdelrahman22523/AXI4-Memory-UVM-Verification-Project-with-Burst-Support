`ifndef AXI4_AGENT_SVH
`define AXI4_AGENT_SVH

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "axi4_sequencer.sv"
`include "axi4_driver.sv"
`include "axi4_monitor.sv"


class axi4_agent extends uvm_agent;

	axi4_sequencer sqr;
	axi4_driver    drv;
	axi4_monitor   mon;

	uvm_active_passive_enum is_active = UVM_ACTIVE;


	`uvm_component_utils(axi4_agent)

	function  new(string name = "axi4_agent", uvm_component parent = null);
		super.new(name,parent);
		`uvm_info("axi4_agent", "INSIDE NEW AGENT CLASS", UVM_LOW)
	endfunction


	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		`uvm_info(get_type_name(), "axi4 agent build phase", UVM_LOW)

		if(!uvm_config_db #(uvm_active_passive_enum)::get(null, "uvm_test_top.env.agt", "is_active", is_active))
			`uvm_fatal(get_type_name(), "Failed to get agent enum value...")
		else
			$display("configuration DB done");

		`uvm_info(get_type_name(), $sformatf("AGENT TYPE IS %p", is_active), UVM_LOW)


		mon = axi4_monitor::type_id::create("mon", this);

		if (is_active == UVM_ACTIVE) 
		begin
			sqr = axi4_sequencer::type_id::create("sqr", this);
			drv = axi4_driver::type_id::create("drv", this);
		end
	endfunction


	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		if (is_active == UVM_ACTIVE) 
		begin
			drv.seq_item_port.connect(sqr.seq_item_export);
			`uvm_info("my_axi4_agent", "INSIDE CONNECT PHASE", UVM_LOW)
		end
	endfunction 

endclass 

`endif