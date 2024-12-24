////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2024 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

#include <stdint.h>
#include "bsp.h"
#include "device_config.h"
#include "spi.h"
#include "userDef.h"

//User Binary Location
#define StartAddress    0x380000

//Read/Write size
#define ReadSize        256
#define WriteSize       256

void init(){
    //SPI init
    Spi_Config spiA;
    spiA.cpol = 1;
    spiA.cpha = 1;
    spiA.mode = 0; //Assume full duplex (standard SPI)
    spiA.clkDivider = 10;
    spiA.ssSetup = 5;
    spiA.ssHold = 5;
    spiA.ssDisable = 5;
    spi_applyConfig(SPI, &spiA);
}

void WaitBusy(void)
{
    u8 out;
    u16 timeout=0;

    while(1)
    {
        bsp_uDelay(1*1000);
        spi_select(SPI, 0);
        //Write Enable
        spi_write(SPI, 0x05);
        out = spi_read(SPI);
        spi_diselect(SPI, 0);
        if((out & 0x01) ==0x00)
            return;
        timeout++;
        //sector erase max=400ms
        if(timeout >=400)
        {
            bsp_printf("Time out \r\n");
            return;
        }
    }
}

void WriteEnableLatch(void)
{
    spi_select(SPI, 0);
    //Write Enable latch
    spi_write(SPI, 0x06);
    spi_diselect(SPI, 0);
}

void GlobalLock(void)
{
    WriteEnableLatch();
    spi_select(SPI, 0);
    //Global lock
    spi_write(SPI, 0x7E);
    spi_diselect(SPI, 0);
}

void GlobalUnlock(void)
{
    WriteEnableLatch();
    spi_select(SPI, 0);
    //Global unlock
    spi_write(SPI, 0x98);
    spi_diselect(SPI, 0);
}

void SectorErase(u32 Addr)
{
    WriteEnableLatch();
    spi_select(SPI, 0);
    //Erase Sector
    spi_write(SPI, 0x20);
    spi_write(SPI, (Addr>>16)&0xFF);
    spi_write(SPI, (Addr>>8)&0xFF);
    spi_write(SPI, Addr&0xFF);
    spi_diselect(SPI, 0);
    WaitBusy();
}

void main() {
	bsp_init();
    init();
    int i;
    u8 out;
    uint8_t data[3];

    bsp_printf("***Starting SPI Demo*** \r\n");
    bsp_printf("[Warning]: Running this app will overwrite the content in the SPI Flash!!!\r\n");
    spi_select(SPI, 0);
    spi_write(SPI, 0xAB);
    spi_write(SPI, 0x00);
    spi_write(SPI, 0x00);
    spi_write(SPI, 0x00);
    uint8_t id = spi_read(SPI);
    spi_diselect(SPI, 0);
    bsp_printf("Device ID : %x \r\n", id);
	spi_select(SPI, 0);
	spi_write(SPI, 0x9F);
	data[0] = spi_read(SPI);
	data[1] = spi_read(SPI);
	data[2] = spi_read(SPI);
	spi_diselect(SPI, 0);
	bsp_printf("CMD 0x9F : %x \r\n", data[2] | data[1] << 8 | data[0] << 16);

    //spiWriteDemo
    bsp_printf("SPI 0 flash write start ! \r\n");
    GlobalUnlock();
    bsp_uDelay(1000);
    SectorErase(StartAddress);
    WriteEnableLatch();
    spi_select(SPI, 0);
    spi_write(SPI, 0x02);
    spi_write(SPI, (StartAddress>>16)&0xFF);
    spi_write(SPI, (StartAddress>>8)&0xFF);
    spi_write(SPI, StartAddress&0xFF);
    //Write sequential number for testing
    for(i=0;i<WriteSize;i++)
    {
        spi_write(SPI, i&0xFF);
        bsp_printf("WR Addr %x := %x \r\n", StartAddress+i, i&0xFF);
    }
    spi_diselect(SPI, 0);
    //wait for page progarm done
    WaitBusy();
    GlobalLock();
    bsp_printf("SPI 0 flash write end ! \r\n\n");

    //spiReadFlashDemo
    bsp_printf("SPI 0 flash read start ! \r\n");

    for(i=StartAddress;i<StartAddress+ReadSize;i++)
    {
        spi_select(SPI, 0);
        spi_write(SPI, 0x03);
        spi_write(SPI, (i>>16)&0xFF);
        spi_write(SPI, (i>>8)&0xFF);
        spi_write(SPI, i&0xFF);
        uint8_t out = spi_read(SPI);
        spi_diselect(SPI, 0);
        bsp_printf("RD Addr %x := %x \r\n", i, out);
    }
    bsp_printf("SPI 0 flash read end ! \r\n");
    bsp_printf("***SPI Demo Finish*** \r\n");

    while(1){}

}


