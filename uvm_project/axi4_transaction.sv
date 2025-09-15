`ifndef AXI4_TRANSACTION_SVH  
`define AXI4_TRANSACTION_SVH 

`include "uvm_macros.svh"    
import uvm_pkg::*;           

class axi4_transaction extends uvm_sequence_item;  

	// Write signals
    rand logic [15:0] ADDR;
    rand logic [7:0]  LEN;   
    rand logic [2:0]  SIZE;
    rand logic [31:0] DATA;
    rand logic [1:0]  OPERATION;


    logic [31:0] all_data[$];
    logic [31:0] actual_queue[$];
    logic [1 :0] actual_response;


    // Random delays for handshaking
    rand  logic [2:0] aw_valid_delay;
    rand  logic [2:0] w_valid_delay; 
    rand  logic [2:0] b_ready_delay;
    rand  logic [2:0] ar_valid_delay;
    rand  logic [2:0] r_ready_delay;

    rand bit below_1024;
    rand int unsigned data_mode;
    rand int unsigned addr_mode;
    rand int unsigned len_mode;


	// Constraints
	constraint OPERATION_C {
    OPERATION dist { 2'd1 := 50, 2'd2 := 50 }; // Equal distribution
  }

	// Delay constraints
	constraint delay_ranges {
	  aw_valid_delay inside {[0:7]};
	  w_valid_delay  inside {[0:7]};
	  b_ready_delay  inside {[0:7]};
	  ar_valid_delay inside {[0:7]};  
	  r_ready_delay  inside {[0:7]};
	}

	constraint fix_size {
	  SIZE == 2;  // Fixed to 2 (4 bytes)
	}


	constraint aligned_address {
	  ADDR[1:0] == 2'b00; // Aligned to 4-byte boundary
	}


	// Valid access constraint 
	constraint range_split {
  below_1024 dist {1 := 50, 0 := 50}; 
  if (below_1024)
    ((ADDR >> 2) + (LEN + 1)) <= 1024;
  else
    ((ADDR >> 2) + (LEN + 1)) > 1024;
	}


	constraint len_mode_dist {
  len_mode dist {0 := 80, 1 := 20};
	}


	constraint LEN_range_c {
	  if (len_mode == 0) {
	    LEN inside {[8'd0 : 8'd255]};
	  }
	}


	constraint LEN_corners_c {
	  if (len_mode == 1) {
	    LEN inside {
	      8'd0,
	      8'd1,
	      8'd127,
	      8'd128,
	      8'd254,
	      8'd255
	    };
	  }
	}



	constraint addr_mode_dist {
  addr_mode dist {0 := 90, 1 := 10};
  }

  constraint addr_c {
  if (addr_mode == 0) {
    ADDR inside {[16'd0 : 16'd65535]};
	  }
	}

	constraint addr_corner_c {
	  if (addr_mode == 1) {
	    ADDR inside {
	      16'd0,
	      16'd1024,
	      16'd2048,
	      16'd4092,
	      16'b1111_1111_1100
	    };
	  }
	}



	constraint data_mode_dist {
  data_mode dist {0:=30, 1:=30, 2:=30, 3:=10};
	}

  constraint data_c1 {
  if (data_mode == 0) {
    DATA inside {
      [32'd0          : 32'd255],
      [32'd256        : 32'd1023],
      [32'd1024       : 32'd4095],
      [32'd4096       : 32'd16383],
      [32'd16384      : 32'd32767]
	    };
	  }
	}

	constraint data_c2 {
	  if (data_mode == 1) {
	    DATA inside {
	      [32'd0          : 32'd1],
	      [32'd32768      : 32'd49151],
	      [32'd49152      : 32'd65535],
	      [32'd65536      : 32'd262143],
	      [32'd262144     : 32'd1048575]
	    };
	  }
	}

	constraint data_c3 {
	  if (data_mode == 2) {
	    DATA inside {
	      [32'd0          : 32'd1],
	      [32'd1048576    : 32'd16777215],
	      [32'd16777216   : 32'd268435455],
	      [32'd268435456  : 32'd1073741823],
	      [32'd1073741824 : 32'hFFFFFFFF]
	    };
	  }
	}

	constraint data_corner_c {
	  if (data_mode == 3) {
	    DATA inside {
	      32'd0, 
	      32'd1,  
	      32'hFFFF_FFFF, 
	      32'hAAAA_AAAA, 
	      32'h1111_0000, 
	      32'h0000_1111
	    };
	  }
	}




	function void display();
	  `uvm_info(get_type_name(), $sformatf("ADDR = %0d, LEN = %0d, SIZE = %0d, Memory Access = %0d", 
		              ADDR, LEN, SIZE, ((ADDR >> 2) + (LEN))), UVM_LOW)

		`uvm_info(get_type_name(), $sformatf("Delays - AW:%0d, W:%0d, B:%0d, AR:%0d, R:%0d",
		        aw_valid_delay, w_valid_delay, b_ready_delay, ar_valid_delay, r_ready_delay), UVM_LOW)
	endfunction


	`uvm_object_utils_begin(axi4_transaction)
	    `uvm_field_int(ADDR,       UVM_DEFAULT)  
	    `uvm_field_int(LEN,        UVM_DEFAULT)  
	    `uvm_field_int(SIZE,       UVM_DEFAULT)
	    `uvm_field_int(DATA,       UVM_DEFAULT)  
	    `uvm_field_int(OPERATION,  UVM_DEFAULT)

	    // Handshake delays
	    `uvm_field_int(aw_valid_delay, UVM_DEFAULT)
	    `uvm_field_int(w_valid_delay,  UVM_DEFAULT)
	    `uvm_field_int(b_ready_delay,  UVM_DEFAULT)
	    `uvm_field_int(ar_valid_delay, UVM_DEFAULT)
	    `uvm_field_int(r_ready_delay,  UVM_DEFAULT)
	`uvm_object_utils_end


	function new(string name = "axi4_transaction");   
		super.new(name);        
		//axi4_cov = new(this);  // Construct the covergroup                     
		`uvm_info("axi4_transaction", "INSIDE NEW TRANSACTION CLASS", UVM_LOW)	
	endfunction

endclass 

`endif