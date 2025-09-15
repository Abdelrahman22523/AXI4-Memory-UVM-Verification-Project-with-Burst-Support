`ifndef AXI4_MONITOR_SVH
`define AXI4_MONITOR_SVH

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "common_cfg.sv"
`include "axi4_transaction.sv"

class axi4_monitor extends uvm_monitor;

	`uvm_component_utils(axi4_monitor)

	static int monitor_transaction_count = 0;

	virtual axi4_if axi4_vif;
	common_cfg m_cfg;

	uvm_analysis_port #(axi4_transaction) ap;

	function new (string name = "axi4_monitor", uvm_component parent = null);
		super.new(name,parent);
		ap = new("ap", this);
		`uvm_info("axi4_monitor", "INSIDE NEW MONITOR CLASS", UVM_LOW)
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		`uvm_info(get_type_name(), "axi4 monitor build phase", UVM_LOW)

		if(!uvm_config_db#(virtual axi4_if)::get(this, "*", "axi4_intf", axi4_vif ))
			`uvm_fatal(get_full_name(), "Faild to get axi4_vifface")
		else
			$display("configuration DB dond");

		if(!uvm_config_db#(common_cfg)::get(this, "*", "m_cfg", m_cfg))
			`uvm_fatal(get_full_name(), "Failed to get common_cfg from config DB")
		else
			$display("common_cfg retrieved successfully in monitor");
	endfunction

	task run_phase(uvm_phase phase);
		axi4_transaction tr;

		//`uvm_info(get_type_name(), "ENTERED RUN PHASE", UVM_LOW)

		forever
		begin
			// Wait for trulus to be sent
			wait(m_cfg.stimulus_sent_e.triggered);

			/*monitor_transaction_count++;
			`uvm_info(get_type_name(), $sformatf("Monitor processing transaction %0d", monitor_transaction_count), UVM_LOW)*/

			// Get transaction information from driver via config
			tr = m_cfg.current_tr;

			tr.actual_queue.delete();
			tr.actual_response = 0;

			if (tr.OPERATION == 2'd2) 
	    	begin

			    // Start with RREADY high, then apply delay by temporarily deasserting
			    axi4_vif.RREADY = 1'b1;

			    axi4_vif.RREADY = 1'b1;

			    for (int i = 0; i <= tr.LEN; i++) 
			    begin
			    	tr.actual_response = 2'b00;

				    // Generate random delay for each read beat
				    assert(tr.randomize(r_ready_delay)) 
				    	else $fatal("r_ready_delay randomization failed");

				    // Apply r_ready_delay for each read beat
				    if (tr.r_ready_delay > 0) 
				    begin
				      axi4_vif.RREADY = 1'b0;
				      repeat (tr.r_ready_delay) @(negedge axi4_vif.ACLK);
				      axi4_vif.RREADY = 1'b1;
				    end

	
				    if (i == tr.LEN && !axi4_vif.RLAST) 
				    begin
		                `uvm_error(get_type_name(), "RLAST not asserted on final beat")
		            end

				    // Wait for valid read data
				    repeat (20) @(negedge axi4_vif.ACLK)
				      if (axi4_vif.RVALID) break;

				    tr.actual_queue.push_back(axi4_vif.RDATA);
				    tr.actual_response = axi4_vif.RRESP;

				end
				axi4_vif.RREADY = 1'b0;
				//`uvm_info(get_type_name(), "Read operation completed", UVM_MEDIUM)

			end else
			if (tr.OPERATION == 2'd1)
			begin
				// Generate random delay for each read beat
			    assert(tr.randomize(b_ready_delay)) 
			    	else $fatal("b_ready_delay randomization failed");

				tr.actual_response = axi4_vif.BRESP;
		        axi4_vif.WVALID = 1'b0;
		        axi4_vif.WLAST  = 0;

		        // Apply delay before accepting write response
		        repeat (tr.b_ready_delay) @(negedge axi4_vif.ACLK);
		        axi4_vif.BREADY = 1'b1;

		        // Wait for write response
		        repeat (20) @(negedge axi4_vif.ACLK)
		          if (axi4_vif.BVALID) break;

		        axi4_vif.BREADY = 0;
		        //`uvm_info(get_type_name(), "Write operation completed", UVM_MEDIUM)
			end
			
			// Send transaction to scoreboard and coverage via analysis port
			ap.write(tr);
			-> m_cfg.monitor_sent_e;
		end
	endtask 




endclass 
`endif