interface axi4_if ();

	logic        ACLK;
	logic        ARESETn;
    logic        AWVALID;
	logic        AWREADY;
	logic        WLAST;
	logic        RLAST;
	logic        WVALID;
	logic        WREADY;
	logic        RVALID;
	logic        RREADY;
	logic        ARREADY;
	logic        ARVALID;
	logic        BVALID;
	logic        BREADY;
    logic [15:0] AWADDR;
    logic [7:0]  AWLEN;
    logic [2:0]  AWSIZE;
    logic [31:0] WDATA;
	logic [15:0] ARADDR;
	logic [31:0] RDATA;
	logic [7:0]  ARLEN;
    logic [2:0]  ARSIZE;
	logic [1:0]  RRESP;
	logic [1:0]  BRESP;
	 
endinterface