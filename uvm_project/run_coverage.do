if {![file exists work]} {
    vlib work
}

vlog -f files.txt +cover -covercells
vsim  work.top  -cover

coverage save -onexit cov.ucdb -du work.axi4 

do wave.do
run -all

coverage report -details -output cov_report.txt