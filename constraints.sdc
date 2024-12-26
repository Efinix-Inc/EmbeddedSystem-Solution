
# Efinity Interface Designer SDC
# Version: 2023.1.150.3.11
# Date: 2023-08-21 22:29

# Copyright (C) 2017 - 2023 Efinix Inc. All rights reserved.

# Device: T120F576
# Project: Unified Soc Project
# Timing Model: C4 (final)

# PLL Constraints
#################

### Clock for Soc
create_clock -period 2.5000 ddr_clk
create_clock -period 20.0000 io_peripheralClk
create_clock -period 20.0000 io_systemClk
create_clock -period 20.0000 io_memoryClk
create_clock -period 100.000 jtag_inst1_TCK

### Clock for Picam and HDMI
create_clock -period 13.3333 mipi_pclk
create_clock -period 10.0000 mipi_cal_clk
create_clock -period 33.3333 hdmi_clk
create_clock -period 26.9360 tx_slowclk
create_clock -waveform {1.9240 5.7720} -period 7.6960 tx_fastclk

### Clock for Tsemac
create_clock -period 8.0000 io_tseClk
create_clock -waveform {1.0000 5.0000} -period 8.0000 io_tseClk_90
create_clock -period 40.0 [get_ports {rgmii_rxc}]

set_clock_groups -exclusive -group {io_tseClk} -group {io_tseClk_90}  -group {rgmii_rxc} -group {io_peripheralClk} -group {io_systemClk} -group {io_memoryClk} -group {jtag_inst1_TCK} -group {mipi_pclk} -group {hdmi_clk} -group {mipi_cal_clk} -group {tx_slowclk} -group {tx_fastclk}


#Display & Camera Related Constraints
##############################
set_input_delay -clock hdmi_clk -reference_pin [get_ports {hdmi_clk~CLKOUT~101~1}] -max 0.620 [get_ports {hdmi_scl_read}]
set_input_delay -clock hdmi_clk -reference_pin [get_ports {hdmi_clk~CLKOUT~101~1}] -min 0.310 [get_ports {hdmi_scl_read}]
set_output_delay -clock hdmi_clk -reference_pin [get_ports {hdmi_clk~CLKOUT~99~1}] -max 0.100 [get_ports {hdmi_scl_writeEnable}]
set_output_delay -clock hdmi_clk -reference_pin [get_ports {hdmi_clk~CLKOUT~99~1}] -min -0.175 [get_ports {hdmi_scl_writeEnable}]
set_input_delay -clock hdmi_clk -reference_pin [get_ports {hdmi_clk~CLKOUT~102~1}] -max 0.620 [get_ports {hdmi_sda_read}]
set_input_delay -clock hdmi_clk -reference_pin [get_ports {hdmi_clk~CLKOUT~102~1}] -min 0.310 [get_ports {hdmi_sda_read}]
set_output_delay -clock hdmi_clk -reference_pin [get_ports {hdmi_clk~CLKOUT~100~1}] -max 0.100 [get_ports {hdmi_sda_writeEnable}]
set_output_delay -clock hdmi_clk -reference_pin [get_ports {hdmi_clk~CLKOUT~100~1}] -min -0.175 [get_ports {hdmi_sda_writeEnable}]
set_output_delay -clock io_peripheralClk -reference_pin [get_ports {io_peripheralClk~CLKOUT~308~1}] -max 0.100 [get_ports {o_cam_scl_oe}]
set_output_delay -clock io_peripheralClk -reference_pin [get_ports {io_peripheralClk~CLKOUT~308~1}] -min -0.175 [get_ports {o_cam_scl_oe}]
set_input_delay -clock io_peripheralClk -reference_pin [get_ports {io_peripheralClk~CLKOUT~309~1}] -max 0.790 [get_ports {i_cam_sda}]
set_input_delay -clock io_peripheralClk -reference_pin [get_ports {io_peripheralClk~CLKOUT~309~1}] -min 0.395 [get_ports {i_cam_sda}]
set_output_delay -clock io_peripheralClk -reference_pin [get_ports {io_peripheralClk~CLKOUT~307~1}] -max 0.100 [get_ports {o_cam_sda_oe}]
set_output_delay -clock io_peripheralClk -reference_pin [get_ports {io_peripheralClk~CLKOUT~307~1}] -min -0.175 [get_ports {o_cam_sda_oe}]

