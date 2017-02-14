vcom -work work -2002 -explicit -vopt ./throughput_meter.vhd
vcom -work work -2002 -explicit -vopt ../hdl/vhdl/pkg_crc.vhd
vcom -work work -2002 -explicit -vopt ../hdl/vhdl/ram_infer.vhd
vcom -work work -2002 -explicit -vopt ../hdl/vhdl/virtex5_gtx_package.vhd
vcom -work work -2002 -explicit -vopt ../hdl/vhdl/ibfb_comm_package_dev.vhd
vcom -work work -2002 -explicit -vopt ./dual_router_tb.vhd


vsim -gui -t ps -vopt -voptargs=+acc work.dual_router_tb
log -r *
radix hex

do wave_filt.do

alias WW "write format wave -window .main_pane.wave.interior.cs.body.pw.wf ./wave_filt.do"

