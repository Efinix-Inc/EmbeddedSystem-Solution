///////////////////////////////////////////////////////////////////////////////////
//  Copyright (c) 2024 SaxonSoc contributors
//  SPDX license identifier: MIT
//  Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
///////////////////////////////////////////////////////////////////////////////////
#pragma once

#include "type.h"
#include "spi.h"
#include "gpio.h"
#include "io.h"

#define MX25_QUAD_ENABLE_BIT        0x40
#define MX25_WRITE_ENABLE_LATCH_BIT 0x02

    /**
    * Set SPI Flash device Chip Select with GPIO port
    * 
    * @param gpio GPIO port base address 
    * @param cs 32-bit bitwise setting. Set 1 to enable particular bit. 
    */
    static void spiFlash_select_withGpioCs(u32 gpio, u32 cs){
        gpio_setOutput(gpio, gpio_getOutput(gpio) & ~(1 << cs));
        bsp_uDelay(1);
    }
    
    /**
    * Clear SPI Flash device Chip Select with GPIO port
    * 
    * @param gpio GPIO port base address 
    * @param cs 32-bit bitwise setting. Set 1 to disable particular bit. 
    */
    static void spiFlash_diselect_withGpioCs(u32 gpio, u32 cs){
        gpio_setOutput(gpio, gpio_getOutput(gpio) | (1 << cs));
        bsp_uDelay(1);
    }
    
    /**
    * Set SPI Flash device Chip Select
    * 
    * @param spi SPI port base address 
    * @param cs 32-bit bitwise setting. Set 1 to enable particular bit. 
    */
    static void spiFlash_select(u32 spi, u32 cs){
        spi_select(spi, cs);
    }
   
    /**
    * Clear SPI Flash device Chip Select
    * 
    * @param spi SPI port base address 
    * @param cs 32-bit bitwise setting. Set 1 to disable particular bit. 
    */ 
    static void spiFlash_diselect(u32 spi, u32 cs){
        spi_diselect(spi, cs);
    }
    
    /**
    * Initialize SPI port with default settings 
    * 
    * @param spi SPI port base address
    */
    static void spiFlash_init_(u32 spi){
        Spi_Config spiCfg;
        spiCfg.cpol = 0;
        spiCfg.cpha = 0;
        spiCfg.mode = 0;
        spiCfg.clkDivider = 2;
        spiCfg.ssSetup = 5;
        spiCfg.ssHold = 2;
        spiCfg.ssDisable = 7;
        spi_applyConfig(spi, &spiCfg);
        spi_waitXferBusy(spi); 
    }
   
    /**
    * Initialize SPI port with default settings with mode selection
    * 
    * @param spi SPI port base address
    * @param mode SPI mode selection 
    */ 
    static void spiFlash_init_mode_(u32 spi, u32 mode ){
        Spi_Config spiCfg;
        spiCfg.cpol = 0;
        spiCfg.cpha = 0;
        spiCfg.mode = mode;
        spiCfg.clkDivider = 2;
        spiCfg.ssSetup = 5;
        spiCfg.ssHold = 2;
        spiCfg.ssDisable = 7;
        spi_applyConfig(spi, &spiCfg);
        spi_waitXferBusy(spi);
    }

    /**
    * Initialize SPI port with GPIO Chip Select
    * 
    * @param spi SPI port base address
    * @param gpio GPIO port base address 
    * @param cs 32-bit bitwise chip select setting.
    */
    static void spiFlash_init_withGpioCs(u32 spi, u32 gpio, u32 cs){
        spiFlash_init_(spi);
        gpio_setOutputEnable(gpio, gpio_getOutputEnable(gpio) | (1 << cs));
        spiFlash_diselect_withGpioCs(gpio,cs);
    }
    
    /**
    * Initialize SPI port with GPIO Chip Select
    * 
    * @param spi SPI port base address
    * @param gpio GPIO port base address 
    * @param cs 32-bit bitwise chip select setting.
    */
    static void spiFlash_init(u32 spi, u32 cs){
        spiFlash_init_(spi);
        spiFlash_diselect(spi, cs);
    }
    
    /**
    * Get SPI Flash Manufacturer ID
    *
    * @param spi SPI port base address
    * @param cs 32-bit bitwise chip select setting. 
    */
    static inline u8 spiFlash_manufacturer_id_(u32 spi, u32 cs){
        spi_write(spi, 0x90); 
        spi_write(spi, 0x00);
        spi_write(spi, 0x00);
        spi_write(spi, 0x00);
        u8 mid = spi_read(spi); 
        bsp_uDelay(300); 
        return mid;    
    }

    /**
    * Wake up the Spi Flash. 
    * Crucial to ensure the device is in operation state before 
    * start communicating with the device. 
    * 
    * @param spi SPI port base address
    */
    static void spiFlash_wake_(u32 spi){
        spi_write(spi, 0xAB);        
    }

    /**
    * Exit 4-byte addressing
    * Ensure the addressing mode is set to 3-byte before accessing
    * the SPI Flash 
    *
    * @param spi SPI port base address
    * @param cs 32-bit bitwise chip select setting
    * @param mid 8-bit SPI Flash Manufacturer ID.
    */
    static void spiFlash_exit4ByteAddr_(u32 spi, u32 cs, u8 mid){
        switch(mid){
            case 0xC2: 
                spi_write(spi, 0xE9);
                break; 
            case 0x9D: 
                spi_write(spi, 0x29);
                break; 
            default: 
                break; 
        }
    }
    
    /**
    * Exit 4-byte addressing
    * Ensure the addressing mode is set to 3-byte before accessing
    * the SPI Flash. Readback the manufacturer ID before exit 4 byte
    * addressing. 
    *
    * @param spi SPI port base address
    * @param cs 32-bit bitwise chip select setting.
    *
    */
    static void spiFlash_exit4ByteAddr(u32 spi, u32 cs){
        spiFlash_select(spi,cs);
        u8 mid = spiFlash_manufacturer_id_(spi, cs); 
        spiFlash_diselect(spi,cs);
        spi_waitXferBusy(spi);
        spiFlash_select(spi,cs);
        spiFlash_exit4ByteAddr_(spi, cs, mid); 
        spiFlash_diselect(spi,cs);
        spi_waitXferBusy(spi);
    }

    /**
    * Exit 4-byte addressing with gpio chip select
    * Ensure the addressing mode is set to 3-byte before accessing
    * the SPI Flash. Readback the manufacturer ID before exit 4 byte
    * addressing. 
    *
    * @param spi SPI port base address
    * @param gpio GPIO port base address 
    * @param cs 32-bit bitwise chip select setting.
    *
    */
    static void spiFlash_exit4ByteAddr_withGpioCs(u32 spi, u32 gpio, u32 cs){
        spiFlash_select_withGpioCs(gpio,cs);
        u8 mid = spiFlash_manufacturer_id_(spi, cs); 
        spiFlash_diselect_withGpioCs(gpio,cs);
        spi_waitXferBusy(spi);
        spiFlash_select_withGpioCs(gpio,cs);
        spiFlash_exit4ByteAddr_(spi, cs, mid); 
        spiFlash_diselect_withGpioCs(gpio,cs);
        spi_waitXferBusy(spi);
    }

    /**
    * Wake up the Spi Flash with gpio chip select
    * 
    * @param spi SPI port base address
    * @param gpio GPIO port base address 
    * @param cs 32-bit bitwise chip select setting.
    */
    static void spiFlash_wake_withGpioCs(u32 spi, u32 gpio, u32 cs){
        spiFlash_select_withGpioCs(gpio,cs);
        spiFlash_wake_(spi);
        spiFlash_diselect_withGpioCs(gpio,cs);
        bsp_uDelay(200);
    }
    
    /**
    * Wake up the Spi Flash with chip select
    * 
    * @param spi SPI port base address
    * @param cs 32-bit bitwise chip select setting.
    */
    static void spiFlash_wake(u32 spi, u32 cs){
        spiFlash_select(spi,cs);
        spiFlash_wake_(spi);
        spiFlash_diselect(spi,cs);
        spi_waitXferBusy(spi);
        bsp_uDelay(100); // make sure the Flash fully awake
    }
   
    /**
    * Send software reset to the SPI Flash
    * 
    * @param spi SPI port base address
    * @param cs 32-bit bitwise chip select setting.
    */ 
    static void spiFlash_software_reset(u32 spi, u32 cs){
        spiFlash_select(spi,cs);
        spi_write(spi, 0x66);
        spiFlash_diselect(spi,cs);
        spiFlash_select(spi,cs);
        spi_write(spi, 0x99);
        spiFlash_diselect(spi,cs);
        bsp_uDelay(200);
    }
    
    /**
    * Read current SPI Flash ID
    * 
    * @param spi SPI port base address
    */
    static u8 spiFlash_read_id_(u32 spi){
        spi_write(spi, 0xAB);
        spi_write(spi, 0x00);
        spi_write(spi, 0x00);
        spi_write(spi, 0x00);
        return spi_read(spi);
    }
   
     /**
    * Read current SPI Flash ID with chip select
    * 
    * @param spi SPI port base address
    * @param cs 32-bit bitwise chip select setting.
    */ 
    static u8 spiFlash_read_id(u32 spi, u32 cs){
        u8 id;
        spiFlash_select(spi,cs);
        id = spiFlash_read_id_(spi);
        spiFlash_diselect(spi,cs);
        return id;
    }
   
