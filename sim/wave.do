onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group en /dual_router_tb/f02_en
add wave -noupdate -group en /dual_router_tb/x0_en
add wave -noupdate -group en /dual_router_tb/x1_en
add wave -noupdate -group en /dual_router_tb/y0_en
add wave -noupdate -group en /dual_router_tb/y1_en
add wave -noupdate /dual_router_tb/btrig
add wave -noupdate -group {FILT data gen} /dual_router_tb/f02_btrig
add wave -noupdate -group {FILT data gen} -color Gold /dual_router_tb/f02_ktrig
add wave -noupdate -group {FILT data gen} /dual_router_tb/pg0_in_busy
add wave -noupdate -group {FILT data gen} -color magenta /dual_router_tb/pg0_in_valid
add wave -noupdate -group {FILT data gen} -expand /dual_router_tb/pg0_in_data
add wave -noupdate -group {FILT data gen} -group {PKT GEN OUT} /dual_router_tb/pg0_out_data
add wave -noupdate -group {FILT data gen} -group {PKT GEN OUT} /dual_router_tb/pg0_out_full
add wave -noupdate -group {FILT data gen} -group {PKT GEN OUT} /dual_router_tb/pg0_out_isk
add wave -noupdate -group {FILT data gen} -group {PKT GEN OUT} /dual_router_tb/pg0_out_valid
add wave -noupdate -group {FILT data gen} -group {FIFO OUT} /dual_router_tb/gen0_fifo_data
add wave -noupdate -group {FILT data gen} -group {FIFO OUT} /dual_router_tb/gen0_fifo_empty
add wave -noupdate -group {FILT data gen} -group {FIFO OUT} /dual_router_tb/gen0_fifo_isk
add wave -noupdate -group {FILT data gen} -group {FIFO OUT} /dual_router_tb/gen0_fifo_next
add wave -noupdate -group {X0 data gen} /dual_router_tb/x0_btrig
add wave -noupdate -group {X0 data gen} -color Gold /dual_router_tb/x0_ktrig
add wave -noupdate -group {X0 data gen} /dual_router_tb/x0_in_valid
add wave -noupdate -group {X0 data gen} -expand /dual_router_tb/x0_in_data
add wave -noupdate -group {X1 data gen} /dual_router_tb/x1_btrig
add wave -noupdate -group {X1 data gen} -color Gold /dual_router_tb/x1_ktrig
add wave -noupdate -group {X1 data gen} /dual_router_tb/x1_in_valid
add wave -noupdate -group {X1 data gen} /dual_router_tb/x1_in_data
add wave -noupdate -group {Y0 data gen} /dual_router_tb/y0_btrig
add wave -noupdate -group {Y0 data gen} -color Gold /dual_router_tb/y0_ktrig
add wave -noupdate -group {Y0 data gen} /dual_router_tb/y0_in_valid
add wave -noupdate -group {Y0 data gen} -expand /dual_router_tb/y0_in_data
add wave -noupdate -group {Y1 data gen} /dual_router_tb/y1_btrig
add wave -noupdate -group {Y1 data gen} -color Gold /dual_router_tb/y1_ktrig
add wave -noupdate -group {Y1 data gen} /dual_router_tb/y1_in_valid
add wave -noupdate -group {Y1 data gen} /dual_router_tb/y1_in_data
add wave -noupdate -group {FIFO FILL CNT} -group full /dual_router_tb/pg0_out_full
add wave -noupdate -group {FIFO FILL CNT} -group full /dual_router_tb/x0_out_full
add wave -noupdate -group {FIFO FILL CNT} -group full /dual_router_tb/x1_out_full
add wave -noupdate -group {FIFO FILL CNT} -group full /dual_router_tb/y0_out_full
add wave -noupdate -group {FIFO FILL CNT} -group full /dual_router_tb/y1_out_full
add wave -noupdate -group {FIFO FILL CNT} -format Analog-Step -height 50 -max 1024.0 -radix unsigned /dual_router_tb/fifo_cnt_f02
add wave -noupdate -group {FIFO FILL CNT} -format Analog-Step -height 50 -max 1024.0 -radix unsigned /dual_router_tb/fifo_cnt_x0
add wave -noupdate -group {FIFO FILL CNT} -format Analog-Step -height 50 -max 1024.0 -radix unsigned /dual_router_tb/fifo_cnt_x1
add wave -noupdate -group {FIFO FILL CNT} -format Analog-Step -height 50 -max 1024.0 -radix unsigned /dual_router_tb/fifo_cnt_y0
add wave -noupdate -group {FIFO FILL CNT} -format Analog-Step -height 50 -max 1024.0 -radix unsigned /dual_router_tb/fifo_cnt_y1
add wave -noupdate -group {FIFO WRITE CNT} -radix unsigned /dual_router_tb/fifo_wcnt_f02
add wave -noupdate -group {FIFO WRITE CNT} -radix unsigned /dual_router_tb/fifo_wcnt_x0
add wave -noupdate -group {FIFO WRITE CNT} -radix unsigned /dual_router_tb/fifo_wcnt_x1
add wave -noupdate -group {FIFO WRITE CNT} -radix unsigned /dual_router_tb/fifo_wcnt_y0
add wave -noupdate -group {FIFO WRITE CNT} -radix unsigned /dual_router_tb/fifo_wcnt_y1
add wave -noupdate -group {filter IO} -color {Cornflower Blue} -radix unsigned /dual_router_tb/f02_in_cnt
add wave -noupdate -group {filter IO} -color orange /dual_router_tb/f02_resetting
add wave -noupdate -group {filter IO} -color cyan /dual_router_tb/f02_pkt_valid
add wave -noupdate -group {filter IO} -color tan /dual_router_tb/f02_pkt_discard_x
add wave -noupdate -group {filter IO} -color tan /dual_router_tb/f02_pkt_discard_y
add wave -noupdate -group {filter IO} -color cyan /dual_router_tb/f02_in0_empty
add wave -noupdate -group {filter IO} /dual_router_tb/f02_in0_next
add wave -noupdate -group {filter IO} /dual_router_tb/f02_in0_isk
add wave -noupdate -group {filter IO} /dual_router_tb/f02_in0_data
add wave -noupdate -group {filter IO} -color cyan /dual_router_tb/f02_in1_empty
add wave -noupdate -group {filter IO} /dual_router_tb/f02_in1_next
add wave -noupdate -group {filter IO} /dual_router_tb/f02_in1_isk
add wave -noupdate -group {filter IO} /dual_router_tb/f02_in1_data
add wave -noupdate -group {filter IO} -color tan /dual_router_tb/xr_in_next(0)
add wave -noupdate -group {filter IO} -color tan /dual_router_tb/xr_in_valid(0)
add wave -noupdate -group {filter IO} -color tan /dual_router_tb/xr_in_isk(0)
add wave -noupdate -group {filter IO} -color tan /dual_router_tb/xr_in_data(0)
add wave -noupdate -group {filter IO} /dual_router_tb/yr_in_next(0)
add wave -noupdate -group {filter IO} /dual_router_tb/yr_in_valid(0)
add wave -noupdate -group {filter IO} /dual_router_tb/yr_in_isk(0)
add wave -noupdate -group {filter IO} /dual_router_tb/yr_in_data(0)
add wave -noupdate -group xrouter -radix unsigned /dual_router_tb/xr_in_cnt0
add wave -noupdate -group xrouter -radix unsigned /dual_router_tb/xr_in_cnt1
add wave -noupdate -group xrouter -radix unsigned /dual_router_tb/xr_in_cnt2
add wave -noupdate -group xrouter -color tan -expand -subitemconfig {/dual_router_tb/xr_in_valid(0) {-color tan -height 15} /dual_router_tb/xr_in_valid(1) {-color tan -height 15} /dual_router_tb/xr_in_valid(2) {-color tan -height 15}} /dual_router_tb/xr_in_valid
add wave -noupdate -group xrouter -color tan -expand -subitemconfig {/dual_router_tb/xr_in_next(0) {-color tan -height 15} /dual_router_tb/xr_in_next(1) {-color tan -height 15} /dual_router_tb/xr_in_next(2) {-color tan -height 15}} /dual_router_tb/xr_in_next
add wave -noupdate -group xrouter -color tan -expand -subitemconfig {/dual_router_tb/xr_in_isk(0) {-color tan -height 15} /dual_router_tb/xr_in_isk(1) {-color tan -height 15} /dual_router_tb/xr_in_isk(2) {-color tan -height 15}} /dual_router_tb/xr_in_isk
add wave -noupdate -group xrouter -color tan -expand -subitemconfig {/dual_router_tb/xr_in_data(0) {-color tan -height 15} /dual_router_tb/xr_in_data(1) {-color tan -height 15} /dual_router_tb/xr_in_data(2) {-color tan -height 15}} /dual_router_tb/xr_in_data
add wave -noupdate -group xrouter /dual_router_tb/xr_in_valid(0)
add wave -noupdate -group xrouter /dual_router_tb/xr_in_next(0)
add wave -noupdate -group xrouter /dual_router_tb/xr_in_isk(0)
add wave -noupdate -group xrouter /dual_router_tb/xr_in_data(0)
add wave -noupdate -group xrouter /dual_router_tb/xr_out_valid(0)
add wave -noupdate -group xrouter /dual_router_tb/xr_out_isk(0)
add wave -noupdate -group xrouter /dual_router_tb/xr_out_data(0)
add wave -noupdate -group xrouter /dual_router_tb/xr_out_err
add wave -noupdate -group yrouter -radix unsigned /dual_router_tb/yr_in_cnt0
add wave -noupdate -group yrouter -radix unsigned /dual_router_tb/yr_in_cnt1
add wave -noupdate -group yrouter -radix unsigned /dual_router_tb/yr_in_cnt2
add wave -noupdate -group yrouter -expand /dual_router_tb/yr_in_valid
add wave -noupdate -group yrouter -expand /dual_router_tb/yr_in_next
add wave -noupdate -group yrouter -expand /dual_router_tb/yr_in_isk
add wave -noupdate -group yrouter -expand /dual_router_tb/yr_in_data
add wave -noupdate -group yrouter /dual_router_tb/yr_out_valid
add wave -noupdate -group yrouter /dual_router_tb/yr_out_isk
add wave -noupdate -group yrouter /dual_router_tb/yr_out_data
add wave -noupdate -group yrouter /dual_router_tb/yr_out_err
add wave -noupdate -group {outfifo X} -radix unsigned /dual_router_tb/xr_out_cnt
add wave -noupdate -group {outfifo X} -color {Orange Red} /dual_router_tb/xr_out_full
add wave -noupdate -group {outfifo X} -clampanalog 1 -format Analog-Step -height 50 -max 1024.0 -radix unsigned /dual_router_tb/ofifo_x_cnt
add wave -noupdate -group {outfifo Y} -radix unsigned /dual_router_tb/yr_out_cnt
add wave -noupdate -group {outfifo Y} -color {Orange Red} /dual_router_tb/yr_out_full
add wave -noupdate -group {outfifo Y} -clampanalog 1 -format Analog-Step -height 50 -max 1024.0 -radix unsigned /dual_router_tb/ofifo_y_cnt
add wave -noupdate -group xout -color magenta /dual_router_tb/xout_eop
add wave -noupdate -group xout /dual_router_tb/xout_good
add wave -noupdate -group xout -color orange /dual_router_tb/xout_bad
add wave -noupdate -group xout -color {Orange Red} /dual_router_tb/xout_error
add wave -noupdate -group xout /dual_router_tb/xout_packet
add wave -noupdate -group yout -color magenta /dual_router_tb/yout_eop
add wave -noupdate -group yout /dual_router_tb/yout_good
add wave -noupdate -group yout -color orange /dual_router_tb/yout_bad
add wave -noupdate -group yout -color {Orange Red} /dual_router_tb/yout_error
add wave -noupdate -group yout /dual_router_tb/yout_packet
add wave -noupdate -expand -group Stats -color {Medium Orchid} -radix unsigned /dual_router_tb/bpm1_xcnt
add wave -noupdate -expand -group Stats -color {Medium Orchid} -radix unsigned /dual_router_tb/bpm2_xcnt
add wave -noupdate -expand -group Stats -color {Medium Orchid} -radix unsigned /dual_router_tb/bpm3_xcnt
add wave -noupdate -expand -group Stats -color {Medium Orchid} -radix unsigned /dual_router_tb/bpm4_xcnt
add wave -noupdate -expand -group Stats -color {Medium Orchid} -radix unsigned /dual_router_tb/bpm5_xcnt
add wave -noupdate -expand -group Stats -color {Medium Orchid} -radix unsigned /dual_router_tb/bpm6_xcnt
add wave -noupdate -expand -group Stats -color {Medium Orchid} -radix unsigned /dual_router_tb/bpm7_xcnt
add wave -noupdate -expand -group Stats -color {Medium Orchid} -radix unsigned /dual_router_tb/bpm8_xcnt
add wave -noupdate -expand -group Stats -color Orchid -radix unsigned /dual_router_tb/bpm9_xcnt
add wave -noupdate -expand -group Stats -color Orchid -radix unsigned /dual_router_tb/bpmA_xcnt
add wave -noupdate -expand -group Stats -color Turquoise -radix unsigned /dual_router_tb/bpm1_ycnt
add wave -noupdate -expand -group Stats -color Turquoise -radix unsigned /dual_router_tb/bpm2_ycnt
add wave -noupdate -expand -group Stats -color Turquoise -radix unsigned /dual_router_tb/bpm3_ycnt
add wave -noupdate -expand -group Stats -color Turquoise -radix unsigned /dual_router_tb/bpm4_ycnt
add wave -noupdate -expand -group Stats -color Turquoise -radix unsigned /dual_router_tb/bpm5_ycnt
add wave -noupdate -expand -group Stats -color Turquoise -radix unsigned /dual_router_tb/bpm6_ycnt
add wave -noupdate -expand -group Stats -color Turquoise -radix unsigned /dual_router_tb/bpm7_ycnt
add wave -noupdate -expand -group Stats -color Turquoise -radix unsigned /dual_router_tb/bpm8_ycnt
add wave -noupdate -expand -group Stats -color Turquoise -radix unsigned /dual_router_tb/bpm9_ycnt
add wave -noupdate -expand -group Stats -color Turquoise -radix unsigned /dual_router_tb/bpmA_ycnt
add wave -noupdate -group {BITS PER CLOCK} -color Cyan -format Analog-Step -height 40 -max 25.0 /dual_router_tb/bpc_gen_filt
add wave -noupdate -group {BITS PER CLOCK} -color Cyan -format Analog-Step -height 40 -max 25.0 /dual_router_tb/bpc_gen_x0
add wave -noupdate -group {BITS PER CLOCK} -color Cyan -format Analog-Step -height 40 -max 25.0 /dual_router_tb/bpc_gen_x1
add wave -noupdate -group {BITS PER CLOCK} -color Cyan -format Analog-Step -height 40 -max 25.0 /dual_router_tb/bpc_gen_y0
add wave -noupdate -group {BITS PER CLOCK} -color Cyan -format Analog-Step -height 40 -max 25.0 /dual_router_tb/bpc_gen_y1
add wave -noupdate -group {BITS PER CLOCK} -color Magenta -format Analog-Step -height 40 -max 25.0 /dual_router_tb/bpc_pkt_filt
add wave -noupdate -group {BITS PER CLOCK} -color Magenta -format Analog-Step -height 40 -max 25.0 /dual_router_tb/bpc_pkt_x0
add wave -noupdate -group {BITS PER CLOCK} -color Magenta -format Analog-Step -height 40 -max 25.0 /dual_router_tb/bpc_pkt_x1
add wave -noupdate -group {BITS PER CLOCK} -color Magenta -format Analog-Step -height 40 -max 25.0 /dual_router_tb/bpc_pkt_y0
add wave -noupdate -group {BITS PER CLOCK} -color Magenta -format Analog-Step -height 40 -max 25.0 /dual_router_tb/bpc_pkt_y1
add wave -noupdate -group {BITS PER CLOCK} -color Yellow -format Analog-Step -height 40 -max 25.0 /dual_router_tb/bpc_filt_in
add wave -noupdate -group {BITS PER CLOCK} -color {Orange Red} -format Analog-Step -height 40 -max 25.0 /dual_router_tb/bpc_xr_in0
add wave -noupdate -group {BITS PER CLOCK} -color {Orange Red} -format Analog-Step -height 40 -max 25.0 /dual_router_tb/bpc_xr_in1
add wave -noupdate -group {BITS PER CLOCK} -color {Orange Red} -format Analog-Step -height 40 -max 25.0 /dual_router_tb/bpc_xr_in2
add wave -noupdate -group {BITS PER CLOCK} -color Gold -format Analog-Step -height 40 -max 25.0 /dual_router_tb/bpc_yr_in0
add wave -noupdate -group {BITS PER CLOCK} -color Gold -format Analog-Step -height 40 -max 25.0 /dual_router_tb/bpc_yr_in1
add wave -noupdate -group {BITS PER CLOCK} -color Gold -format Analog-Step -height 40 -max 25.0 /dual_router_tb/bpc_yr_in2
add wave -noupdate -group {BITS PER CLOCK} -color {Orange Red} -format Analog-Step -height 40 -max 25.0 /dual_router_tb/bpc_xr_out
add wave -noupdate -group {BITS PER CLOCK} -color Gold -format Analog-Step -height 40 -max 25.0 /dual_router_tb/bpc_yr_out
add wave -noupdate -group {BITS PER CLOCK} -color {Cornflower Blue} -format Analog-Step -height 40 -max 25.0 /dual_router_tb/bpc_ofifo_x
add wave -noupdate -group {BITS PER CLOCK} -color {Cornflower Blue} -format Analog-Step -height 40 -max 25.0 /dual_router_tb/bpc_ofifo_y
add wave -noupdate -group {BITS PER CLOCK} -format Analog-Step -height 40 -max 25.0 /dual_router_tb/bpc_opkt_x
add wave -noupdate -group {BITS PER CLOCK} -format Analog-Step -height 40 -max 25.0 /dual_router_tb/bpc_opkt_y
add wave -noupdate -group {BITS PER SECOND} -color Cyan -format Analog-Step -height 30 -max 4000.0 /dual_router_tb/bps_gen_filt
add wave -noupdate -group {BITS PER SECOND} -color Cyan -format Analog-Step -height 30 -max 4000.0 /dual_router_tb/bps_gen_x0
add wave -noupdate -group {BITS PER SECOND} -color Cyan -format Analog-Step -height 30 -max 4000.0 /dual_router_tb/bps_gen_x1
add wave -noupdate -group {BITS PER SECOND} -color Cyan -format Analog-Step -height 30 -max 4000.0 /dual_router_tb/bps_gen_y0
add wave -noupdate -group {BITS PER SECOND} -color Cyan -format Analog-Step -height 30 -max 4000.0 /dual_router_tb/bps_gen_y1
add wave -noupdate -group {BITS PER SECOND} -color magenta -format Analog-Step -height 30 -max 4000.0 /dual_router_tb/bps_pkt_filt
add wave -noupdate -group {BITS PER SECOND} -color magenta -format Analog-Step -height 30 -max 4000.0 /dual_router_tb/bps_pkt_x0
add wave -noupdate -group {BITS PER SECOND} -color magenta -format Analog-Step -height 30 -max 4000.0 /dual_router_tb/bps_pkt_x1
add wave -noupdate -group {BITS PER SECOND} -color magenta -format Analog-Step -height 30 -max 4000.0 /dual_router_tb/bps_pkt_y0
add wave -noupdate -group {BITS PER SECOND} -color magenta -format Analog-Step -height 30 -max 4000.0 /dual_router_tb/bps_pkt_y1
add wave -noupdate -group {BITS PER SECOND} -color Yellow -format Analog-Step -height 30 -max 4000.0 /dual_router_tb/bps_filt_in
add wave -noupdate -group {BITS PER SECOND} -color {Orange Red} -format Analog-Step -height 30 -max 4000.0 /dual_router_tb/bps_xr_in0
add wave -noupdate -group {BITS PER SECOND} -color {Orange Red} -format Analog-Step -height 30 -max 4000.0 /dual_router_tb/bps_xr_in1
add wave -noupdate -group {BITS PER SECOND} -color {Orange Red} -format Analog-Step -height 30 -max 4000.0 /dual_router_tb/bps_xr_in2
add wave -noupdate -group {BITS PER SECOND} -color Gold -format Analog-Step -height 30 -max 4000.0 /dual_router_tb/bps_yr_in0
add wave -noupdate -group {BITS PER SECOND} -color Gold -format Analog-Step -height 30 -max 4000.0 /dual_router_tb/bps_yr_in1
add wave -noupdate -group {BITS PER SECOND} -color Gold -format Analog-Step -height 30 -max 4000.0 /dual_router_tb/bps_yr_in2
add wave -noupdate -group {BITS PER SECOND} -color {Orange Red} -format Analog-Step -height 30 -max 4000.0 /dual_router_tb/bps_xr_out
add wave -noupdate -group {BITS PER SECOND} -color Gold -format Analog-Step -height 30 -max 4000.0 /dual_router_tb/bps_yr_out
add wave -noupdate -group {BITS PER SECOND} -color {Cornflower Blue} -format Analog-Step -height 30 -max 4000.0 /dual_router_tb/bps_ofifo_x
add wave -noupdate -group {BITS PER SECOND} -color {Cornflower Blue} -format Analog-Step -height 30 -max 4000.0 /dual_router_tb/bps_ofifo_y
add wave -noupdate -group {BITS PER SECOND} -format Analog-Step -height 30 -max 4000.0 /dual_router_tb/bps_opkt_x
add wave -noupdate -group {BITS PER SECOND} -format Analog-Step -height 30 -max 4000.0 /dual_router_tb/bps_opkt_y
add wave -noupdate -divider PING
add wave -noupdate /dual_router_tb/TEST_PING
add wave -noupdate /dual_router_tb/f02_ping_en0
add wave -noupdate /dual_router_tb/f02_ping_en1
add wave -noupdate -color gold /dual_router_tb/f02_btrig
add wave -noupdate -color Cyan /dual_router_tb/f02_ping_rx0
add wave -noupdate -radix unsigned /dual_router_tb/f02_ping_lat0
add wave -noupdate -color Cyan /dual_router_tb/f02_ping_rx1
add wave -noupdate -radix unsigned /dual_router_tb/f02_ping_lat1
add wave -noupdate -expand -group TX0 /dual_router_tb/f02_out0_data
add wave -noupdate -expand -group TX0 /dual_router_tb/f02_out0_full
add wave -noupdate -expand -group TX0 /dual_router_tb/f02_out0_isk
add wave -noupdate -expand -group TX0 -color gold /dual_router_tb/f02_out0_write
add wave -noupdate -expand -group TX1 /dual_router_tb/f02_out1_data
add wave -noupdate -expand -group TX1 /dual_router_tb/f02_out1_full
add wave -noupdate -expand -group TX1 /dual_router_tb/f02_out1_isk
add wave -noupdate -expand -group TX1 -color gold /dual_router_tb/f02_out1_write
add wave -noupdate -expand -group RX0 /dual_router_tb/ping0_fifo_data
add wave -noupdate -expand -group RX0 /dual_router_tb/ping0_fifo_empty
add wave -noupdate -expand -group RX0 /dual_router_tb/ping0_fifo_isk
add wave -noupdate -expand -group RX0 -color magenta /dual_router_tb/ping0_fifo_next
add wave -noupdate -expand -group RX1 /dual_router_tb/ping1_fifo_data
add wave -noupdate -expand -group RX1 /dual_router_tb/ping1_fifo_empty
add wave -noupdate -expand -group RX1 /dual_router_tb/ping1_fifo_isk
add wave -noupdate -expand -group RX1 -color magenta /dual_router_tb/ping1_fifo_next
add wave -noupdate -expand -group internal /dual_router_tb/FILTER02/s
add wave -noupdate -expand -group internal /dual_router_tb/FILTER02/trig_cnt
add wave -noupdate -expand -group internal /dual_router_tb/FILTER02/timer
add wave -noupdate -expand -group internal /dual_router_tb/FILTER02/ping0_sent
add wave -noupdate -expand -group internal /dual_router_tb/FILTER02/ping1_sent
add wave -noupdate -expand -group internal /dual_router_tb/FILTER02/ctrl
add wave -noupdate -expand -group internal -color magenta /dual_router_tb/FILTER02/pkt_valid
add wave -noupdate -expand -group internal -color magenta /dual_router_tb/FILTER02/pkt_valid_r
add wave -noupdate -expand -group internal /dual_router_tb/FILTER02/rx_is_ping0
add wave -noupdate -expand -group internal /dual_router_tb/FILTER02/rx_is_ping1
add wave -noupdate -expand -group internal -color cyan /dual_router_tb/FILTER02/ping0_rx
add wave -noupdate -expand -group internal -color cyan /dual_router_tb/FILTER02/ping1_rx
add wave -noupdate -expand -group internal /dual_router_tb/FILTER02/bpm
add wave -noupdate -expand -group internal /dual_router_tb/FILTER02/rx_time
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {556375000 ps} 0} {{Cursor 2} {99843785 ps} 0}
quietly wave cursor active 2
configure wave -namecolwidth 172
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
configure wave -timeline 1
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {105 us}
