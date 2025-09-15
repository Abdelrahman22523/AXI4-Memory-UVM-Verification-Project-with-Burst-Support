package axi4_pkg;
	import uvm_pkg::*;
	`include "uvm_macros.svh"

	`include "axi4_transaction.sv"
    `include "common_cfg.sv"
    `include "axi4_sequencer.sv"
    `include "axi4_sequence.sv"
    `include "axi4_driver.sv"
    `include "axi4_monitor.sv"
    `include "axi4_agent.sv"
    `include "axi4_coverage.sv"
    `include "axi4_scoreboard.sv"
    `include "axi4_env.sv"
    `include "axi4_test.sv"
endpackage