vlib work
vlog -f files.txt
vsim  -assertdebug +acc -voptargs=+acc work.top

do wave.do
run -all