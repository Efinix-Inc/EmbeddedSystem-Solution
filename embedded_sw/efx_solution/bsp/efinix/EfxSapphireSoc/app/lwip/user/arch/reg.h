/*
 * reg.h
 *
 *  Created on: Jul 24, 2020
 *      Author: shchung
 */

#ifndef SRC_REG_H_
#define SRC_REG_H_

//MAC Configuration Registers
#define VERSION 			0x0000
#define COMMAND_CONFIG		0x0008
#define MAC_ADDR_LO			0x000C
#define MAC_ADDR_HI			0x0010
#define FRM_LENGHT			0x0014
#define PAUSE_QUANT			0x0018
#define TX_IPG_LEN			0x005C

//MDIO Configuration Registers
#define	DIVIDER_PRE			0x0100
#define	RD_WR_EN			0x0104
#define	REG_PHY_ADDR		0x0108
#define	WR_DATA				0x010C
#define	RD_DATA				0x0110
#define	STATUS				0x0114

//Receive Supplementary Registers
#define	BOARD_FILTER_EN		0x0140
#define	MAC_ADDR_MAKE_LO	0x0144
#define	MAC_ADDR_MAKE_HI	0x0148
#define TX_DST_ADDR_INS		0x0180
#define DST_MAC_ADDR_LO		0x0184
#define	DST_MAC_ADDR_HI		0x0188

//Statistic Counter Registers
#define	A_FRAME_TRANSMITTED_OK		0x0068
#define	A_FRAME_RECEIVED_OK			0x006C
#define	A_FRAME_CHECK_SEQ_ERR		0x0070
#define	A_TX_PAUSE_MAC_CTRL_FRAME	0x0080
#define	A_RX_PAUSE_MAC_CTRL_FRAME	0x0084
#define	IF_INDICATES_ERROR			0x0088
#define	IF_OUT_ERROR				0x008C
#define	A_RX_FILTER_FRAMES_ERROR	0x009C
#define	ETHER_STATS_PKTS			0x00B4
#define	ETHER_STATS_UNDER_SIZE_PKTS	0x00B8
#define	ETHER_STATS_OVERSIZE_PKTS	0x00BC
#define	ETHER_PACKET_LENS			0x00C0


//Example Design Configuration Registers

#define	MAC_SW_RST					0x0200	//[0] mac_sw_rst
#define MUX_SELECT					0x0204	//[1] pat_mux_select [0] axi4_st_mux_select
#define UDP_MAC_PAT_GEN_EN			0x0208	//[1] mac_pat_gen_en [0] udp_pat_gen_en
#define PAT_GEN_NUM_IPG				0x020C	//[15:0] pat_gen_num [31:16] pat_gen_ipg
#define PAT_DST_MAC_LO				0x0210	//[31:0] pat_dst_mac
#define PAT_DST_MAC_HI				0x0214	//[47:32] pat_dst_mac
#define PAT_SRC_MAC_LO				0x0218	//[31:0] pat_src_mac
#define PAT_SRC_MAC_HI				0x021C	//[47:32] pat_src_mac
#define PAT_MAC_DLEN				0x0220	//[15:0] pat_mac_dlen
#define PAT_SRC_IP					0x0224	//[31:0] pat_src_ip
#define PAT_DST_IP					0x0228	//[31:0] pat_dst_ip
#define PAT_SRC_DST_PORT			0x022C	//[31:16] pat_dst_port [15:0] pat_src_port
#define PAT_UDP_DLEN				0x0230	//[15:0] pat_udp_dlen




#endif /* SRC_REG_H_ */
