`ifndef AXI4_COVERAGE_SVH
`define AXI4_COVERAGE_SVH

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "axi4_transaction.sv"

class axi4_coverage extends uvm_component;

	`uvm_component_utils(axi4_coverage)

	uvm_analysis_export #(axi4_transaction) analysis_export;
	uvm_tlm_analysis_fifo #(axi4_transaction) fifo;

	axi4_transaction tr;

	covergroup axi4_cov(ref axi4_transaction tr);
		// LEN coverage with corner bins
	    coverpoint tr.LEN {
	      bins corner0   = {8'd0};
	      bins corner1   = {8'd1};
	      bins corner2   = {8'd127};
	      bins corner3   = {8'd128};
	      bins corner4   = {8'd254}; 
	      bins corner5   = {8'd255};
	      bins auto_bins[] = {[8'd0:8'd255]}; 
	    }

	    // ADDR coverage with corner bins
	    coverpoint tr.ADDR {
	      bins corner0   = {16'd0};
	      bins corner1   = {16'd1024};
	      bins corner2   = {16'd2048};
	      bins corner3   = {16'd4092};
	      bins corner4   = {16'b1111_1111_1100};
	      bins range_0   = { [16'd0       : 16'd255]   };
	      bins range_1   = { [16'd256     : 16'd1023]  };
	      bins range_2   = { [16'd1024    : 16'd4095]  };
	      bins range_3   = { [16'd4096    : 16'd16383] };
	      bins range_4   = { [16'd16384   : 16'd32767] };
	      bins range_5   = { [16'd32768   : 16'd49151] };
	      bins range_6   = { [16'd49152   : 16'd65535] };
	    }

	    // Fixed size coverage
	    coverpoint tr.SIZE {
	      bins fixed_size = {2};
	      illegal_bins others = default;
	    }

	    // DATA coverage with corner bins
	    coverpoint tr.DATA {
	      bins corner0       = {32'd0};
	      bins corner1       = {32'd1};
	      bins corner2       = {32'hFFFF_FFFF};
	      bins corner3       = {32'hAAAA_AAAA};
	      bins corner4       = {32'h1111_0000}; 
	      bins corner5       = {32'h0000_1111};
	      bins range_0       = { [32'd0          : 32'd255] };
	      bins range_1       = { [32'd256        : 32'd1023] };
	      bins range_2       = { [32'd1024       : 32'd4095] };
	      bins range_3       = { [32'd4096       : 32'd16383] };
	      bins range_4       = { [32'd16384      : 32'd32767] };
	      bins range_5       = { [32'd32768      : 32'd49151] };
	      bins range_6       = { [32'd49152      : 32'd65535] };
	      bins range_7       = { [32'd65536      : 32'd262143] };
	      bins range_8       = { [32'd262144     : 32'd1048575] };
	      bins range_9       = { [32'd1048576    : 32'd16777215] };
	      bins range_10      = { [32'd16777216   : 32'd268435455] };
	      bins range_11      = { [32'd268435456  : 32'd1073741823] };
	      bins range_12      = { [32'd1073741824 : 32'hFFFFFFFF] };  
	      }

	    // Memory access bounds coverage
	    coverpoint ((tr.ADDR >> 2) + (tr.LEN + 1)) {
	      bins valid_access   = {[0:1024]};   // Fits within memory
	      bins invalid_access = {[1025:$]};   // Exceeds memory
	    }

	    // Delay coverage
	    coverpoint tr.aw_valid_delay { bins all_values[] = {[0:7]}; }
	    coverpoint tr.w_valid_delay  { bins all_values[] = {[0:7]}; }
	    coverpoint tr.b_ready_delay  { bins all_values[] = {[0:7]}; }
	    coverpoint tr.ar_valid_delay { bins all_values[] = {[0:7]}; }
	    coverpoint tr.r_ready_delay  { bins all_values[] = {[0:7]}; }

	    // Cross coverage
	    cross tr.LEN, tr.ADDR;
	    cross tr.DATA, tr.LEN;
	    cross tr.DATA, tr.ADDR;
	    cross tr.aw_valid_delay, tr.w_valid_delay;
	    cross tr.ar_valid_delay, tr.r_ready_delay;
		
	endgroup


	function new (string name = "axi4_coverage", uvm_component parent = null);
		super.new(name,parent);
		axi4_cov = new(tr);

		`uvm_info("axi4_coverage", "INSIDE NEW COVERAGE CLASS", UVM_LOW)
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		analysis_export = new("analysis_export", this);
		fifo = new("fifo", this);

		`uvm_info(get_type_name(), "axi4 coverage build phase", UVM_LOW)
	endfunction

	function void connect_phase(uvm_phase phase);
		analysis_export.connect(fifo.analysis_export);
	endfunction 

	task run_phase(uvm_phase phase);
		forever
		begin
			fifo.get(tr);
			axi4_cov.sample();
			//`uvm_info(get_type_name(), "Coverage sampled for transaction", UVM_MEDIUM)
		end
	endtask

	function void report_phase(uvm_phase phase);
	  real cov = axi4_cov.get_coverage();
	  `uvm_info(get_type_name(),
	            $sformatf("Final Coverage = %0.2f%%", cov),
	            UVM_LOW)
	endfunction

endclass 
`endif