# LVDS Tx Constraints
####################
set_output_delay -clock tx_slowclk -reference_pin [get_ports {tx_slowclk~CLKOUT~88~1}] -max 0.080 [get_ports {lvds_1a_DATA[6] lvds_1a_DATA[5] lvds_1a_DATA[4] lvds_1a_DATA[3] lvds_1a_DATA[2] lvds_1a_DATA[1] lvds_1a_DATA[0]}]
set_output_delay -clock tx_slowclk -reference_pin [get_ports {tx_slowclk~CLKOUT~88~1}] -min -0.080 [get_ports {lvds_1a_DATA[6] lvds_1a_DATA[5] lvds_1a_DATA[4] lvds_1a_DATA[3] lvds_1a_DATA[2] lvds_1a_DATA[1] lvds_1a_DATA[0]}]
set_output_delay -clock tx_slowclk -reference_pin [get_ports {tx_slowclk~CLKOUT~154~1}] -max 0.080 [get_ports {lvds_1b_DATA[6] lvds_1b_DATA[5] lvds_1b_DATA[4] lvds_1b_DATA[3] lvds_1b_DATA[2] lvds_1b_DATA[1] lvds_1b_DATA[0]}]
set_output_delay -clock tx_slowclk -reference_pin [get_ports {tx_slowclk~CLKOUT~154~1}] -min -0.080 [get_ports {lvds_1b_DATA[6] lvds_1b_DATA[5] lvds_1b_DATA[4] lvds_1b_DATA[3] lvds_1b_DATA[2] lvds_1b_DATA[1] lvds_1b_DATA[0]}]
set_output_delay -clock tx_slowclk -reference_pin [get_ports {tx_slowclk~CLKOUT~160~1}] -max 0.080 [get_ports {lvds_1c_DATA[6] lvds_1c_DATA[5] lvds_1c_DATA[4] lvds_1c_DATA[3] lvds_1c_DATA[2] lvds_1c_DATA[1] lvds_1c_DATA[0]}]
set_output_delay -clock tx_slowclk -reference_pin [get_ports {tx_slowclk~CLKOUT~160~1}] -min -0.080 [get_ports {lvds_1c_DATA[6] lvds_1c_DATA[5] lvds_1c_DATA[4] lvds_1c_DATA[3] lvds_1c_DATA[2] lvds_1c_DATA[1] lvds_1c_DATA[0]}]
set_output_delay -clock tx_slowclk -reference_pin [get_ports {tx_slowclk~CLKOUT~148~1}] -max 0.080 [get_ports {lvds_1d_DATA[6] lvds_1d_DATA[5] lvds_1d_DATA[4] lvds_1d_DATA[3] lvds_1d_DATA[2] lvds_1d_DATA[1] lvds_1d_DATA[0]}]
set_output_delay -clock tx_slowclk -reference_pin [get_ports {tx_slowclk~CLKOUT~148~1}] -min -0.080 [get_ports {lvds_1d_DATA[6] lvds_1d_DATA[5] lvds_1d_DATA[4] lvds_1d_DATA[3] lvds_1d_DATA[2] lvds_1d_DATA[1] lvds_1d_DATA[0]}]
set_output_delay -clock tx_slowclk -reference_pin [get_ports {tx_slowclk~CLKOUT~70~1}] -max 0.080 [get_ports {lvds_2a_DATA[6] lvds_2a_DATA[5] lvds_2a_DATA[4] lvds_2a_DATA[3] lvds_2a_DATA[2] lvds_2a_DATA[1] lvds_2a_DATA[0]}]
set_output_delay -clock tx_slowclk -reference_pin [get_ports {tx_slowclk~CLKOUT~70~1}] -min -0.080 [get_ports {lvds_2a_DATA[6] lvds_2a_DATA[5] lvds_2a_DATA[4] lvds_2a_DATA[3] lvds_2a_DATA[2] lvds_2a_DATA[1] lvds_2a_DATA[0]}]
set_output_delay -clock tx_slowclk -reference_pin [get_ports {tx_slowclk~CLKOUT~82~1}] -max 0.080 [get_ports {lvds_2b_DATA[6] lvds_2b_DATA[5] lvds_2b_DATA[4] lvds_2b_DATA[3] lvds_2b_DATA[2] lvds_2b_DATA[1] lvds_2b_DATA[0]}]
set_output_delay -clock tx_slowclk -reference_pin [get_ports {tx_slowclk~CLKOUT~82~1}] -min -0.080 [get_ports {lvds_2b_DATA[6] lvds_2b_DATA[5] lvds_2b_DATA[4] lvds_2b_DATA[3] lvds_2b_DATA[2] lvds_2b_DATA[1] lvds_2b_DATA[0]}]
set_output_delay -clock tx_slowclk -reference_pin [get_ports {tx_slowclk~CLKOUT~76~1}] -max 0.080 [get_ports {lvds_2c_DATA[6] lvds_2c_DATA[5] lvds_2c_DATA[4] lvds_2c_DATA[3] lvds_2c_DATA[2] lvds_2c_DATA[1] lvds_2c_DATA[0]}]
set_output_delay -clock tx_slowclk -reference_pin [get_ports {tx_slowclk~CLKOUT~76~1}] -min -0.080 [get_ports {lvds_2c_DATA[6] lvds_2c_DATA[5] lvds_2c_DATA[4] lvds_2c_DATA[3] lvds_2c_DATA[2] lvds_2c_DATA[1] lvds_2c_DATA[0]}]
set_output_delay -clock tx_slowclk -reference_pin [get_ports {tx_slowclk~CLKOUT~94~1}] -max 0.080 [get_ports {lvds_2d_DATA[6] lvds_2d_DATA[5] lvds_2d_DATA[4] lvds_2d_DATA[3] lvds_2d_DATA[2] lvds_2d_DATA[1] lvds_2d_DATA[0]}]
set_output_delay -clock tx_slowclk -reference_pin [get_ports {tx_slowclk~CLKOUT~94~1}] -min -0.080 [get_ports {lvds_2d_DATA[6] lvds_2d_DATA[5] lvds_2d_DATA[4] lvds_2d_DATA[3] lvds_2d_DATA[2] lvds_2d_DATA[1] lvds_2d_DATA[0]}]
set_output_delay -clock tx_slowclk -reference_pin [get_ports {tx_slowclk~CLKOUT~166~1}] -max 0.080 [get_ports {lvds_clk[6] lvds_clk[5] lvds_clk[4] lvds_clk[3] lvds_clk[2] lvds_clk[1] lvds_clk[0]}]
set_output_delay -clock tx_slowclk -reference_pin [get_ports {tx_slowclk~CLKOUT~166~1}] -min -0.080 [get_ports {lvds_clk[6] lvds_clk[5] lvds_clk[4] lvds_clk[3] lvds_clk[2] lvds_clk[1] lvds_clk[0]}]


