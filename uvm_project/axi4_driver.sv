`ifndef AXI4_DRIVER_SVH
`define AXI4_DRIVER_SVH

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "axi4_transaction.sv"
`include "common_cfg.sv"

class axi4_driver extends uvm_driver #(axi4_transaction) ;

	virtual axi4_if axi4_vif;
	common_cfg m_cfg;

	uvm_analysis_port #(axi4_transaction) ap;

	`uvm_component_utils(axi4_driver)

	static int driver_transaction_count = 0;

	function new (string name = "axi4_driver", uvm_component parent = null);
		super.new(name,parent);
		ap = new("ap", this); // instantiate analysis port
		`uvm_info("axi4_driver", "INSIDE NEW DRIVER CLASS", UVM_LOW)
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		`uvm_info(get_type_name(), "axi4 driver build phase", UVM_LOW)

		if(!uvm_config_db#(virtual axi4_if)::get(this, "*", "axi4_intf", axi4_vif ))
			`uvm_fatal(get_full_name(), {"virtual axi4_vifface must be set for:", ".axi4_vif"})
		else
			$display("configuration DB dond");

		if(!uvm_config_db#(common_cfg)::get(this, "*", "m_cfg", m_cfg))
			`uvm_fatal(get_full_name(), "Failed to get common_cfg from config DB")
		else
			$display("common_cfg retrieved successfully in driver");
	endfunction


	task run_phase(uvm_phase phase);

		reset_signals();

		forever
		begin

			axi4_transaction req;

			// In driver's run_phase, add a counter
			/*driver_transaction_count++;
			`uvm_info(get_type_name(), $sformatf("Driver processing transaction %0d", driver_transaction_count), UVM_LOW)*/

			seq_item_port.get_next_item(req);
			ap.write(req);
			drive(req);
			seq_item_port.item_done();
		end
	endtask

	task reset_signals();
		axi4_vif.ARESETn = 1'b0;
		axi4_vif.AWVALID = 0;
	    axi4_vif.WVALID  = 0;
	    axi4_vif.WLAST   = 0;
	    axi4_vif.BREADY  = 0;
	    axi4_vif.ARVALID = 0;
	    axi4_vif.RREADY  = 0;
	    axi4_vif.AWADDR  = 0;
	    axi4_vif.AWLEN   = 0; 
	    axi4_vif.AWSIZE  = 0;
	    axi4_vif.WDATA   = 0;
	    axi4_vif.ARADDR  = 0;
	    axi4_vif.ARLEN   = 0; 
	    axi4_vif.ARSIZE  = 0;
	    
		// Hold reset for multiple clock cycles
		repeat(3) @(posedge axi4_vif.ACLK);
		axi4_vif.ARESETn = 1'b1;
		// Wait for reset deassertion to settle
		repeat(2) @(posedge axi4_vif.ACLK);
	endtask

	extern task drive(axi4_transaction req);

endclass


task axi4_driver::drive(axi4_transaction req);

	if (req.OPERATION == 2'd2) 
	begin
	  // Apply delay before starting read address phase
	  repeat (req.ar_valid_delay) @(negedge axi4_vif.ACLK);

	  // Set up read address channel
	  axi4_vif.ARADDR  = req.ADDR;
	  axi4_vif.ARLEN   = req.LEN;
	  axi4_vif.ARSIZE  = req.SIZE;
	  axi4_vif.ARVALID = 1'b1;

	  // Wait for address acceptance
	  repeat (20) @(negedge axi4_vif.ACLK)
	    if (axi4_vif.ARREADY) break;
	  axi4_vif.ARVALID = 0;

	  //`uvm_info(get_type_name(), "Read address phase completed", UVM_MEDIUM)
	end else 
	if (req.OPERATION == 2'd1) 
	begin

		// data randomiz
		for (int i = 0; i <= req.LEN; i++) 
		  begin  
		    assert(req.randomize(DATA))
		      else `uvm_fatal(get_type_name(), $sformatf("Data randomization failed for beat %0d", i))
		    req.all_data.push_back(req.DATA);

		  end

	    // Apply delay before starting write address phase
	    repeat (req.aw_valid_delay) @(negedge axi4_vif.ACLK);
	    // Start write address transaction

	    axi4_vif.AWADDR  = req.ADDR;
	    axi4_vif.AWLEN   = req.LEN;
	    axi4_vif.AWSIZE  = req.SIZE;
	    axi4_vif.AWVALID = 1'b1;

	    // Wait for address acceptance
	    repeat (20) @(negedge axi4_vif.ACLK)
	      if (axi4_vif.AWREADY) break;

	    axi4_vif.AWVALID = 1'b0;

	    //`uvm_info(get_type_name(), "Write address phase completed", UVM_MEDIUM)
      	//req.display();

	    if (((req.ADDR >> req.SIZE) + (req.LEN + 1)) > 1024)  
	    begin
	        assert(req.randomize(w_valid_delay))
	          else $fatal("w_valid_delay randomization failed");

	        repeat (req.w_valid_delay) @(negedge axi4_vif.ACLK);

	        axi4_vif.WDATA  = req.all_data[0];
	        axi4_vif.WVALID = 1'b1;
	        axi4_vif.WLAST  = 1;
	        
	        // Wait for write data acceptance
	        repeat (20) @(negedge axi4_vif.ACLK)
	        if (axi4_vif.WREADY) break;
	        
	    end else
	    begin

	        // Apply delay before starting write data phase
	        repeat (req.w_valid_delay) @(negedge axi4_vif.ACLK);

	        // Send burst data with proper handshaking
	        for (int i = 0; i <= req.LEN; i++) 
	        begin
		        axi4_vif.WDATA  = req.all_data[i];
		        axi4_vif.WVALID = 1'b1;
		        axi4_vif.WLAST  = (i == req.LEN);
		        
		        // Wait for write data acceptance
		        repeat (20) @(negedge axi4_vif.ACLK)
		          if (axi4_vif.WREADY) break;
		          
		        // Generate random delay for each write data beat
		        if (i < req.LEN) 
		        begin
	            	assert(req.randomize(w_valid_delay)) 
	            	    else $fatal("w_valid_delay randomization failed");
	            	axi4_vif.WVALID = 1'b0;
	            	repeat (req.w_valid_delay) @(negedge axi4_vif.ACLK);
	            end;
	        end
	        //`uvm_info(get_type_name(), "Write data phase completed", UVM_MEDIUM)
        	//req.display();
	    end
	end
	//req.print();
	
	// Store current transaction in config for monitor access
	m_cfg.current_tr = req;
	-> m_cfg.stimulus_sent_e;
endtask



`endif