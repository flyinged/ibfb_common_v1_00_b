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
add wave -noupdate -group Stats -color {Medium Orchid} -radix unsigned /dual_router_tb/bpm1_xcnt
add wave -noupdate -group Stats -color {Medium Orchid} -radix unsigned /dual_router_tb/bpm2_xcnt
add wave -noupdate -group Stats -color {Medium Orchid} -radix unsigned /dual_router_tb/bpm3_xcnt
add wave -noupdate -group Stats -color {Medium Orchid} -radix unsigned /dual_router_tb/bpm4_xcnt
add wave -noupdate -group Stats -color {Medium Orchid} -radix unsigned /dual_router_tb/bpm5_xcnt
add wave -noupdate -group Stats -color {Medium Orchid} -radix unsigned /dual_router_tb/bpm6_xcnt
add wave -noupdate -group Stats -color {Medium Orchid} -radix unsigned /dual_router_tb/bpm7_xcnt
add wave -noupdate -group Stats -color {Medium Orchid} -radix unsigned /dual_router_tb/bpm8_xcnt
add wave -noupdate -group Stats -color Orchid -radix unsigned /dual_router_tb/bpm9_xcnt
add wave -noupdate -group Stats -color Orchid -radix unsigned /dual_router_tb/bpmA_xcnt
add wave -noupdate -group Stats -color Turquoise -radix unsigned /dual_router_tb/bpm1_ycnt
add wave -noupdate -group Stats -color Turquoise -radix unsigned /dual_router_tb/bpm2_ycnt
add wave -noupdate -group Stats -color Turquoise -radix unsigned /dual_router_tb/bpm3_ycnt
add wave -noupdate -group Stats -color Turquoise -radix unsigned /dual_router_tb/bpm4_ycnt
add wave -noupdate -group Stats -color Turquoise -radix unsigned /dual_router_tb/bpm5_ycnt
add wave -noupdate -group Stats -color Turquoise -radix unsigned /dual_router_tb/bpm6_ycnt
add wave -noupdate -group Stats -color Turquoise -radix unsigned /dual_router_tb/bpm7_ycnt
add wave -noupdate -group Stats -color Turquoise -radix unsigned /dual_router_tb/bpm8_ycnt
add wave -noupdate -group Stats -color Turquoise -radix unsigned /dual_router_tb/bpm9_ycnt
add wave -noupdate -group Stats -color Turquoise -radix unsigned /dual_router_tb/bpmA_ycnt
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
add wave -noupdate -group TX0 /dual_router_tb/f02_out0_data
add wave -noupdate -group TX0 /dual_router_tb/f02_out0_full
add wave -noupdate -group TX0 /dual_router_tb/f02_out0_isk
add wave -noupdate -group TX0 -color gold /dual_router_tb/f02_out0_write
add wave -noupdate -group TX1 /dual_router_tb/f02_out1_data
add wave -noupdate -group TX1 /dual_router_tb/f02_out1_full
add wave -noupdate -group TX1 /dual_router_tb/f02_out1_isk
add wave -noupdate -group TX1 -color gold /dual_router_tb/f02_out1_write
add wave -noupdate -group RX0 /dual_router_tb/ping0_fifo_data
add wave -noupdate -group RX0 /dual_router_tb/ping0_fifo_empty
add wave -noupdate -group RX0 /dual_router_tb/ping0_fifo_isk
add wave -noupdate -group RX0 -color magenta /dual_router_tb/ping0_fifo_next
add wave -noupdate -group RX1 /dual_router_tb/ping1_fifo_data
add wave -noupdate -group RX1 /dual_router_tb/ping1_fifo_empty
add wave -noupdate -group RX1 /dual_router_tb/ping1_fifo_isk
add wave -noupdate -group RX1 -color magenta /dual_router_tb/ping1_fifo_next
add wave -noupdate -group internal /dual_router_tb/FILTER02/s
add wave -noupdate -group internal /dual_router_tb/FILTER02/trig_cnt
add wave -noupdate -group internal /dual_router_tb/FILTER02/timer
add wave -noupdate -group internal /dual_router_tb/FILTER02/ping0_sent
add wave -noupdate -group internal /dual_router_tb/FILTER02/ping1_sent
add wave -noupdate -group internal /dual_router_tb/FILTER02/ctrl
add wave -noupdate -group internal -color magenta /dual_router_tb/FILTER02/pkt_valid
add wave -noupdate -group internal -color magenta /dual_router_tb/FILTER02/pkt_valid_r
add wave -noupdate -group internal /dual_router_tb/FILTER02/rx_is_ping0
add wave -noupdate -group internal /dual_router_tb/FILTER02/rx_is_ping1
add wave -noupdate -group internal -color cyan /dual_router_tb/FILTER02/ping0_rx
add wave -noupdate -group internal -color cyan /dual_router_tb/FILTER02/ping1_rx
add wave -noupdate -group internal /dual_router_tb/FILTER02/bpm
add wave -noupdate -group internal /dual_router_tb/FILTER02/rx_time
add wave -noupdate -divider <NULL>
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
add wave -noupdate -color yellow /dual_router_tb/FILTER02/bpm_mask
add wave -noupdate -expand -group {FLAG RAM WRITE} /dual_router_tb/FILTER02/flag_write_v
add wave -noupdate -expand -group {FLAG RAM WRITE} /dual_router_tb/FILTER02/flag_set
add wave -noupdate -expand -group {FLAG RAM WRITE} /dual_router_tb/FILTER02/reset_addr
add wave -noupdate /dual_router_tb/FILTER02/flag_addr
add wave -noupdate /dual_router_tb/FILTER02/flag_v
add wave -noupdate /dual_router_tb/FILTER02/flag_m
add wave -noupdate -color Yellow /dual_router_tb/FILTER02/flag
add wave -noupdate -color Magenta /dual_router_tb/FILTER02/pkt_valid
add wave -noupdate -expand -group discard /dual_router_tb/FILTER02/pkt_valid_r
add wave -noupdate -expand -group discard -color Yellow /dual_router_tb/FILTER02/flag
add wave -noupdate -expand -group discard /dual_router_tb/FILTER02/bpm_mask
add wave -noupdate -expand -group discard /dual_router_tb/FILTER02/off_range
add wave -noupdate -expand -group discard /dual_router_tb/FILTER02/rx_is_ping0
add wave -noupdate -expand -group discard /dual_router_tb/FILTER02/rx_is_ping1
add wave -noupdate -expand -group discard -color orange /dual_router_tb/FILTER02/pkt_discard_x
add wave -noupdate -expand -group discard -color orange /dual_router_tb/FILTER02/pkt_discard_y
add wave -noupdate /dual_router_tb/FILTER02/ovalid
add wave -noupdate -expand -group STATS -color Magenta /dual_router_tb/FILTER02/pkt_valid
add wave -noupdate -expand -group STATS /dual_router_tb/FILTER02/pkt_valid_r
add wave -noupdate -expand -group STATS /dual_router_tb/FILTER02/pkt_valid_s
add wave -noupdate -expand -group STATS /dual_router_tb/FILTER02/pkt_discard_x_r
add wave -noupdate -expand -group STATS /dual_router_tb/FILTER02/pkt_discard_y_r
add wave -noupdate -expand -group STATS -childformat {{/dual_router_tb/FILTER02/r_statistics.packets_chan0_in -radix unsigned} {/dual_router_tb/FILTER02/r_statistics.packets_chan1_in -radix unsigned} {/dual_router_tb/FILTER02/r_statistics.packets_discarded_x -radix unsigned} {/dual_router_tb/FILTER02/r_statistics.packets_discarded_y -radix unsigned} {/dual_router_tb/FILTER02/r_statistics.wrong_bpm_id_x -radix unsigned} {/dual_router_tb/FILTER02/r_statistics.wrong_bpm_id_y -radix unsigned} {/dual_router_tb/FILTER02/r_statistics.packets_passed_x -radix unsigned} {/dual_router_tb/FILTER02/r_statistics.packets_passed_y -radix unsigned}} -expand -subitemconfig {/dual_router_tb/FILTER02/r_statistics.packets_chan0_in {-height 15 -radix unsigned} /dual_router_tb/FILTER02/r_statistics.packets_chan1_in {-height 15 -radix unsigned} /dual_router_tb/FILTER02/r_statistics.packets_discarded_x {-height 15 -radix unsigned} /dual_router_tb/FILTER02/r_statistics.packets_discarded_y {-height 15 -radix unsigned} /dual_router_tb/FILTER02/r_statistics.wrong_bpm_id_x {-height 15 -radix unsigned} /dual_router_tb/FILTER02/r_statistics.wrong_bpm_id_y {-height 15 -radix unsigned} /dual_router_tb/FILTER02/r_statistics.packets_passed_x {-height 15 -radix unsigned} /dual_router_tb/FILTER02/r_statistics.packets_passed_y {-height 15 -radix unsigned}} /dual_router_tb/FILTER02/r_statistics
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
WaveRestoreCursors {{Cursor 1} {999023350 ps} 0} {{Cursor 2} {99843785 ps} 0}
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
WaveRestoreZoom {118935799 ps} {119667619 ps}