#SD Card Related Constraints
##############################
set_output_delay -clock io_peripheralClk -reference_pin [get_ports {io_peripheralClk~CLKOUT~302~642}] -max 0.100 [get_ports {sd_clk_hi}]
set_output_delay -clock io_peripheralClk -reference_pin [get_ports {io_peripheralClk~CLKOUT~302~642}] -min -0.175 [get_ports {sd_clk_hi}]

#SPI Constraints
#########################
set_output_delay -clock io_systemClk -reference_pin [get_ports {io_systemClk~CLKOUT~1~43}] -max 0.610 [get_ports {system_spi_0_io_sclk_write}]
set_output_delay -clock io_systemClk -reference_pin [get_ports {io_systemClk~CLKOUT~1~43}] -min -0.085 [get_ports {system_spi_0_io_sclk_write}]
set_output_delay -clock io_systemClk -reference_pin [get_ports {io_systemClk~CLKOUT~1~41}] -max 0.610 [get_ports {system_spi_0_io_ss}]
set_output_delay -clock io_systemClk -reference_pin [get_ports {io_systemClk~CLKOUT~1~41}] -min -0.085 [get_ports {system_spi_0_io_ss}]
set_input_delay -clock io_systemClk -reference_pin [get_ports {io_systemClk~CLKOUT~1~66}] -max 0.858 [get_ports {system_spi_0_io_data_0_read}]
set_input_delay -clock io_systemClk -reference_pin [get_ports {io_systemClk~CLKOUT~1~66}] -min 0.429 [get_ports {system_spi_0_io_data_0_read}]
set_output_delay -clock io_systemClk -reference_pin [get_ports {io_systemClk~CLKOUT~1~67}] -max 0.610 [get_ports {system_spi_0_io_data_0_write}]
set_output_delay -clock io_systemClk -reference_pin [get_ports {io_systemClk~CLKOUT~1~67}] -min -0.085 [get_ports {system_spi_0_io_data_0_write}]
set_output_delay -clock io_systemClk -reference_pin [get_ports {io_systemClk~CLKOUT~1~67}] -max 0.603 [get_ports {system_spi_0_io_data_0_writeEnable}]
set_output_delay -clock io_systemClk -reference_pin [get_ports {io_systemClk~CLKOUT~1~67}] -min -0.087 [get_ports {system_spi_0_io_data_0_writeEnable}]
set_input_delay -clock io_systemClk -reference_pin [get_ports {io_systemClk~CLKOUT~1~69}] -max 0.858 [get_ports {system_spi_0_io_data_1_read}]
set_input_delay -clock io_systemClk -reference_pin [get_ports {io_systemClk~CLKOUT~1~69}] -min 0.429 [get_ports {system_spi_0_io_data_1_read}]
set_output_delay -clock io_systemClk -reference_pin [get_ports {io_systemClk~CLKOUT~1~70}] -max 0.610 [get_ports {system_spi_0_io_data_1_write}]
set_output_delay -clock io_systemClk -reference_pin [get_ports {io_systemClk~CLKOUT~1~70}] -min -0.085 [get_ports {system_spi_0_io_data_1_write}]
set_output_delay -clock io_systemClk -reference_pin [get_ports {io_systemClk~CLKOUT~1~70}] -max 0.603 [get_ports {system_spi_0_io_data_1_writeEnable}]
set_output_delay -clock io_systemClk -reference_pin [get_ports {io_systemClk~CLKOUT~1~70}] -min -0.087 [get_ports {system_spi_0_io_data_1_writeEnable}]

