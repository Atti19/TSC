onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top/clk
add wave -noupdate /top/test_clk
add wave -noupdate /top/tbif/clk
add wave -noupdate /top/tbif/test_clk
add wave -noupdate /top/tbif/reset_n
add wave -noupdate /top/tbif/load_en
add wave -noupdate /top/tbif/operand_a
add wave -noupdate /top/tbif/operand_b
add wave -noupdate /top/tbif/opcode
add wave -noupdate /top/tbif/write_pointer
add wave -noupdate /top/tbif/read_pointer
add wave -noupdate /top/tbif/instruction_word
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {1 us}
