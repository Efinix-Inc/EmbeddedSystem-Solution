////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2024 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////
#pragma once

#include "bsp.h"
#include "device_config.h"
#include "userDef.h"
#include "efx_tse_mac.h"

#define RTL8211F_RX_DELAY			BIT_3

/************************** Function File ***************************/
static void Phy_Wr(u32 RegAddr, u32 Data)
{
    write_u32(((PHY_ADDR&0x1f)<<8)|(RegAddr&0x1f), (TSEMAC_BASE+REG_PHY_ADDR));
    write_u32(Data, (TSEMAC_BASE+WR_DATA));
    write_u32(0x2, (TSEMAC_BASE+RD_WR_EN));
    bsp_uDelay(1000);
    if(DEBUG_PRINTF_EN == 1) {
        bsp_printf("Wr Phy Addr :%x \r\n", RegAddr);
        bsp_printf("Wr Phy Data :%x \r\n ", Data);
    }
}

static u32 Phy_Rd(u32 RegAddr)
{
    u32 Value;
    write_u32(((PHY_ADDR&0x1f)<<8)|(RegAddr&0x1f), (TSEMAC_BASE+REG_PHY_ADDR));
    write_u32(0x1, (TSEMAC_BASE+RD_WR_EN));
    bsp_uDelay(1000);
    Value = read_u32(TSEMAC_BASE+RD_DATA);
    if(DEBUG_PRINTF_EN == 1) {
        bsp_printf("Rd Phy Addr :%x \r\n ", RegAddr);
        bsp_printf("Return Value :%x \r\n ", Value);
    }
    return Value;
}

static void disable_1000Mbps()
{
	u32 value;
	value = Phy_Rd(0x09);
	value &= 0xFCFF;
	Phy_Wr(0x09,value);
}

static u32 Phy_identification() //True if the ethernet driver is rtl8211
{
	if(DEBUG_PRINTF_EN == 1) bsp_printf("PHY ID: %x\r\n",Phy_Rd(2));
	if (Phy_Rd(2)==0x1c) bsp_printf("Info: RTL82111F eth driver (Ti180/ Ti375) is detected.\r\n");
	else if (Phy_Rd(2)==0x6e)
		{
			bsp_printf("Info: DM9119 eth driver (T120) is detected.\r\n");
			bsp_printf("Info: Phy Link Up 1000Mbps is disabled.\r\n");
			disable_1000Mbps();
		}
	else
	{
		bsp_printf("Info: No supported phy is detected\r\nPlease check the phy hardware setting...");
		while(1){};
	}

	return (Phy_Rd(2)==0x1c)?1:0;
}



/************************** Function File ***************************/
static void PhyDlySetRXTX(int RX_delay, int TX_delay)
{
    u32 Value;
    if(DEBUG_PRINTF_EN == 1) bsp_printf("Start Info : Set Phy Delay.\r\n");
    Phy_Wr(0x1F,0x0168);
    Phy_Wr(0x1E,0x8040);
    Phy_Wr(0x1E,0x401E);

    Value = Phy_Rd(0x1F) & 0xFFFF;

    Value &= 0xFF00;
    RX_delay &= 0xF;
    TX_delay &= 0xF;
    if(DEBUG_PRINTF_EN == 1) bsp_printf("Setup New Value =%x \r\n", RX_delay);

    Value = ((Value) | (RX_delay<<4) | (TX_delay));
    Phy_Wr(0x1F,Value);
    Phy_Wr(0x1E,0x801E);
    Phy_Wr(0x1E,0x401E);
    Value = Phy_Rd(0x1F) & 0xFFFF;
    if(DEBUG_PRINTF_EN == 1) bsp_printf("Read New Value =%x \r\n", Value);
}

/************************** Function File ***************************/
static u32 PhyNormalInit()
{
	PhyDlySetRXTX(15, 8);

	u32 Value;
	if(DEBUG_PRINTF_EN == 1) {
		bsp_printf("Info: Wait Ethernet Link up...");
	}
    // to read Basic control
	Phy_Rd(0x0); 
    // to read phy ID
	Phy_Rd(0x2); 
    // to read phy ID
	Phy_Rd(0x3); 

	//Unlock Extended registers
	Phy_Wr(0x1f, 0x0168);
	Phy_Wr(0x1e, 0x8040);

	while(1) {
		Value = Phy_Rd(0x11);
        //Link up and DUPLEX mode
		if((Value&0x2400) == 0x2400) {
			if((Value&0xc000) == 0x8000) {          //1000Mbps
				{
					bsp_printf("Info: Phy Link up on 1000Mbps.\r\n");
				}
				return 0x4;
			} else if((Value&0xc000) == 0x4000) {   //100Mbps
				{
					bsp_printf("Info: Phy Link up on 100Mbps.\r\n");
				}
				return 0x2;
			} else if((Value&0xc000) == 0x0) {      //10Mbps
				{
					bsp_printf("Info: Phy Link up on 10Mbps.\r\n");
				}
				return 0x1;
			}
		}
		bsp_uDelay(100000);
	}
}

