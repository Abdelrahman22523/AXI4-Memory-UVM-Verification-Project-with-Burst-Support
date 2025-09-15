`ifndef AXI4_TEST_SVH
`define AXI4_TEST_SVH 

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "axi4_env.sv"
`include "axi4_sequence.sv"
`include "debug_sequence.sv"
`include "common_cfg.sv"

`include "axi4_transaction.sv"

class axi4_test extends uvm_test;

	axi4_env       env;
	axi4_sequence  seq;
	debug_sequence debug;
	common_cfg     m_cfg;

	`uvm_component_utils(axi4_test)

	function new(string name = "axi4_test", uvm_component parent = null);
	begin
		super.new(name,parent);
		`uvm_info("axi4_test", "INSIDE NEW TEST CLASS", UVM_LOW)
	end
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		env   = axi4_env::type_id::create("env", this);
		seq   = axi4_sequence::type_id::create("seq", this);
		debug = debug_sequence::type_id::create("debug", this);
		m_cfg = common_cfg::type_id::create("m_cfg");
		`uvm_info(get_type_name(), "axi4 test build phase", UVM_LOW)

		uvm_config_db#(common_cfg)::set(this, "*", "m_cfg", m_cfg);
	endfunction


	function void end_of_elaboration_phase(uvm_phase phase);
		super.end_of_elaboration_phase(phase);
		uvm_top.print_topology();
	endfunction

	task run_phase(uvm_phase phase);
		phase.raise_objection(this);
		`uvm_info(get_type_name(), "Starting AXI4 test sequence", UVM_LOW)
		fork
			begin
				seq.start(env.agt.sqr);
				`uvm_info(get_type_name(), "AXI4 test sequence completed", UVM_LOW)

				debug.start(env.agt.sqr);
				`uvm_info(get_type_name(), "Debug sequence completed", UVM_LOW)
			end	
		join
		
		phase.drop_objection(this);
	endtask 


endclass

`endif