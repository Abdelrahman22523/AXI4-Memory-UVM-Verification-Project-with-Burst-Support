`ifndef AXI4_SCOREBOARD_SVH
`define AXI4_SCOREBOARD_SVH

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "common_cfg.sv"
`include "axi4_transaction.sv"

class axi4_scoreboard extends uvm_scoreboard;

	`uvm_component_utils(axi4_scoreboard)

	uvm_analysis_export #(axi4_transaction) analysis_export;
	uvm_tlm_analysis_fifo #(axi4_transaction) fifo;

	logic [31:0] golden_mem [0:1023];
    logic [31:0] expected_queue[$];
	logic [1 :0] expected_response;
	logic [31:0] faild_cases[$];

    int cases, pass, fail;  
    real cov;

	virtual axi4_if axi4_vif;
	common_cfg m_cfg;


	function new (string name = "axi4_scoreboard", uvm_component parent);
		super.new(name,parent);
		cases = 0;
	    pass  = 0;
	    fail  = 0;
	    cov  = 0;

		analysis_export = new("analysis_export", this);
		fifo = new("fifo", this);

		// Initialize golden memory
		for (int i = 0; i < 1024; i++) begin
			golden_mem[i] = 32'h0;
		end

		`uvm_info("axi4_scoreboard", "INSIDE NEW SCOREBOARD CLASS", UVM_LOW)
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		`uvm_info(get_type_name(), "axi4 scoreboard build phase", UVM_LOW)
		if(!uvm_config_db #(virtual axi4_if)::get(this, "", "axi4_intf", axi4_vif))  
			`uvm_fatal(get_type_name(), "Failed to get interface")

		if(!uvm_config_db#(common_cfg)::get(this, "*", "m_cfg", m_cfg))
			`uvm_fatal(get_full_name(), "Failed to get common_cfg from config DB")
		else
			$display("common_cfg retrieved successfully in monitor");
	endfunction

	function void connect_phase(uvm_phase phase);
		analysis_export.connect(fifo.analysis_export);
	endfunction

	task run_phase(uvm_phase phase);
		axi4_transaction tr;

		

		forever 
		begin
			wait(m_cfg.monitor_sent_e.triggered);

			fifo.get(tr);
			cases++;

			// Debug: Print every transaction received
        	/*`uvm_info(get_type_name(), 
                $sformatf("Scoreboard received transaction %0d: OPERATION = %0d (%s)", 
                cases, 
                tr.OPERATION,
                (tr.OPERATION == 2'd1) ? "WRITE" : "READ"),UVM_LOW)*/

			expected_queue.delete();
			expected_response = 0;

			// Golden model
			if (((tr.ADDR >> tr.SIZE) + (tr.LEN)) >= 1024) 
		    begin
		        expected_response = 2'b10;
		    end else
		    begin
			    expected_response = 2'b00;
			    if (tr.OPERATION == 2'd1) 
			    begin
			    	// Write operation - update golden memory
			    	for (int i = 0; i <= tr.LEN; i++) 
			    	begin
			    		golden_mem[(tr.ADDR >> 2) + i] = tr.all_data[i];  
			    	end
			    end else if (tr.OPERATION == 2'd2) 
			    begin
			    	// Read operation - get expected data from golden memory
			        for (int i = 0; i <= tr.LEN; i++) 
			        begin
			        	expected_queue.push_back(golden_mem[(tr.ADDR >> 2) + i]);  
			        end
			    end
		    end


		    // Check results
		    if (tr.OPERATION == 2'd1) 
		    begin
		    	`uvm_info(get_type_name(), $sformatf("Test %0d - Write Operation", cases), UVM_LOW)
				tr.display();

				if (tr.actual_response == expected_response) 
				begin
					pass++;
					`uvm_info("get_type_name()", $sformatf("Test %0d PASSED", cases), UVM_LOW)
					`uvm_info("get_type_name()", "Write Operation passed", UVM_LOW)
					`uvm_info("get_type_name()", $sformatf("Expected response: %2b, Actual response: %2b",
						                                  expected_response, tr.actual_response), UVM_LOW)
				end
				else 
				begin
					fail++;
					faild_cases.push_back(cases);
					`uvm_info("get_type_name()", $sformatf("Test %0d FAILED - Response mismatch", cases), UVM_LOW)
					`uvm_info("get_type_name()", "Write Operation failed", UVM_LOW)
					`uvm_info("get_type_name()", $sformatf("Expected response: %2b, Actual response: %2b",
						                                  expected_response, tr.actual_response), UVM_LOW)
				end

			end else 
			if (tr.OPERATION == 2'd2) 
			begin
				`uvm_info(get_type_name(), $sformatf("Test %0d - Read Operation", cases), UVM_LOW)
				tr.display();

				if (((tr.ADDR >> tr.SIZE) + (tr.LEN)) >= 1024) 
				begin
					if (tr.actual_response == expected_response) 
					begin
						pass++;
						`uvm_info("get_type_name()", $sformatf("Test %0d PASSED", cases), UVM_LOW)
						`uvm_info("get_type_name()", "Read Operation passed", UVM_LOW)
						`uvm_info("get_type_name()", $sformatf("Expected response: %2b, Actual response: %2b",
						                                  expected_response, tr.actual_response), UVM_LOW)
					end else 
					begin
						fail++;
						faild_cases.push_back(cases);
						`uvm_info("get_type_name()", $sformatf("Test %0d FAILED - Response mismatch", cases), UVM_LOW)
						`uvm_info("get_type_name()", "Read Operation failed", UVM_LOW)
						`uvm_info("get_type_name()", $sformatf("Expected response: %2b, Actual response: %2b",
						                                  expected_response, tr.actual_response), UVM_LOW)
					end
				end else 
				begin
					// Valid read - check both data and response
					if (tr.actual_queue.size() != expected_queue.size()) begin
						fail++;
						faild_cases.push_back(cases);
						`uvm_info("get_type_name()", $sformatf("Test %0d FAILED - Queue size mismatch", cases), UVM_LOW)
						`uvm_info("get_type_name()", "Read Operation failed", UVM_LOW)
						`uvm_info("get_type_name()", $sformatf("Expected size: %0d, Actual size: %0d",
						                                  expected_queue.size(), tr.actual_queue.size()), UVM_LOW)
					end else
					if ((tr.actual_queue == expected_queue) && (tr.actual_response == expected_response)) 
					begin
					  pass++;
					  `uvm_info("get_type_name()", $sformatf("Test %0d PASSED", cases), UVM_LOW)
					  `uvm_info("get_type_name()", "Read Operation passed", UVM_LOW)
					  `uvm_info("get_type_name()", $sformatf("Expected response: %2b, Actual response: %2b",
					                                    expected_response, tr.actual_response), UVM_LOW)
					end else 
					begin
						fail++;
						faild_cases.push_back(cases);
						`uvm_error("get_type_name()", $sformatf("Test %0d FAILED - Data|Response mismatch", cases))
						`uvm_info("get_type_name()", "Read Operation failed", UVM_LOW)
						`uvm_info("get_type_name()", $sformatf("Expected response: %2b, Actual response: %2b",
						                                  expected_response, tr.actual_response), UVM_LOW) 
						// Print detailed mismatch information
						for (int i = 0; i < expected_queue.size(); i++) 
						begin
							if (expected_queue[i] != tr.actual_queue[i]) 
							begin
							  `uvm_info("get_type_name()", $sformatf("  Beat[%0d]: Expected = %h, Actual = %h",
							                                    i, expected_queue[i], tr.actual_queue[i]), UVM_LOW)
							end
						end
					end
				end
			end
			$display("");
		end
	endtask

	function void extract_phase(uvm_phase phase);
		super.report_phase(phase);
        $display("=== Final Results ===");
        `uvm_info(get_type_name(), $sformatf("Total tests: %0d", cases), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Passed: %0d", pass), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Failed: %0d", fail), UVM_LOW)
        if (faild_cases.size() > 0) 
        begin
        	for (int i = 0; i < faild_cases.size(); i++) 
        	begin
        		`uvm_info(get_type_name(), $sformatf("case nember: %0d failed", faild_cases[i]), UVM_LOW)
        	end
        end
        if (cases > 0) begin
            cov = (real'(pass) / real'(cases)) * 100.0;
            `uvm_info(get_type_name(), $sformatf("Pass Rate: %0.2f%%", cov), UVM_LOW)
        end
	endfunction


endclass 
`endif