#TSEMAC Related Constraints
#########################
set_output_delay -clock io_tseClk -reference_pin [get_ports {io_tseClk~CLKOUT~21~642}] -max 0.100 [get_ports {rgmii_tx_ctl}]
set_output_delay -clock io_tseClk -reference_pin [get_ports {io_tseClk~CLKOUT~21~642}] -min -0.175 [get_ports {rgmii_tx_ctl}]
set_input_delay -clock rgmii_rxc -reference_pin [get_ports {rgmii_rxc~CLKOUT~24~642}] -max 0.620 [get_ports {rgmii_rx_ctl}]
set_input_delay -clock rgmii_rxc -reference_pin [get_ports {rgmii_rxc~CLKOUT~24~642}] -min 0.310 [get_ports {rgmii_rx_ctl}]
set_input_delay -clock rgmii_rxc -reference_pin [get_ports {rgmii_rxc~CLKOUT~1~362}] -max 0.858 [get_ports {rgmii_rxd_LO[0] rgmii_rxd_HI[0]}]
set_input_delay -clock rgmii_rxc -reference_pin [get_ports {rgmii_rxc~CLKOUT~1~362}] -min 0.429 [get_ports {rgmii_rxd_LO[0] rgmii_rxd_HI[0]}]
set_input_delay -clock rgmii_rxc -reference_pin [get_ports {rgmii_rxc~CLKOUT~1~364}] -max 0.858 [get_ports {rgmii_rxd_LO[1] rgmii_rxd_HI[1]}]
set_input_delay -clock rgmii_rxc -reference_pin [get_ports {rgmii_rxc~CLKOUT~1~364}] -min 0.429 [get_ports {rgmii_rxd_LO[1] rgmii_rxd_HI[1]}]
set_input_delay -clock rgmii_rxc -reference_pin [get_ports {rgmii_rxc~CLKOUT~1~366}] -max 0.858 [get_ports {rgmii_rxd_LO[2] rgmii_rxd_HI[2]}]
set_input_delay -clock rgmii_rxc -reference_pin [get_ports {rgmii_rxc~CLKOUT~1~366}] -min 0.429 [get_ports {rgmii_rxd_LO[2] rgmii_rxd_HI[2]}]
set_input_delay -clock rgmii_rxc -reference_pin [get_ports {rgmii_rxc~CLKOUT~1~375}] -max 0.858 [get_ports {rgmii_rxd_LO[3] rgmii_rxd_HI[3]}]
set_input_delay -clock rgmii_rxc -reference_pin [get_ports {rgmii_rxc~CLKOUT~1~375}] -min 0.429 [get_ports {rgmii_rxd_LO[3] rgmii_rxd_HI[3]}]
set_output_delay -clock io_tseClk_90 -reference_pin [get_ports {io_tseClk_90~CLKOUT~1~292}] -max 0.610 [get_ports {rgmii_txc_LO rgmii_txc_HI}]
set_output_delay -clock io_tseClk_90 -reference_pin [get_ports {io_tseClk_90~CLKOUT~1~292}] -min -0.085 [get_ports {rgmii_txc_LO rgmii_txc_HI}]
set_output_delay -clock io_tseClk -reference_pin [get_ports {io_tseClk~CLKOUT~1~311}] -max 0.610 [get_ports {rgmii_txd_LO[0] rgmii_txd_HI[0]}]
set_output_delay -clock io_tseClk -reference_pin [get_ports {io_tseClk~CLKOUT~1~311}] -min -0.085 [get_ports {rgmii_txd_LO[0] rgmii_txd_HI[0]}]
set_output_delay -clock io_tseClk -reference_pin [get_ports {io_tseClk~CLKOUT~1~313}] -max 0.610 [get_ports {rgmii_txd_LO[1] rgmii_txd_HI[1]}]
set_output_delay -clock io_tseClk -reference_pin [get_ports {io_tseClk~CLKOUT~1~313}] -min -0.085 [get_ports {rgmii_txd_LO[1] rgmii_txd_HI[1]}]
set_output_delay -clock io_tseClk -reference_pin [get_ports {io_tseClk~CLKOUT~1~331}] -max 0.610 [get_ports {rgmii_txd_LO[2] rgmii_txd_HI[2]}]
set_output_delay -clock io_tseClk -reference_pin [get_ports {io_tseClk~CLKOUT~1~331}] -min -0.085 [get_ports {rgmii_txd_LO[2] rgmii_txd_HI[2]}]
set_output_delay -clock io_tseClk -reference_pin [get_ports {io_tseClk~CLKOUT~1~358}] -max 0.610 [get_ports {rgmii_txd_LO[3] rgmii_txd_HI[3]}]
set_output_delay -clock io_tseClk -reference_pin [get_ports {io_tseClk~CLKOUT~1~358}] -min -0.085 [get_ports {rgmii_txd_LO[3] rgmii_txd_HI[3]}]

