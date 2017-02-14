vcom -work work -2002 -explicit -vopt ./throughput_meter.vhd
vcom -work work -2002 -explicit -vopt ../hdl/vhdl/pkg_crc.vhd
vcom -work work -2002 -explicit -vopt ../hdl/vhdl/ram_infer.vhd
vcom -work work -2002 -explicit -vopt ../hdl/vhdl/virtex5_gtx_package.vhd
vcom -work work -2002 -explicit -vopt ../hdl/vhdl/ibfb_comm_package.vhd
vcom -work work -2002 -explicit -vopt ./dual_router_tb.vhd


vsim -gui -t ps -vopt -voptargs=+acc work.dual_router_tb
#vsim -gui -t ps -novopt work.dual_router_tb
log -r *
radix hex

do wave.do

alias WW "write format wave -window .main_pane.wave.interior.cs.body.pw.wf C:/temp/G/XFEL/14_Firmware/22_Library/EDKLib/hw/PSI/pcores/ibfb_common_v1_00_b/sim/wave.do"

