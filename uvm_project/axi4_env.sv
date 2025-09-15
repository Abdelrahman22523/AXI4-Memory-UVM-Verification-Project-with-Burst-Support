`ifndef AXI4_ENV_SVH
`define AXI4_ENV_SVH

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "axi4_agent.sv"
`include "axi4_coverage.sv"
`include "axi4_scoreboard.sv"
`include "common_cfg.sv"

class axi4_env extends uvm_env;

	common_cfg      m_cfg;

	axi4_agent      agt;
	axi4_coverage   cov;
	axi4_scoreboard scb;

	`uvm_component_utils(axi4_env)

	function new(string name = "axi4_env", uvm_component parent = null);
		super.new(name,parent);
		`uvm_info("axi4_env", "INSIDE NEW ENV CLASS", UVM_LOW)
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		agt   = axi4_agent::type_id::create("agt", this);
		cov   = axi4_coverage::type_id::create("cov", this);
		scb = axi4_scoreboard::type_id::create("scb", this);
		`uvm_info(get_type_name(), "axi4 enviroment build phase", UVM_LOW)

		if(!uvm_config_db#(common_cfg)::get(this, "", "m_cfg", m_cfg)) begin
            `uvm_fatal(get_full_name(), "Failed to get common_cfg from config DB")
        end else 
        begin
            $display("common_cfg retrieved successfully in environment");
        end

        uvm_config_db#(common_cfg)::set(this, "*", "m_cfg", m_cfg);
	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);

		// Connect config to components
		agt.drv.m_cfg = m_cfg;
		agt.mon.m_cfg = m_cfg;

		// Connect analysis ports
		agt.drv.ap.connect(cov.analysis_export);
		agt.mon.ap.connect(scb.analysis_export);
		agt.mon.ap.connect(cov.analysis_export);

		`uvm_info(get_type_name(), "axi4_env connect phase", UVM_LOW)
	endfunction

endclass 
`endif