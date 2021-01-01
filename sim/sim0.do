quit -sim
.main clear
vlib work
vmap work work
vlog -f list.txt
vsim -gui work.mp3dec_tb
add wave -group mp3tb_top sim:*
add wave -group mp3dec_top sim:uut/*
add wave -group mp3dec_dout sim:uut/dout_monitor_u0/*
run -all