# MIPI RX Constraints
#####################################
set_output_delay -clock mipi_pclk -reference_pin [get_ports {mipi_pclk~CLKOUT~337~581}] -max 0.564 [get_ports {mipi_inst1_VC_ENA[3] mipi_inst1_VC_ENA[2] mipi_inst1_VC_ENA[1] mipi_inst1_VC_ENA[0]}]
set_output_delay -clock mipi_pclk -reference_pin [get_ports {mipi_pclk~CLKOUT~337~581}] -min -0.069 [get_ports {mipi_inst1_VC_ENA[3] mipi_inst1_VC_ENA[2] mipi_inst1_VC_ENA[1] mipi_inst1_VC_ENA[0]}]
set_output_delay -clock mipi_pclk -reference_pin [get_ports {mipi_pclk~CLKOUT~337~581}] -max 0.113 [get_ports {mipi_inst1_CLEAR}]
set_output_delay -clock mipi_pclk -reference_pin [get_ports {mipi_pclk~CLKOUT~337~581}] -min -0.157 [get_ports {mipi_inst1_CLEAR}]
set_input_delay -clock mipi_pclk -reference_pin [get_ports {mipi_pclk~CLKOUT~337~581}] -max 1.084 [get_ports {mipi_inst1_VSYNC[3] mipi_inst1_VSYNC[2] mipi_inst1_VSYNC[1] mipi_inst1_VSYNC[0]}]
set_input_delay -clock mipi_pclk -reference_pin [get_ports {mipi_pclk~CLKOUT~337~581}] -min 0.542 [get_ports {mipi_inst1_VSYNC[3] mipi_inst1_VSYNC[2] mipi_inst1_VSYNC[1] mipi_inst1_VSYNC[0]}]
set_input_delay -clock mipi_pclk -reference_pin [get_ports {mipi_pclk~CLKOUT~337~581}] -max 1.078 [get_ports {mipi_inst1_HSYNC[3] mipi_inst1_HSYNC[2] mipi_inst1_HSYNC[1] mipi_inst1_HSYNC[0]}]
set_input_delay -clock mipi_pclk -reference_pin [get_ports {mipi_pclk~CLKOUT~337~581}] -min 0.539 [get_ports {mipi_inst1_HSYNC[3] mipi_inst1_HSYNC[2] mipi_inst1_HSYNC[1] mipi_inst1_HSYNC[0]}]
set_input_delay -clock mipi_pclk -reference_pin [get_ports {mipi_pclk~CLKOUT~337~581}] -max 0.932 [get_ports {mipi_inst1_VALID}]
set_input_delay -clock mipi_pclk -reference_pin [get_ports {mipi_pclk~CLKOUT~337~581}] -min 0.466 [get_ports {mipi_inst1_VALID}]
set_input_delay -clock mipi_pclk -reference_pin [get_ports {mipi_pclk~CLKOUT~337~581}] -max 1.002 [get_ports {mipi_inst1_CNT[3] mipi_inst1_CNT[2] mipi_inst1_CNT[1] mipi_inst1_CNT[0]}]
set_input_delay -clock mipi_pclk -reference_pin [get_ports {mipi_pclk~CLKOUT~337~581}] -min 0.501 [get_ports {mipi_inst1_CNT[3] mipi_inst1_CNT[2] mipi_inst1_CNT[1] mipi_inst1_CNT[0]}]
set_input_delay -clock mipi_pclk -reference_pin [get_ports {mipi_pclk~CLKOUT~337~581}] -max 1.030 [get_ports {mipi_inst1_DATA[*]}]
set_input_delay -clock mipi_pclk -reference_pin [get_ports {mipi_pclk~CLKOUT~337~581}] -min 0.515 [get_ports {mipi_inst1_DATA[*]}]
set_input_delay -clock mipi_pclk -reference_pin [get_ports {mipi_pclk~CLKOUT~337~581}] -max 0.947 [get_ports {mipi_inst1_ERROR[*]}]
set_input_delay -clock mipi_pclk -reference_pin [get_ports {mipi_pclk~CLKOUT~337~581}] -min 0.473 [get_ports {mipi_inst1_ERROR[*]}]
set_input_delay -clock mipi_pclk -reference_pin [get_ports {mipi_pclk~CLKOUT~337~581}] -max 0.945 [get_ports {mipi_inst1_ULPS_CLK}]
set_input_delay -clock mipi_pclk -reference_pin [get_ports {mipi_pclk~CLKOUT~337~581}] -min 0.472 [get_ports {mipi_inst1_ULPS_CLK}]
set_input_delay -clock mipi_pclk -reference_pin [get_ports {mipi_pclk~CLKOUT~337~581}] -max 0.954 [get_ports {mipi_inst1_ULPS[3] mipi_inst1_ULPS[2] mipi_inst1_ULPS[1] mipi_inst1_ULPS[0]}]
set_input_delay -clock mipi_pclk -reference_pin [get_ports {mipi_pclk~CLKOUT~337~581}] -min 0.477 [get_ports {mipi_inst1_ULPS[3] mipi_inst1_ULPS[2] mipi_inst1_ULPS[1] mipi_inst1_ULPS[0]}]

