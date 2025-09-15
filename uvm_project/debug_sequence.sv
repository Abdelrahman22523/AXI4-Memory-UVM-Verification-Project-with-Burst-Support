`ifndef DEBUG_SEQUENCE_SVH
`define DEBUG_SEQUENCE_SVH

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "axi4_transaction.sv"
`include "common_cfg.sv"
`include "axi4_sequencer.sv"

class debug_sequence extends uvm_sequence #(axi4_transaction);
    `uvm_object_utils(debug_sequence)
    
    int transaction_count = 0;

    common_cfg m_cfg;
    
    // Known failing scenarios based on your log pattern
    typedef struct {
        bit [15:0] addr;
        bit [7:0]  len;
        bit [2:0]  size;
        bit [1:0]  operation;
        string     description;
    } debug_scenario_t;
    
    debug_scenario_t failing_scenarios[] = '{
        // Scenarios that commonly cause failures
        '{addr: 16'h0FF0, len: 8'd3,   size: 3'd2, operation: 2'd2, description: "Read near 4KB boundary"},
        '{addr: 16'h0FFC, len: 8'd1,   size: 3'd2, operation: 2'd2, description: "Read at 4KB boundary"},
        '{addr: 16'h1000, len: 8'd255, size: 3'd2, operation: 2'd1, description: "Write with max length crossing boundary"},
        '{addr: 16'h0000, len: 8'd0,   size: 3'd2, operation: 2'd2, description: "Minimum read length"},
        '{addr: 16'hFFFC, len: 8'd255, size: 3'd2, operation: 2'd2, description: "Max address with long burst"},
        '{addr: 16'h0FE0, len: 8'd7,   size: 3'd2, operation: 2'd1, description: "Write crossing boundary"},
        '{addr: 16'h0FE4, len: 8'd6,   size: 3'd2, operation: 2'd2, description: "Read crossing boundary"},
        '{addr: 16'h0FF8, len: 8'd2,   size: 3'd2, operation: 2'd2, description: "Read exactly at boundary"},
        '{addr: 16'h1004, len: 8'd1,   size: 3'd2, operation: 2'd1, description: "Write just after boundary"},
        '{addr: 16'h0800, len: 8'd127, size: 3'd2, operation: 2'd2, description: "Large read in middle range"}
    };
    
    function new(string name = "debug_sequence");
        super.new(name);
        `uvm_info("debug_sequence", "INSIDE NEW DEBUG SEQUENCE CLASS", UVM_LOW)
    endfunction
    
    task body();
        axi4_transaction req;
        axi4_sequencer sqr;
        
        $cast(sqr, m_sequencer);
        m_cfg = sqr.m_cfg;
        
        `uvm_info(get_type_name(), "Starting debug sequence with targeted scenarios", UVM_LOW)
        
        // Run each specific scenario multiple times
        foreach(failing_scenarios[i]) begin
            `uvm_info(get_type_name(), 
                $sformatf("Testing scenario %0d: %s", i, failing_scenarios[i].description), UVM_LOW)
            
            repeat(50) begin  // Run each scenario 50 times
                transaction_count++;
                req = axi4_transaction::type_id::create("req");
                req.all_data.delete();
                
                start_item(req);
                
                // Disable randomization for main signals
                req.ADDR.rand_mode(0);
				req.LEN.rand_mode(0);
				req.SIZE.rand_mode(0);
				req.OPERATION.rand_mode(0);

				// Disable conflicting constraints
				req.constraint_mode(0);  // disable ALL constraints

				// Apply fixed values from scenario
				req.ADDR      = failing_scenarios[i].addr;
				req.LEN       = failing_scenarios[i].len;
				req.SIZE      = failing_scenarios[i].size;
				req.OPERATION = failing_scenarios[i].operation;

				// Randomize only handshake delays
				assert(req.randomize(aw_valid_delay, w_valid_delay, b_ready_delay, 
				                     ar_valid_delay, r_ready_delay))
				  else `uvm_fatal(get_type_name(), "Delay randomization failed")
                
                // Generate data for write operations
                if (req.OPERATION == 2'd1) begin
                    for (int j = 0; j <= req.LEN; j++) begin
                        assert(req.randomize(DATA))
                            else `uvm_fatal(get_type_name(), 
                                $sformatf("Data randomization failed for beat %0d", j))
                        req.all_data.push_back(req.DATA);
                        //req.axi4_cov.sample();
                    end
                end else begin
                    //req.axi4_cov.sample();
                end
                
                finish_item(req);
                @ (m_cfg.monitor_sent_e);
            end
            
            `uvm_info(get_type_name(), 
                $sformatf("Completed scenario %0d: %s", i, failing_scenarios[i].description), UVM_LOW)
        end
        
        
        `uvm_info(get_type_name(), 
            $sformatf("Debug sequence completed - Generated %0d targeted transactions", 
            transaction_count), UVM_LOW)
    endtask
endclass

`endif