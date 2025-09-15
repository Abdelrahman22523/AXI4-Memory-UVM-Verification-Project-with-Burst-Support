onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix binary /top/DUT/ARESETn
add wave -noupdate -radix binary /top/DUT/ACLK
add wave -noupdate -expand -group {Write signals} /top/DUT/write_state
add wave -noupdate -expand -group {Write signals} -radix unsigned /top/DUT/AWADDR
add wave -noupdate -expand -group {Write signals} -radix unsigned /top/DUT/AWLEN
add wave -noupdate -expand -group {Write signals} -radix unsigned /top/DUT/AWSIZE
add wave -noupdate -expand -group {Write signals} -radix binary /top/DUT/AWVALID
add wave -noupdate -expand -group {Write signals} -radix binary /top/DUT/AWREADY
add wave -noupdate -expand -group {Write signals} -radix binary /top/DUT/WVALID
add wave -noupdate -expand -group {Write signals} -radix binary /top/DUT/WREADY
add wave -noupdate -expand -group {Write signals} -radix unsigned /top/DUT/WDATA
add wave -noupdate -expand -group {Write signals} -radix binary /top/DUT/write_size
add wave -noupdate -expand -group {Write signals} -radix binary /top/DUT/WLAST
add wave -noupdate -expand -group {Write signals} -radix unsigned /top/DUT/write_burst_len
add wave -noupdate -expand -group {Write signals} -radix unsigned /top/DUT/write_burst_cnt
add wave -noupdate -expand -group {Write signals} -radix binary /top/DUT/write_boundary_cross
add wave -noupdate -expand -group {Write signals} -radix binary /top/DUT/write_addr_valid
add wave -noupdate -expand -group {Write signals} /top/DUT/write_addr_incr
add wave -noupdate -expand -group {Write signals} /top/DUT/write_addr
add wave -noupdate -expand -group {Write signals} -radix binary /top/DUT/BREADY
add wave -noupdate -expand -group {Write signals} -radix binary /top/DUT/BVALID
add wave -noupdate -expand -group {Write signals} -radix binary /top/DUT/BRESP
add wave -noupdate -expand -group Read_signals /top/DUT/read_state
add wave -noupdate -expand -group Read_signals -radix unsigned /top/DUT/ARADDR
add wave -noupdate -expand -group Read_signals -radix unsigned /top/DUT/ARLEN
add wave -noupdate -expand -group Read_signals -radix unsigned /top/DUT/ARSIZE
add wave -noupdate -expand -group Read_signals -radix binary /top/DUT/ARVALID
add wave -noupdate -expand -group Read_signals -radix binary /top/DUT/ARREADY
add wave -noupdate -expand -group Read_signals -radix binary /top/DUT/RREADY
add wave -noupdate -expand -group Read_signals -radix binary /top/DUT/RVALID
add wave -noupdate -expand -group Read_signals -radix unsigned /top/DUT/RDATA
add wave -noupdate -expand -group Read_signals -radix binary /top/DUT/RLAST
add wave -noupdate -expand -group Read_signals -radix binary /top/DUT/RRESP
add wave -noupdate -expand -group Read_signals -radix unsigned /top/DUT/read_size
add wave -noupdate -expand -group Read_signals -radix unsigned /top/DUT/read_burst_len
add wave -noupdate -expand -group Read_signals -radix unsigned /top/DUT/read_burst_cnt
add wave -noupdate -expand -group Read_signals -radix binary /top/DUT/read_boundary_cross
add wave -noupdate -expand -group Read_signals -radix binary /top/DUT/read_addr_valid
add wave -noupdate -expand -group Read_signals /top/DUT/read_addr_incr
add wave -noupdate -expand -group Read_signals /top/DUT/read_addr
add wave -noupdate -expand -group {Memory signals} -radix unsigned /top/DUT/mem_addr
add wave -noupdate -expand -group {Memory signals} -radix binary /top/DUT/mem_en
add wave -noupdate -expand -group {Memory signals} -radix binary /top/DUT/mem_we
add wave -noupdate -expand -group {Memory signals} -radix unsigned /top/DUT/mem_wdata
add wave -noupdate -expand -group {Memory signals} -radix unsigned /top/DUT/mem_rdata_reg
add wave -noupdate -expand -group {Memory signals} -radix unsigned /top/DUT/mem_rdata
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {14084929 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 251
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {14955834 ps} {15308987 ps}