# JTAG Constraints
####################
set_output_delay -clock jtag_inst1_TCK -max 0.111 [get_ports {jtag_inst1_TDO}]
set_output_delay -clock jtag_inst1_TCK -min -0.053 [get_ports {jtag_inst1_TDO}]
set_input_delay -clock_fall -clock jtag_inst1_TCK -max 0.267 [get_ports {jtag_inst1_CAPTURE}]
set_input_delay -clock_fall -clock jtag_inst1_TCK -min 0.134 [get_ports {jtag_inst1_CAPTURE}]
set_input_delay -clock_fall -clock jtag_inst1_TCK -max 0.267 [get_ports {jtag_inst1_RESET}]
set_input_delay -clock_fall -clock jtag_inst1_TCK -min 0.134 [get_ports {jtag_inst1_RESET}]
set_input_delay -clock_fall -clock jtag_inst1_TCK -max 0.231 [get_ports {jtag_inst1_SEL}]
set_input_delay -clock_fall -clock jtag_inst1_TCK -min 0.116 [get_ports {jtag_inst1_SEL}]
set_input_delay -clock_fall -clock jtag_inst1_TCK -max 0.267 [get_ports {jtag_inst1_UPDATE}]
set_input_delay -clock_fall -clock jtag_inst1_TCK -min 0.134 [get_ports {jtag_inst1_UPDATE}]
set_input_delay -clock_fall -clock jtag_inst1_TCK -max 0.321 [get_ports {jtag_inst1_SHIFT}]
set_input_delay -clock_fall -clock jtag_inst1_TCK -min 0.161 [get_ports {jtag_inst1_SHIFT}]

