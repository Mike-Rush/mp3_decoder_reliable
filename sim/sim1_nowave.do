quit -sim
.main clear
vlib work
vmap work work
vlog -f list1.txt
vsim -L unisims_ver -gui work.mp3dec_tb_v01 work.glbl 
run -all