#if defined(DEFAULT_ADDRESS_BYTE) || defined(MX25_FLASH)
    /**
        * Set Write Enable Latch and set Quad Enable bit to enable Quad SPI
        *
        * @param spi SPI port base address
        * @param cs 32-bit bitwise chip select setting
        *
        */
    static void spiFlash_enable_quad_access(u32 spi, u32 cs){
    	u8 status = 0;
    	// Poll until Write Enable Latch bit is set
		do {
			spiWriteEnable(spi, cs);
			status = spiReadStatusRegister(spi, cs);
			bsp_uDelay(1);
		} while ((status & MX25_WRITE_ENABLE_LATCH_BIT) != MX25_WRITE_ENABLE_LATCH_BIT);

		// Enable Quad Enable (QE)
		spiWriteStatusRegister(spi, cs, status | MX25_QUAD_ENABLE_BIT);

		 // Poll until Quad Enable is set
		do {
			status = spiReadStatusRegister(spi, cs);
			bsp_uDelay(1);
		} while ((status & MX25_QUAD_ENABLE_BIT) != MX25_QUAD_ENABLE_BIT);
    }
#endif
 
    /**
    * Read data from FlashAddress and copy to memoryAddress of specific size
    * With single data line 
    * 
    * @param spi SPI port base address
    * @param flashAddress The flash address to read the data
    * @param memoryAddress The RAM address to write the data
    * @param size The size of data to copy
    */
    static void spiFlash_f2m_(u32 spi, u32 flashAddress, u32 memoryAddress, u32 size){
        spi_write(spi, 0x0B);
        spi_write(spi, flashAddress >> 16);
        spi_write(spi, flashAddress >>  8);
        spi_write(spi, flashAddress >>  0);
        spi_write(spi, 0);
        uint8_t *ram = (uint8_t *) memoryAddress;
        for(u32 idx = 0;idx < size;idx++){
            u8 value = spi_read(spi);
            *ram++ = value;
        }
    }
    
    /**
    * Read data from FlashAddress and copy to memoryAddress of specific size
    * With dual data line - half duplex
    * 
    * @param spi SPI port base address
    * @param flashAddress The flash address to read the data
    * @param memoryAddress The RAM address to write the data
    * @param size The size of data to copy
    * 
    * \note Make sure hardware need to connect both Data0 and Data1 port. Else, it would not work. 
    */
    static void spiFlash_dual_f2m_(u32 spi, u32 flashAddress, u32 memoryAddress, u32 size){
        spi_write(spi, 0x3B);
        spi_write(spi, flashAddress >> 16);
        spi_write(spi, flashAddress >>  8);
        spi_write(spi, flashAddress >>  0);
        spi_write(spi, 0);
        spi_waitXferBusy(spi); // Make sure all spi data transferred before switching mode
        spiFlash_init_mode_(spi, 0x01); // change mode to dual data mode
        uint8_t *ram = (uint8_t *) memoryAddress;
        for(u32 idx = 0;idx < size;idx++){
            u8 value = spi_read(spi);
            *ram++ = value;
        }
        spiFlash_init_mode_(spi, 0x00); // change mode back to single data mode
    }


    /**
    * Read data from FlashAddress and copy to memoryAddress of specific size
    * With quad data line - half duplex
    * 
    * @param spi SPI port base address
    * @param flashAddress The flash address to read the data
    * @param memoryAddress The RAM address to write the data
    * @param size The size of data to copy
    *
    * \note Make sure hardware need to connect all data ports. 
    * Else, it would not work. 
    */
    static void spiFlash_quad_f2m_(u32 spi, u32 flashAddress, u32 memoryAddress, u32 size){
        spi_write(spi, 0x6B);
        spi_write(spi, flashAddress >> 16);
        spi_write(spi, flashAddress >>  8);
        spi_write(spi, flashAddress >>  0);
        spi_write(spi, 0);
        spi_waitXferBusy(spi); // Make sure all spi data transferred before switching mode
        spiFlash_init_mode_(spi, 0x02); // change mode to quad data mode
        uint8_t *ram = (uint8_t *) memoryAddress;
        for(u32 idx = 0;idx < size;idx++){
            u8 value = spi_read(spi);
            *ram++ = value;
        }
        spiFlash_init_mode_(spi, 0x00); // change mode back to single data mode
    }

    /**
    * Read data from FlashAddress and copy to memoryAddress of specific size with GPIO Chip Select
    * 
    * @param spi SPI port base address
    * @param gpio GPIO port base address
    * @param cs 32-bit bitwise chip select setting
    * @param flashAddress The flash address to read the data
    * @param memoryAddress The RAM address to write the data
    * @param size The size of data to copy
    */
    static void spiFlash_f2m_withGpioCs(u32 spi,  u32 gpio, u32 cs, u32 flashAddress, u32 memoryAddress, u32 size){
        spiFlash_select_withGpioCs(gpio,cs);
        spiFlash_f2m_(spi, flashAddress, memoryAddress, size);
        spiFlash_diselect_withGpioCs(gpio,cs);
    }
    
    /**
    * Read data from FlashAddress and copy to memoryAddress of specific size with GPIO Chip Select
    * With Dual data lines - half duplex  
    *
    * @param spi SPI port base address
    * @param gpio GPIO port base address
    * @param cs 32-bit bitwise chip select setting
    * @param flashAddress The flash address to read the data
    * @param memoryAddress The RAM address to write the data
    * @param size The size of data to copy
    */
    static void spiFlash_f2m_dual_withGpioCs(u32 spi,  u32 gpio, u32 cs, u32 flashAddress, u32 memoryAddress, u32 size){
        spiFlash_select_withGpioCs(gpio,cs);
        spiFlash_dual_f2m_(spi, flashAddress, memoryAddress, size);
        spiFlash_diselect_withGpioCs(gpio,cs);
    }
    
    /**
    * Read data from FlashAddress and copy to memoryAddress of specific size with GPIO Chip Select
    * With Quad data lines - half duplex  
    *
    * @param spi SPI port base address
    * @param gpio GPIO port base address
    * @param cs 32-bit bitwise chip select setting
    * @param flashAddress The flash address to read the data
    * @param memoryAddress The RAM address to write the data
    * @param size The size of data to copy
    */
    static void spiFlash_f2m_quad_withGpioCs(u32 spi,  u32 gpio, u32 cs, u32 flashAddress, u32 memoryAddress, u32 size){
        spiFlash_select_withGpioCs(gpio,cs);
        spiFlash_quad_f2m_(spi, flashAddress, memoryAddress, size);
        spiFlash_diselect_withGpioCs(gpio,cs);
    }
 
    /**
    * Read data from FlashAddress and copy to memoryAddress of specific size with Chip Select
    * 
    * @param spi SPI port base address
    * @param cs 32-bit bitwise chip select setting
    * @param flashAddress The flash address to read the data
    * @param memoryAddress The RAM address to write the data
    * @param size The size of data to copy
    */ 
    static void spiFlash_f2m(u32 spi, u32 cs, u32 flashAddress, u32 memoryAddress, u32 size){
        spiFlash_select(spi,cs);
        spiFlash_f2m_(spi, flashAddress, memoryAddress, size);
        spiFlash_diselect(spi,cs);
    }

    /**
    * Read data from FlashAddress and copy to memoryAddress of specific size with Chip Select
    * with Dual data lines - half duplex
    * 
    * @param spi SPI port base address
    * @param cs 32-bit bitwise chip select setting
    * @param flashAddress The flash address to read the data
    * @param memoryAddress The RAM address to write the data
    * @param size The size of data to copy
    * 
    * \note Make sure hardware need to connect both Data0 and Data1 port. Else, it would not work. 
    */
    static void spiFlash_f2m_dual(u32 spi, u32 cs, u32 flashAddress, u32 memoryAddress, u32 size){
        spiFlash_select(spi,cs);
        spiFlash_dual_f2m_(spi, flashAddress, memoryAddress, size);
        spiFlash_diselect(spi,cs);
    }

    /**
    * Read data from FlashAddress and copy to memoryAddress of specific size with Chip Select
    * with Quad data lines - half duplex 
    * 
    * @param spi SPI port base address
    * @param cs 32-bit bitwise chip select setting
    * @param flashAddress The flash address to read the data
    * @param memoryAddress The RAM address to write the data
    * @param size The size of data to copy
    *
    * \note Make sure hardware need to connect all data ports. 
    * Else, it would not work.  
    */
    static void spiFlash_f2m_quad(u32 spi, u32 cs, u32 flashAddress, u32 memoryAddress, u32 size){
#if defined(DEFAULT_ADDRESS_BYTE) || defined(MX25_FLASH)
    	spiFlash_enable_quad_access(spi,cs);
#endif
        spiFlash_select(spi,cs);
        spiFlash_quad_f2m_(spi, flashAddress, memoryAddress, size);
        spiFlash_diselect(spi,cs);
    }