# DDR Constraints
#####################
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~166}] -max 2.500 [get_ports {io_ddrB_arw_payload_addr[*]}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~166}] -min -0.400 [get_ports {io_ddrB_arw_payload_addr[*]}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~166}] -max 2.500 [get_ports {io_ddrB_arw_payload_burst[1] io_ddrB_arw_payload_burst[0]}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~166}] -min -0.400 [get_ports {io_ddrB_arw_payload_burst[1] io_ddrB_arw_payload_burst[0]}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~166}] -max 2.500 [get_ports {io_ddrB_arw_payload_id[*]}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~166}] -min -0.400 [get_ports {io_ddrB_arw_payload_id[*]}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~166}] -max 2.500 [get_ports {io_ddrB_arw_payload_len[*]}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~166}] -min -0.400 [get_ports {io_ddrB_arw_payload_len[*]}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~166}] -max 2.500 [get_ports {io_ddrB_arw_payload_lock[1] io_ddrB_arw_payload_lock[0]}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~166}] -min -0.400 [get_ports {io_ddrB_arw_payload_lock[1] io_ddrB_arw_payload_lock[0]}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~166}] -max 2.500 [get_ports {io_ddrB_arw_payload_size[2] io_ddrB_arw_payload_size[1] io_ddrB_arw_payload_size[0]}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~166}] -min -0.400 [get_ports {io_ddrB_arw_payload_size[2] io_ddrB_arw_payload_size[1] io_ddrB_arw_payload_size[0]}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~166}] -max 2.500 [get_ports {io_ddrB_arw_payload_write}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~166}] -min -0.400 [get_ports {io_ddrB_arw_payload_write}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~166}] -max 2.500 [get_ports {io_ddrB_arw_valid}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~166}] -min -0.400 [get_ports {io_ddrB_arw_valid}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~166}] -max 2.500 [get_ports {io_ddrB_b_ready}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~166}] -min -0.400 [get_ports {io_ddrB_b_ready}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~166}] -max 2.500 [get_ports {io_ddrB_r_ready}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~166}] -min -0.400 [get_ports {io_ddrB_r_ready}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~166}] -max 2.500 [get_ports {io_ddrB_w_payload_data[*]}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~166}] -min -0.400 [get_ports {io_ddrB_w_payload_data[*]}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~166}] -max 2.500 [get_ports {io_ddrB_w_payload_id[*]}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~166}] -min -0.400 [get_ports {io_ddrB_w_payload_id[*]}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~166}] -max 2.500 [get_ports {io_ddrB_w_payload_last}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~166}] -min -0.400 [get_ports {io_ddrB_w_payload_last}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~166}] -max 2.500 [get_ports {io_ddrB_w_payload_strb[*]}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~166}] -min -0.400 [get_ports {io_ddrB_w_payload_strb[*]}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~166}] -max 2.500 [get_ports {io_ddrB_w_valid}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~166}] -min -0.400 [get_ports {io_ddrB_w_valid}]
set_input_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~166}] -max 3.000 [get_ports {io_ddrB_arw_ready}]
set_input_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~166}] -min 1.500 [get_ports {io_ddrB_arw_ready}]
set_input_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~166}] -max 3.000 [get_ports {io_ddrB_b_payload_id[*]}]
set_input_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~166}] -min 1.500 [get_ports {io_ddrB_b_payload_id[*]}]
set_input_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~166}] -max 3.000 [get_ports {io_ddrB_b_valid}]
set_input_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~166}] -min 1.500 [get_ports {io_ddrB_b_valid}]
set_input_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~166}] -max 3.000 [get_ports {io_ddrB_r_payload_data[*]}]
set_input_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~166}] -min 1.500 [get_ports {io_ddrB_r_payload_data[*]}]
set_input_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~166}] -max 3.000 [get_ports {io_ddrB_r_payload_id[*]}]
set_input_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~166}] -min 1.500 [get_ports {io_ddrB_r_payload_id[*]}]
set_input_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~166}] -max 3.000 [get_ports {io_ddrB_r_payload_last}]
set_input_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~166}] -min 1.500 [get_ports {io_ddrB_r_payload_last}]
set_input_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~166}] -max 3.000 [get_ports {io_ddrB_r_payload_resp[1] io_ddrB_r_payload_resp[0]}]
set_input_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~166}] -min 1.500 [get_ports {io_ddrB_r_payload_resp[1] io_ddrB_r_payload_resp[0]}]
set_input_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~166}] -max 3.000 [get_ports {io_ddrB_r_valid}]
set_input_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~166}] -min 1.500 [get_ports {io_ddrB_r_valid}]
set_input_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~166}] -max 3.000 [get_ports {io_ddrB_w_ready}]
set_input_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~166}] -min 1.500 [get_ports {io_ddrB_w_ready}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~282}] -max 2.500 [get_ports {io_ddrA_arw_payload_addr[*]}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~282}] -min -0.400 [get_ports {io_ddrA_arw_payload_addr[*]}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~282}] -max 2.500 [get_ports {io_ddrA_arw_payload_burst[1] io_ddrA_arw_payload_burst[0]}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~282}] -min -0.400 [get_ports {io_ddrA_arw_payload_burst[1] io_ddrA_arw_payload_burst[0]}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~282}] -max 2.500 [get_ports {io_ddrA_arw_payload_id[*]}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~282}] -min -0.400 [get_ports {io_ddrA_arw_payload_id[*]}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~282}] -max 2.500 [get_ports {io_ddrA_arw_payload_len[*]}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~282}] -min -0.400 [get_ports {io_ddrA_arw_payload_len[*]}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~282}] -max 2.500 [get_ports {io_ddrA_arw_payload_lock[1] io_ddrA_arw_payload_lock[0]}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~282}] -min -0.400 [get_ports {io_ddrA_arw_payload_lock[1] io_ddrA_arw_payload_lock[0]}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~282}] -max 2.500 [get_ports {io_ddrA_arw_payload_size[2] io_ddrA_arw_payload_size[1] io_ddrA_arw_payload_size[0]}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~282}] -min -0.400 [get_ports {io_ddrA_arw_payload_size[2] io_ddrA_arw_payload_size[1] io_ddrA_arw_payload_size[0]}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~282}] -max 2.500 [get_ports {io_ddrA_arw_payload_write}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~282}] -min -0.400 [get_ports {io_ddrA_arw_payload_write}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~282}] -max 2.500 [get_ports {io_ddrA_arw_valid}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~282}] -min -0.400 [get_ports {io_ddrA_arw_valid}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~282}] -max 2.500 [get_ports {io_ddrA_b_ready}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~282}] -min -0.400 [get_ports {io_ddrA_b_ready}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~282}] -max 2.500 [get_ports {io_ddrA_r_ready}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~282}] -min -0.400 [get_ports {io_ddrA_r_ready}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~282}] -max 2.500 [get_ports {io_ddrA_w_payload_data[*]}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~282}] -min -0.400 [get_ports {io_ddrA_w_payload_data[*]}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~282}] -max 2.500 [get_ports {io_ddrA_w_payload_id[*]}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~282}] -min -0.400 [get_ports {io_ddrA_w_payload_id[*]}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~282}] -max 2.500 [get_ports {io_ddrA_w_payload_last}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~282}] -min -0.400 [get_ports {io_ddrA_w_payload_last}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~282}] -max 2.500 [get_ports {io_ddrA_w_payload_strb[*]}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~282}] -min -0.400 [get_ports {io_ddrA_w_payload_strb[*]}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~282}] -max 2.500 [get_ports {io_ddrA_w_valid}]
set_output_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~282}] -min -0.400 [get_ports {io_ddrA_w_valid}]
set_input_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~282}] -max 3.000 [get_ports {io_ddrA_arw_ready}]
set_input_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~282}] -min 1.500 [get_ports {io_ddrA_arw_ready}]
set_input_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~282}] -max 3.000 [get_ports {io_ddrA_b_payload_id[*]}]
set_input_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~282}] -min 1.500 [get_ports {io_ddrA_b_payload_id[*]}]
set_input_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~282}] -max 3.000 [get_ports {io_ddrA_b_valid}]
set_input_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~282}] -min 1.500 [get_ports {io_ddrA_b_valid}]
set_input_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~282}] -max 3.000 [get_ports {io_ddrA_r_payload_data[*]}]
set_input_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~282}] -min 1.500 [get_ports {io_ddrA_r_payload_data[*]}]
set_input_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~282}] -max 3.000 [get_ports {io_ddrA_r_payload_id[*]}]
set_input_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~282}] -min 1.500 [get_ports {io_ddrA_r_payload_id[*]}]
set_input_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~282}] -max 3.000 [get_ports {io_ddrA_r_payload_last}]
set_input_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~282}] -min 1.500 [get_ports {io_ddrA_r_payload_last}]
set_input_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~282}] -max 3.000 [get_ports {io_ddrA_r_payload_resp[1] io_ddrA_r_payload_resp[0]}]
set_input_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~282}] -min 1.500 [get_ports {io_ddrA_r_payload_resp[1] io_ddrA_r_payload_resp[0]}]
set_input_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~282}] -max 3.000 [get_ports {io_ddrA_r_valid}]
set_input_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~282}] -min 1.500 [get_ports {io_ddrA_r_valid}]
set_input_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~282}] -max 3.000 [get_ports {io_ddrA_w_ready}]
set_input_delay -clock io_memoryClk -reference_pin [get_ports {io_memoryClk~CLKOUT~337~282}] -min 1.500 [get_ports {io_ddrA_w_ready}]




