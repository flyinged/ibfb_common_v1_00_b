onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /dual_router_tb/FILTER02/i_rst
add wave -noupdate -group parameters /dual_router_tb/FILTER02/i_bpm_id
add wave -noupdate -group parameters /dual_router_tb/FILTER02/i_bkt_max
add wave -noupdate -group parameters /dual_router_tb/FILTER02/i_bkt_min
add wave -noupdate -group parameters /dual_router_tb/FILTER02/i_ping_enable0
add wave -noupdate -group parameters /dual_router_tb/FILTER02/i_ping_enable1
add wave -noupdate -group parameters /dual_router_tb/FILTER02/bkt_max
add wave -noupdate -group parameters /dual_router_tb/FILTER02/bkt_min
add wave -noupdate /dual_router_tb/FILTER02/i_trig
add wave -noupdate -group {INPUT FIFOS} -color cyan /dual_router_tb/FILTER02/i_rxfifo_empty0
add wave -noupdate -group {INPUT FIFOS} -color magenta /dual_router_tb/FILTER02/o_rxfifo_next0
add wave -noupdate -group {INPUT FIFOS} /dual_router_tb/FILTER02/i_rxfifo_charisk0
add wave -noupdate -group {INPUT FIFOS} /dual_router_tb/FILTER02/i_rxfifo_data0
add wave -noupdate -group {INPUT FIFOS} -color cyan /dual_router_tb/FILTER02/i_rxfifo_empty1
add wave -noupdate -group {INPUT FIFOS} -color magenta /dual_router_tb/FILTER02/o_rxfifo_next1
add wave -noupdate -group {INPUT FIFOS} /dual_router_tb/FILTER02/i_rxfifo_charisk1
add wave -noupdate -group {INPUT FIFOS} /dual_router_tb/FILTER02/i_rxfifo_data1
add wave -noupdate /dual_router_tb/FILTER02/b0
add wave -noupdate /dual_router_tb/FILTER02/b1
add wave -noupdate /dual_router_tb/FILTER02/b2
add wave -noupdate /dual_router_tb/FILTER02/b3
add wave -noupdate /dual_router_tb/FILTER02/isk
add wave -noupdate /dual_router_tb/FILTER02/switch_channel
add wave -noupdate -color gold /dual_router_tb/FILTER02/chan
add wave -noupdate /dual_router_tb/FILTER02/eop
add wave -noupdate -color {Medium Orchid} /dual_router_tb/FILTER02/sop
add wave -noupdate -color Plum /dual_router_tb/FILTER02/next_s
add wave -noupdate -color Blue /dual_router_tb/FILTER02/s
add wave -noupdate /dual_router_tb/FILTER02/ctrl
add wave -noupdate /dual_router_tb/FILTER02/bpm
add wave -noupdate /dual_router_tb/FILTER02/bucket
add wave -noupdate /dual_router_tb/FILTER02/xpos
add wave -noupdate /dual_router_tb/FILTER02/ypos
add wave -noupdate /dual_router_tb/FILTER02/flag_update
add wave -noupdate -color orange /dual_router_tb/FILTER02/reset_flags
add wave -noupdate -divider <NULL>
add wave -noupdate /dual_router_tb/FILTER02/bpm
add wave -noupdate /dual_router_tb/FILTER02/bpm_id
add wave -noupdate /dual_router_tb/FILTER02/bpm_mask
add wave -noupdate -expand -group {FLAG RAM WRITE} /dual_router_tb/FILTER02/flag_write_v
add wave -noupdate -expand -group {FLAG RAM WRITE} /dual_router_tb/FILTER02/flag_set
add wave -noupdate -expand -group {FLAG RAM WRITE} /dual_router_tb/FILTER02/reset_addr
add wave -noupdate /dual_router_tb/FILTER02/flag_addr
add wave -noupdate /dual_router_tb/FILTER02/flag_v
add wave -noupdate /dual_router_tb/FILTER02/flag_m
add wave -noupdate -color Yellow /dual_router_tb/FILTER02/flag
add wave -noupdate -color Magenta /dual_router_tb/FILTER02/pkt_valid
add wave -noupdate -expand -group discard -color Magenta /dual_router_tb/FILTER02/pkt_valid
add wave -noupdate -expand -group discard -color Yellow /dual_router_tb/FILTER02/flag
add wave -noupdate -expand -group discard /dual_router_tb/FILTER02/bpm_mask
add wave -noupdate -expand -group discard /dual_router_tb/FILTER02/off_range
add wave -noupdate -expand -group discard /dual_router_tb/FILTER02/rx_is_ping0
add wave -noupdate -expand -group discard /dual_router_tb/FILTER02/rx_is_ping1
add wave -noupdate -expand -group discard -color orange /dual_router_tb/FILTER02/pkt_discard_x
add wave -noupdate -expand -group discard -color orange /dual_router_tb/FILTER02/pkt_discard_y
add wave -noupdate /dual_router_tb/FILTER02/ovalid
add wave -noupdate -expand -group {OUTPUT CHANNELS} /dual_router_tb/FILTER02/oreg_free_x
add wave -noupdate -expand -group {OUTPUT CHANNELS} /dual_router_tb/FILTER02/oreg_full_x
add wave -noupdate -expand -group {OUTPUT CHANNELS} -color cyan /dual_router_tb/FILTER02/i_output_next_x
add wave -noupdate -expand -group {OUTPUT CHANNELS} -color magenta /dual_router_tb/FILTER02/o_output_valid_x
add wave -noupdate -expand -group {OUTPUT CHANNELS} /dual_router_tb/FILTER02/o_output_charisk_x
add wave -noupdate -expand -group {OUTPUT CHANNELS} /dual_router_tb/FILTER02/o_output_data_x
add wave -noupdate -expand -group {OUTPUT CHANNELS} /dual_router_tb/FILTER02/ocnt_x
add wave -noupdate -expand -group {OUTPUT CHANNELS} /dual_router_tb/FILTER02/ocnt_y
add wave -noupdate -expand -group {OUTPUT CHANNELS} /dual_router_tb/FILTER02/oreg_free_y
add wave -noupdate -expand -group {OUTPUT CHANNELS} /dual_router_tb/FILTER02/oreg_full_y
add wave -noupdate -expand -group {OUTPUT CHANNELS} -color cyan /dual_router_tb/FILTER02/i_output_next_y
add wave -noupdate -expand -group {OUTPUT CHANNELS} -color magenta /dual_router_tb/FILTER02/o_output_valid_y
add wave -noupdate -expand -group {OUTPUT CHANNELS} /dual_router_tb/FILTER02/o_output_charisk_y
add wave -noupdate -expand -group {OUTPUT CHANNELS} /dual_router_tb/FILTER02/o_output_data_y
add wave -noupdate -group regs /dual_router_tb/FILTER02/bpm_mask_r
add wave -noupdate -group regs /dual_router_tb/FILTER02/bpm_r
add wave -noupdate -group regs /dual_router_tb/FILTER02/chan_r
add wave -noupdate -group regs /dual_router_tb/FILTER02/next_s_x
add wave -noupdate -group regs /dual_router_tb/FILTER02/next_s_y
add wave -noupdate -group regs /dual_router_tb/FILTER02/pkt_discard_x_r
add wave -noupdate -group regs /dual_router_tb/FILTER02/pkt_discard_y_r
add wave -noupdate -group {PING RX} /dual_router_tb/FILTER02/trig_r
add wave -noupdate -group {PING RX} /dual_router_tb/FILTER02/pkt_valid_r
add wave -noupdate -group {PING RX} /dual_router_tb/FILTER02/rx_is_ping0
add wave -noupdate -group {PING RX} /dual_router_tb/FILTER02/ping0_rx
add wave -noupdate -group {PING RX} /dual_router_tb/FILTER02/ping0_latency
add wave -noupdate -group {PING RX} /dual_router_tb/FILTER02/rx_is_ping1
add wave -noupdate -group {PING RX} /dual_router_tb/FILTER02/ping1_latency
add wave -noupdate -group {PING RX} /dual_router_tb/FILTER02/ping1_rx
add wave -noupdate -group {PING RX} /dual_router_tb/FILTER02/rx_time
add wave -noupdate -group {QDR LOGIC} /dual_router_tb/FILTER02/rx_pkt_cnt
add wave -noupdate -group {QDR LOGIC} /dual_router_tb/FILTER02/rx_pkt_cnt0
add wave -noupdate -group {QDR LOGIC} /dual_router_tb/FILTER02/rx_pkt_cnt1
add wave -noupdate -group {QDR LOGIC} /dual_router_tb/FILTER02/bunch_timer
add wave -noupdate -group {PING TX} -color cyan /dual_router_tb/FILTER02/i_txfifo_full0
add wave -noupdate -group {PING TX} -color magenta /dual_router_tb/FILTER02/o_txfifo_write0
add wave -noupdate -group {PING TX} /dual_router_tb/FILTER02/o_txfifo_charisk0
add wave -noupdate -group {PING TX} /dual_router_tb/FILTER02/o_txfifo_data0
add wave -noupdate -group {PING TX} -color cyan /dual_router_tb/FILTER02/i_txfifo_full1
add wave -noupdate -group {PING TX} -color magenta /dual_router_tb/FILTER02/o_txfifo_write1
add wave -noupdate -group {PING TX} /dual_router_tb/FILTER02/o_txfifo_charisk1
add wave -noupdate -group {PING TX} /dual_router_tb/FILTER02/o_txfifo_data1
add wave -noupdate -group {PING TX} /dual_router_tb/FILTER02/ping0_sent
add wave -noupdate -group {PING TX} /dual_router_tb/FILTER02/ping1_sent
add wave -noupdate -group {PING TX} /dual_router_tb/FILTER02/trig_cnt
add wave -noupdate -group {PING TX} /dual_router_tb/FILTER02/timer
add wave -noupdate -group {PING TX} /dual_router_tb/FILTER02/ptx0_busy
add wave -noupdate -group {PING TX} /dual_router_tb/FILTER02/ptx0_data
add wave -noupdate -group {PING TX} /dual_router_tb/FILTER02/ptx0_valid
add wave -noupdate -group {PING TX} /dual_router_tb/FILTER02/ptx1_busy
add wave -noupdate -group {PING TX} /dual_router_tb/FILTER02/ptx1_data
add wave -noupdate -group {PING TX} /dual_router_tb/FILTER02/ptx1_valid
add wave -noupdate -group {out info} /dual_router_tb/FILTER02/o_pkt_discard_x
add wave -noupdate -group {out info} /dual_router_tb/FILTER02/o_pkt_discard_y
add wave -noupdate -group {out info} /dual_router_tb/FILTER02/o_pkt_valid
add wave -noupdate -group {out info} /dual_router_tb/FILTER02/o_resetting
add wave -noupdate -group {out info} /dual_router_tb/FILTER02/o_qdr2_out
add wave -noupdate -group {out info} /dual_router_tb/FILTER02/o_statistics
add wave -noupdate -group {out info} /dual_router_tb/FILTER02/r_statistics
add wave -noupdate -group {Ping out} /dual_router_tb/FILTER02/o_ping_latency0
add wave -noupdate -group {Ping out} /dual_router_tb/FILTER02/o_ping_latency1
add wave -noupdate -group {Ping out} /dual_router_tb/FILTER02/o_ping_rx0
add wave -noupdate -group {Ping out} /dual_router_tb/FILTER02/o_ping_rx1
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {118972359 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 173
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 16
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us
update
WaveRestoreZoom {118799664 ps} {119315813 ps}