/************************** Function File ***************************/
static void PhyLoopInit(u32 speed)
{
	PhyDlySetRXTX(15, 15);
	u32 Value;
	if(speed == 0x4) {
		Phy_Wr(0x0, 0x4140);
		if(DEBUG_PRINTF_EN == 1) {
			bsp_printf("Info: Set Phy 1000Mbps Loopback Mode.\r\n");
		}
	} else if(speed == 0x2) {
		Phy_Wr(0x0, 0x6100);
		if(DEBUG_PRINTF_EN == 1) {
			bsp_printf("Info: Set Phy 100Mbps Loopback Mode.\r\n");
		}
	} else if(speed == 0x1) {
		Phy_Wr(0x0, 0x4100);
		if(DEBUG_PRINTF_EN == 1) {
			bsp_printf("Info: Set Phy 10Mbps Loopback Mode.\r\n");
		}
	}
}

static u32 PhyGetSpeed()
{
	u32 Value;
	if(DEBUG_PRINTF_EN == 1) {
		bsp_printf("Info: Wait Ethernet Link up...\r\n");
	}


	while(1) {
		Value = Phy_Rd(0x11);
        //Link up and DUPLEX mode
		if((Value&0x2400) == 0x2400) {
			if((Value&0xc000) == 0x8000) {          //1000Mbps
				if(DEBUG_PRINTF_EN == 1) {
					bsp_printf("Info: Phy Link up on 1000Mbps.\r\n");
				}
				return 0x4;
			} else if((Value&0xc000) == 0x4000) {   //100Mbps
				if(DEBUG_PRINTF_EN == 1) {
					bsp_printf("Info: Phy Link up on 100Mbps.\r\n");
				}
				return 0x2;
			} else if((Value&0xc000) == 0x0) {      //10Mbps
				if(DEBUG_PRINTF_EN == 1) {
					bsp_printf("Info: Phy Link up on 10Mbps.\r\n");
				}
				return 0x1;
			}
		}
		bsp_uDelay(100000);
	}
}

static u32 Phy_Rd_normal(u32 RegAddr)
{
    u32 Value;
    write_u32(((PHY_ADDR&0x1f)<<8)|(RegAddr&0x1f), (TSEMAC_BASE+0x108));
    write_u32(0x1, (TSEMAC_BASE+0x104));
    bsp_uDelay(1000);
    Value = read_u32(TSEMAC_BASE+0x110);

    return Value;
}


/************************** Titanium (rtl18211 ethernet driver) ***************************/

static int rtl8211_drv_rddata(int addr)
{
	 return Phy_Rd(addr);
}

static void rtl8211_drv_wrdata(int addr ,int data)
{
	 Phy_Wr(addr,data);
	 bsp_uDelay(100);
}

static void rtl8211_drv_setpage(int page)
{
	 Phy_Wr(31,page & 0xFFFF);
	 bsp_uDelay(100);
}

static int rtl8211_drv_linkup(void)
{
	int phy_reg=0;
	int speed=TSE_Speed_1000Mhz;

	/* Below to fix 1000mbps fail to ping intermittently when power cycle */
	// 1000mbps control register
	int ctrl_reg = 0;
	ctrl_reg=rtl8211_drv_rddata(9);
	rtl8211_drv_wrdata(0x09,ctrl_reg|0x1800 );

	ctrl_reg=rtl8211_drv_rddata(9);
	/* Above to fix 1000mbps fail to ping intermittently when power cycle */
	phy_reg=rtl8211_drv_rddata(26);

	 while(1)
	{
		phy_reg=rtl8211_drv_rddata(26);

		if(phy_reg & 0x04)
		{
			bsp_printf("Info: Linked Up\r\n");
			break;
		}

		bsp_uDelay(1000000); /* To fix 1000mbps fail to ping intermittently when power cycle */
	}

	if((phy_reg & 0x30) == 0x20)
	{
		if(phy_reg & 0x08)
			bsp_printf("Info: Link Partner Full duplex 1000 Mbps\n\r\n\r");
		else
			bsp_printf("Info: Link Partner half duplex 1000 Mbps\n\r\n\r");
		speed = TSE_Speed_1000Mhz;
	}
	else if((phy_reg & 0x30) == 0x10)
	{
		if(phy_reg & 0x08)
			bsp_printf("Info: Link Partner Full duplex 100 Mbps\n\r\n\r");
		else
			bsp_printf("Info: Link Partner half duplex 100 Mbps\n\r\n\r");
		speed = TSE_Speed_100Mhz;
	}
	else if((phy_reg & 0x30) == 0)
	{
		if(phy_reg & 0x08)
			bsp_printf("Info: Link Partner Full duplex 10 Mbps\n\r\n\r");
		else
			bsp_printf("Info: Link Partner half duplex 10 Mbps\n\r\n\r");
		speed = TSE_Speed_10Mhz;
	}

	return speed;
}

static void rtl8211_drv_init(void)
{
	rtl8211_drv_setpage(0);
	rtl8211_drv_wrdata(0,0x9000);
	bsp_uDelay(1000*50);
	rtl8211_drv_wrdata(0,0x1000);
	bsp_uDelay(1000*50);

	rtl8211_drv_setpage(0x0A43);
	rtl8211_drv_wrdata(27,0x8011);
	rtl8211_drv_wrdata(28,0xD73F);
//	bsp_uDelay(1000*50);

	rtl8211_drv_setpage(0xD04);
	rtl8211_drv_wrdata(0x10,0x820B);
//	bsp_uDelay(1000*50);

	rtl8211_drv_setpage(0x0D08);
	rtl8211_drv_wrdata(0x15, 0 & RTL8211F_RX_DELAY);
//	bsp_uDelay(1000*50);
}
