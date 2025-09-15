`timescale 1ns/1ps
`include "axi4_if.sv"
`include "axi4_pkg.sv"
`include "axi4_assert.sv"
`include "uvm_macros.svh"

import uvm_pkg::*;
import axi4_pkg::*;

module top ();
	
	axi4_if axi4_vif();
    axi4_assert check (axi4_vif);

	// DUT instantiation with proper port connections
    axi4 #(
        .DATA_WIDTH(32),
        .ADDR_WIDTH(16), 
        .MEMORY_DEPTH(1024)
    ) DUT (
        .ACLK   (axi4_vif.ACLK),
        .ARESETn(axi4_vif.ARESETn),
        .AWADDR (axi4_vif.AWADDR),
        .AWLEN  (axi4_vif.AWLEN),
        .AWSIZE (axi4_vif.AWSIZE),
        .AWVALID(axi4_vif.AWVALID),
        .AWREADY(axi4_vif.AWREADY),
        .WDATA  (axi4_vif.WDATA),
        .WVALID (axi4_vif.WVALID),
        .WLAST  (axi4_vif.WLAST),
        .WREADY (axi4_vif.WREADY),
        .BRESP  (axi4_vif.BRESP),
        .BVALID (axi4_vif.BVALID),
        .BREADY (axi4_vif.BREADY),
        .ARADDR (axi4_vif.ARADDR),
        .ARLEN  (axi4_vif.ARLEN),
        .ARSIZE (axi4_vif.ARSIZE),
        .ARVALID(axi4_vif.ARVALID),
        .ARREADY(axi4_vif.ARREADY),
        .RDATA  (axi4_vif.RDATA),
        .RRESP  (axi4_vif.RRESP),
        .RVALID (axi4_vif.RVALID),
        .RLAST  (axi4_vif.RLAST),
        .RREADY (axi4_vif.RREADY)
    );

	initial
	begin
		axi4_vif.ACLK = 0;
		forever 
		begin
			#5ns axi4_vif.ACLK = ~axi4_vif.ACLK;
		end
	end


	initial
	begin
		uvm_config_db#(uvm_active_passive_enum)::set(null, "uvm_test_top.env.agt","is_active", UVM_ACTIVE);
		/*uvm_config_db#(virtual axi4_if)::set(null, "uvm_test_top.env.agt.*", "axi4_intf", axi4_vif);
		uvm_config_db#(virtual axi4_if)::set(null, "uvm_test_top.env.scb", "axi4_intf", axi4_vif);
        uvm_config_db#(virtual axi4_if)::set(null, "uvm_test_top.env.agt.sqr.*", "axi4_intf", axi4_vif);*/
        uvm_config_db#(virtual axi4_if)::set(null, "*", "axi4_intf", axi4_vif);

		run_test("axi4_test");
	end

endmodule 