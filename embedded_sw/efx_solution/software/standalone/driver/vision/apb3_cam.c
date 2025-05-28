#include "apb3_cam.h"

u32 example_register_read(u16 reg)
{
	u32 rdata;
	rdata = EXAMPLE_APB3_REGR(EXAMPLE_APB3_SLV, reg);
	return rdata;
}

void Set_RGBGain(u8 ena, u8 R, u8 G, u8 B)
{
	u32 data = ((B & 0x7)<<12)|((G & 0x7)<<8)|((R & 0x7)<<4)|(ena&0x1);

	EXAMPLE_APB3_REGW(EXAMPLE_APB3_SLV, EXAMPLE_APB3_SLV_REG0_OFFSET, data);
	bsp_uDelay(DELAY_BUSY);
}

void Set_MipiRst(u8 rst)
{
	EXAMPLE_APB3_REGW(EXAMPLE_APB3_SLV, EXAMPLE_APB3_SLV_REG1_OFFSET, rst &0x01);
	bsp_uDelay(DELAY_BUSY);
}