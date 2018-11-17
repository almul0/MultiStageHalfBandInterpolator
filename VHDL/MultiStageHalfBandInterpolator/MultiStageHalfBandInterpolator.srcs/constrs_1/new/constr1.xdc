create_clock -period 10.000 -name AXI_CLOCK -waveform {0.000 5.000} [get_ports {SlaveAxi_RI[s_axi_aclk]}]
