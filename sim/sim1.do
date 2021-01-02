quit -sim
.main clear
vlib work
vmap work work
vlog -f list1.txt
vsim -L unisims_ver -gui work.mp3dec_tb_v01 work.glbl 
add wave -group mp3tb_top sim:*
add wave -group mp3dec_top sim:uut/*
add wave -group mp3dec_macdout sim:uut/CH0_PCM_RAM_we
add wave -group mp3dec_macdout sim:uut/CH0_PCM_RAM_write_data
add wave -group mp3dec_macdout sim:uut/CH1_PCM_RAM_we
add wave -group mp3dec_macdout sim:uut/CH1_PCM_RAM_write_data
add wave -group input_dat sim:uut/HUFF_clock
add wave -group input_dat sim:uut/HUFF_DP_ADDRESS
add wave -group input_dat sim:uut/HUFF_DP_DATA
#add wave -group mp3dec_dout sim:uut/dout_monitor_u0/*
add wave -group mp3dec_huff_streamer sim:uut/HUFFMANDECODER/inputstream/*
run -all