////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2024 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

/*
 * FreeRTOS+FAT V2.3.3
 * Copyright (C) 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 * https://www.FreeRTOS.org
 * https://github.com/FreeRTOS
 *
 */

/* Standard includes. */
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <stdio.h>


/* Efinix includes. */
#include "bsp.h"
#include "device_config.h"
#include "userDef.h"
#include "source.h"
#include "spi.h"
#include "efx_mmc_driver.h"
#include "vexriscv.h"


/* FreeRTOS includes. */
#include "FreeRTOS.h"
#include "task.h"
#include "semphr.h"
#include "portmacro.h"

/* FreeRTOS+FAT includes. */
#include "ff_sddisk.h"
#include "ff_sys.h"
#include "ff_error.h"
#include "ff_ioman.h"

/* Misc definitions. */
#define sdSIGNATURE         0x41404342UL
#define sdHUNDRED_64_BIT    ( 100ull )
#define sdBYTES_PER_MB      ( 1024ull * 1024ull )
#define sdSECTORS_PER_MB    ( sdBYTES_PER_MB / 512ull )
#define sdIOMAN_MEM_SIZE    4096

/*-----------------------------------------------------------*/

static int32_t prvSDMMC_Init( void );
static int32_t prvFFRead( uint8_t * pucBuffer,
                          uint32_t ulSectorNumber,
                          uint32_t ulSectorCount,
                          FF_Disk_t * pxDisk );
static int32_t prvFFWrite( uint8_t * pucBuffer,
                           uint32_t ulSectorNumber,
                           uint32_t ulSectorCount,
                           FF_Disk_t * pxDisk );
static uint32_t get_sector_count(struct mmc *mmc, struct mmc_cmd *cmd);
static const char* FF_SDDiskGetVolumeLabel( FF_IOManager_t *pxIOManager );

/*-----------------------------------------------------------*/

static BaseType_t xSDCardStatus;
static SemaphoreHandle_t xSDCardSemaphore;
static SemaphoreHandle_t xPlusFATMutex;
uint8_t pucCacheMemory[ 0x10000 ];

/*-----------------------------------------------------------*/

static int32_t prvFFRead( uint8_t * pucBuffer,
                          uint32_t ulSectorNumber,
                          uint32_t ulSectorCount,
                          FF_Disk_t * pxDisk )
{
    int32_t iReturn;

    if( ( pxDisk != NULL ) &&
        ( xSDCardStatus == pdPASS ) &&
        ( pxDisk->ulSignature == sdSIGNATURE ) &&
        ( pxDisk->xStatus.bIsInitialised != pdFALSE ) &&
        ( ulSectorNumber < pxDisk->ulNumberOfSectors ) &&
        ( ( pxDisk->ulNumberOfSectors - ulSectorNumber ) >= ulSectorCount ) )
    {
		struct mmc_cmd *cmd;
		struct mmc_data *data;
		struct mmc_ops	*ops = mmc->cfg->ops;

		cmd = malloc(sizeof(struct mmc_cmd));
		data = malloc(sizeof(struct mmc_data));

		memset(cmd,0,sizeof(struct mmc_cmd));
		memset(data,0,sizeof(struct mmc_data));

		data->blocksize = mmc->read_bl_len;
		data->blocks = ulSectorCount*MAX_BLK_BUF;

		if(data->blocks == 1)	cmd->cmdidx=MMC_CMD_READ_SINGLE_BLOCK;
		else					cmd->cmdidx=MMC_CMD_READ_MULTIPLE_BLOCK;

		cmd->cmdarg =ulSectorNumber;
		cmd->resp_type=MMC_RSP_R1;
		data->dest=pucBuffer;
		data->flags = MMC_DATA_READ;


		mmc->cfg->ops->send_cmd(mmc,cmd,data);

		data_cache_invalidate_all();

		free(cmd);
		free(data);

		iReturn = FF_ERR_NONE;
    }
    else
    {
        memset( ( void * ) pucBuffer, '\0', ulSectorCount * 512 );

        if( pxDisk->xStatus.bIsInitialised != 0 )
        {
            FF_PRINTF( "prvFFRead: warning: %d + %d > %d\r\n", ( unsigned ) ulSectorNumber, ( unsigned ) ulSectorCount, ( unsigned ) pxDisk->ulNumberOfSectors );
        }

        iReturn = ( FF_ERR_IOMAN_OUT_OF_BOUNDS_READ | FF_ERRFLAG );
    }

    return iReturn;
}
/*-----------------------------------------------------------*/

static int32_t prvFFWrite( uint8_t * pucBuffer,
                           uint32_t ulSectorNumber,
                           uint32_t ulSectorCount,
                           FF_Disk_t * pxDisk )
{
    int32_t iReturn;

    if( ( pxDisk != NULL ) &&
        ( xSDCardStatus == pdPASS ) &&
        ( pxDisk->ulSignature == sdSIGNATURE ) &&
        ( pxDisk->xStatus.bIsInitialised != pdFALSE ) &&
        ( ulSectorNumber < pxDisk->ulNumberOfSectors ) &&
        ( ( pxDisk->ulNumberOfSectors - ulSectorNumber ) >= ulSectorCount ) )
    {
		struct mmc_cmd *cmd;
		struct mmc_data *data;
		struct mmc_ops	*ops = mmc->cfg->ops;

		cmd = malloc(sizeof(struct mmc_cmd));
		if (cmd == NULL){
			bsp_printf("Error cmd \r\n");
			while(1);
		}
		data = malloc(sizeof(struct mmc_data));
		if (data == NULL){
			bsp_printf("Error data\r\n");
			while(1);
		}
		memset(cmd,0,sizeof(struct mmc_cmd));
		memset(data,0,sizeof(struct mmc_data));

		data->blocksize = mmc->read_bl_len;
		data->blocks = ulSectorCount; //*MAX_BLK_BUF;

		if(data->blocks == 1)	cmd->cmdidx=MMC_CMD_WRITE_SINGLE_BLOCK;
		else					cmd->cmdidx=MMC_CMD_WRITE_MULTIPLE_BLOCK;

		cmd->cmdarg =ulSectorNumber;
		cmd->resp_type=MMC_RSP_R1;

		data->src=pucBuffer;
		data->flags = MMC_DATA_WRITE;

		ops->send_cmd(mmc,cmd,data);

		data_cache_invalidate_all();

		free(cmd);
		free(data);

		iReturn = 0;
    }
    else
    {
        memset( ( void * ) pucBuffer, '\0', ulSectorCount * 512 );

        if( pxDisk->xStatus.bIsInitialised )
        {
            FF_PRINTF( "prvFFWrite: warning: %d + %d > %d\r\n", ( unsigned ) ulSectorNumber, ( unsigned ) ulSectorCount, ( unsigned ) pxDisk->ulNumberOfSectors );
        }

        iReturn = ( FF_ERR_IOMAN_OUT_OF_BOUNDS_WRITE | FF_ERRFLAG );
    }

    return iReturn;
}
/*-----------------------------------------------------------*/

void FF_SDDiskFlush( FF_Disk_t * pxDisk )
{
    if( ( pxDisk != NULL ) &&
        ( pxDisk->xStatus.bIsInitialised != pdFALSE ) &&
        ( pxDisk->pxIOManager != NULL ) )
    {
        FF_FlushCache( pxDisk->pxIOManager );
    }
}
/*-----------------------------------------------------------*/

FF_Disk_t * FF_SDDiskInitWithSettings( const char * pcName,
                                       const FFInitSettings_t * pxSettings )
{
    ( void ) pxSettings; /* Unused */

    return FF_SDDiskInit( pcName );
}
/*-----------------------------------------------------------*/

FF_Disk_t * FF_SDDiskInit( const char * pcName )
{
    FF_Error_t xFFError;
    BaseType_t xPartitionNumber = 0;
    FF_CreationParameters_t xParameters;
    FF_Disk_t * pxDisk;

    xSDCardStatus = prvSDMMC_Init();

    if( xSDCardStatus == pdPASS )
    {
        pxDisk = ( FF_Disk_t * ) pvPortMalloc( sizeof( *pxDisk ) );

        if( pxDisk != NULL )
        {
            /* Initialise the created disk structure. */
            memset( pxDisk, '\0', sizeof( *pxDisk ) );

            if( xPlusFATMutex == NULL )
            {
                xPlusFATMutex = xSemaphoreCreateRecursiveMutex();
            }

            pxDisk->ulNumberOfSectors = get_sector_count(mmc, xmmc_cmd);
            //pxDisk->ulNumberOfSectors = 31116288;
            pxDisk->ulSignature = sdSIGNATURE;

            if( xPlusFATMutex != NULL )
            {
                memset( &xParameters, '\0', sizeof( xParameters ) );
                xParameters.pucCacheMemory = pucCacheMemory;
                xParameters.ulMemorySize = sdIOMAN_MEM_SIZE;
                xParameters.ulSectorSize = 512;
                xParameters.fnWriteBlocks = prvFFWrite;
                xParameters.fnReadBlocks = prvFFRead;
                xParameters.pxDisk = pxDisk;

                /* prvFFRead()/prvFFWrite() are not re-entrant and must be
                 * protected with the use of a semaphore. */
                xParameters.xBlockDeviceIsReentrant = pdFALSE;

                /* The semaphore will be used to protect critical sections in
                 * the +FAT driver, and also to avoid concurrent calls to
                 * prvFFRead()/prvFFWrite() from different tasks. */
                xParameters.pvSemaphore = ( void * ) xPlusFATMutex;

                pxDisk->pxIOManager = FF_CreateIOManager( &xParameters, &xFFError );

                if( pxDisk->pxIOManager == NULL )
                {
                    FF_PRINTF( "FF_SDDiskInit: FF_CreateIOManager: %s\r\n", ( const char * ) FF_GetErrMessage( xFFError ) );
                    FF_SDDiskDelete( pxDisk );
                    pxDisk = NULL;
                }
                else
                {
                    pxDisk->xStatus.bIsInitialised = pdTRUE;
                    pxDisk->xStatus.bPartitionNumber = xPartitionNumber;

                    if( FF_SDDiskMount( pxDisk ) == 0 )
                    {
                        FF_SDDiskDelete( pxDisk );
                        pxDisk = NULL;
                    }
                    else
                    {
                        if( pcName == NULL )
                        {
                            pcName = "/";
                        }

                        FF_FS_Add( pcName, pxDisk );
                        FF_PRINTF( "FF_SDDiskInit: Mounted SD-card as root \"%s\"\r\n", pcName );
                        FF_SDDiskShowPartition( pxDisk );
                    }
                } /* if( pxDisk->pxIOManager != NULL ) */
            }     /* if( xPlusFATMutex != NULL) */
        }         /* if( pxDisk != NULL ) */
        else
        {
            FF_PRINTF( "FF_SDDiskInit: Malloc failed\r\n" );
        }
    } /* if( xSDCardStatus == pdPASS ) */
    else
    {
        FF_PRINTF( "FF_SDDiskInit: prvSDMMC_Init failed\r\n" );
        pxDisk = NULL;
    }

    return pxDisk;
}
/*-----------------------------------------------------------*/

BaseType_t FF_SDDiskFormat( FF_Disk_t * pxDisk,
                            BaseType_t xPartitionNumber )
{
    FF_Error_t xError;
    BaseType_t xReturn = pdFAIL;

    xError = FF_Unmount( pxDisk );

    if( FF_isERR( xError ) != pdFALSE )
    {
        FF_PRINTF( "FF_SDDiskFormat: unmount fails: %x\r\n", ( unsigned ) xError );
    }
    else
    {
        /* Format the drive - try FAT32 with large clusters. */
        xError = FF_Format( pxDisk, xPartitionNumber, pdFALSE, pdFALSE );

        if( FF_isERR( xError ) )
        {
            FF_PRINTF( "FF_SDDiskFormat: %s\r\n", ( const char * ) FF_GetErrMessage( xError ) );
        }
        else
        {
            FF_PRINTF( "FF_SDDiskFormat: OK, now remounting\r\n" );
            pxDisk->xStatus.bPartitionNumber = xPartitionNumber;
            xError = FF_SDDiskMount( pxDisk );
            FF_PRINTF( "FF_SDDiskFormat: rc %x\r\n", ( unsigned ) xError );

            if( FF_isERR( xError ) == pdFALSE )
            {
                xReturn = pdPASS;
            }
        }
    }

    return xReturn;
}
/*-----------------------------------------------------------*/

/* Get a pointer to IOMAN, which can be used for all FreeRTOS+FAT functions */
BaseType_t FF_SDDiskMount( FF_Disk_t * pxDisk )
{
    FF_Error_t xFFError;
    BaseType_t xReturn;

    /* Mount the partition */
    xFFError = FF_Mount( pxDisk, pxDisk->xStatus.bPartitionNumber );

    if( FF_isERR( xFFError ) )
    {
        FF_PRINTF( "FF_SDDiskMount: %X\r\n", xFFError );
        xReturn = pdFAIL;
    }
    else
    {
        pxDisk->xStatus.bIsMounted = pdTRUE;
        FF_PRINTF( "****** FreeRTOS+FAT initialized %d sectors\r\n", ( unsigned ) pxDisk->pxIOManager->xPartition.ulTotalSectors );
        FF_SDDiskShowPartition( pxDisk );
        xReturn = pdPASS;
    }

    return xReturn;
}
/*-----------------------------------------------------------*/

FF_IOManager_t * sddisk_ioman( FF_Disk_t * pxDisk )
{
    FF_IOManager_t * pxReturn;

    if( ( pxDisk != NULL ) && ( pxDisk->xStatus.bIsInitialised != pdFALSE ) )
    {
        pxReturn = pxDisk->pxIOManager;
    }
    else
    {
        pxReturn = NULL;
    }

    return pxReturn;
}
/*-----------------------------------------------------------*/

/* Release all resources */
BaseType_t FF_SDDiskDelete( FF_Disk_t * pxDisk )
{
    if( pxDisk != NULL )
    {
        pxDisk->ulSignature = 0;
        pxDisk->xStatus.bIsInitialised = 0;

        if( pxDisk->pxIOManager != NULL )
        {
            if( FF_Mounted( pxDisk->pxIOManager ) != pdFALSE )
            {
                FF_Unmount( pxDisk );
            }

            FF_DeleteIOManager( pxDisk->pxIOManager );
        }

        vPortFree( pxDisk );
    }

    return 1;
}
/*-----------------------------------------------------------*/

BaseType_t FF_SDDiskShowPartition( FF_Disk_t * pxDisk )
{
    FF_Error_t xError;
    uint64_t ullFreeSectors;
    uint32_t ulTotalSizeMB, ulFreeSizeMB;
    int iPercentageFree;
    FF_IOManager_t * pxIOManager;
    const char * pcTypeName = "unknown type";
    BaseType_t xReturn = pdPASS;

    if( pxDisk == NULL )
    {
        xReturn = pdFAIL;
    }
    else
    {
        pxIOManager = pxDisk->pxIOManager;

        FF_PRINTF( "Reading FAT and calculating Free Space\r\n" );

        switch( pxIOManager->xPartition.ucType )
        {
            case FF_T_FAT12:
                pcTypeName = "FAT12";
                break;

            case FF_T_FAT16:
                pcTypeName = "FAT16";
                break;

            case FF_T_FAT32:
                pcTypeName = "FAT32";
                break;

            default:
                pcTypeName = "UNKOWN";
                break;
        }

        FF_GetFreeSize( pxIOManager, &xError );

        ullFreeSectors = pxIOManager->xPartition.ulFreeClusterCount * pxIOManager->xPartition.ulSectorsPerCluster;
        iPercentageFree = ( int ) ( ( sdHUNDRED_64_BIT * ullFreeSectors + pxIOManager->xPartition.ulDataSectors / 2 ) /
                                    ( ( uint64_t ) pxIOManager->xPartition.ulDataSectors ) );

        ulTotalSizeMB = pxIOManager->xPartition.ulDataSectors / sdSECTORS_PER_MB;
        ulFreeSizeMB = ( uint32_t ) ( ullFreeSectors / sdSECTORS_PER_MB );

        char vol_label_arr[256];
        const char *vol_label = vol_label_arr;
        vol_label = FF_SDDiskGetVolumeLabel(pxIOManager);
        /* It is better not to use the 64-bit format such as %Lu because it
         * might not be implemented. */
        FF_PRINTF( "Partition Nr   %d\r\n", pxDisk->xStatus.bPartitionNumber );
        FF_PRINTF( "Type           %d (%s)\r\n", pxIOManager->xPartition.ucType, pcTypeName );
        FF_PRINTF( "VolLabel       '%s' \r\n", vol_label );
        FF_PRINTF( "TotalSectors   %d\r\n", ( unsigned ) pxIOManager->xPartition.ulTotalSectors );
        FF_PRINTF( "SecsPerCluster %d\r\n", ( unsigned ) pxIOManager->xPartition.ulSectorsPerCluster );
        FF_PRINTF( "Size           %d MB\r\n", ( unsigned ) ulTotalSizeMB );
        FF_PRINTF( "FreeSize       %d MB ( %d percent free )\r\n", ( unsigned ) ulFreeSizeMB, iPercentageFree );
    }

    return xReturn;
}
/*-----------------------------------------------------------*/

static int32_t prvSDMMC_Init( void )
{
    int32_t lSDCardStatus = pdPASS;

    if( xSDCardSemaphore == NULL )
    {
        xSDCardSemaphore = xSemaphoreCreateBinary();
        configASSERT( xSDCardSemaphore );
        xSemaphoreGive( xSDCardSemaphore );
    }

    return lSDCardStatus;
}
/*-----------------------------------------------------------*/

int disk_initialize ()
{
	u8 busy = 0;
	u32 Value;
	u32 rca=0;
	u8 wait_busy_count;

	if(DEBUG_PRINTF_EN)
		bsp_printf("disk_initialize started\r\n");

	struct mmc_data *data;
	struct mmc_ops	*ops = mmc->cfg->ops;

	data = malloc(sizeof(struct mmc_data));

	memset(data,0,sizeof(struct mmc_data));

	sd_send_cmd(mmc,xmmc_cmd,MMC_CMD_GO_IDLE_STATE,MMC_RSP_NONE,0); // Send CMD0 to reset the SD Card
	bsp_uDelay(1000);
	sd_send_cmd(mmc,xmmc_cmd,MMC_CMD_SEND_EXT_CSD,MMC_RSP_R7,0x01AA); //CMD8
	if (xmmc_cmd -> response[0] != 0x01AA){
		return FF_ERR_DEVICE_DRIVER_FAILED;
	}

	sd_send_cmd(mmc,xmmc_cmd,MMC_CMD_SPI_READ_OCR,MMC_RSP_R3,0); // CMD58
	mmc->ocr=xmmc_cmd->response[0];

	bsp_uDelay(50000);//delay 50ms
	sd_send_cmd(mmc,xmmc_cmd,MMC_CMD_APP_CMD,MMC_RSP_R1,0);  // CMD55

	while (busy==0)
	{
		Value = 0;
		Value |= 0x1<<30;	//HCS
		Value |= 0x0<<28;	//XPC
		Value |= 0x0<<24;	//S18R - this is to switch to 1.8V operating voltage. our FPGA dont support switching to 1.8v
		Value |= 0x100000;	//VDD VOLTAGE - indicate the voltage range to be 3.2 to 3.3 (Refer to the OCR Register)
		sd_send_cmd(mmc,xmmc_cmd,MMC_CMD_APP_CMD,MMC_RSP_R1,0); //make the card accept acmd command so that we can send ACMD41 to set the operating condition
		bsp_uDelay(1000);//delay 50ms
		sd_send_cmd(mmc,xmmc_cmd,SD_CMD_APP_SEND_OP_COND,MMC_RSP_R3,Value); // send ACMD41 to set operating condition
		busy = (xmmc_cmd->response[0]>>31)&0x1; 	// need to shift right 31 as the response format is R3. R1 return will be located at bit 32:39
		bsp_uDelay(50000);	//delay 50ms

		wait_busy_count++;
		if (wait_busy_count >=100000)
		{
			return FF_ERR_DEVICE_DRIVER_FAILED;
		}
	}

	mmc->ocr=xmmc_cmd->response[0]; // get back OCR value and put into mmc structure

	bsp_uDelay(1000000);

	sd_send_cmd(mmc,xmmc_cmd,MMC_CMD_ALL_SEND_CID,MMC_RSP_R2,0);
	mmc->cid[0]=xmmc_cmd->response[0];
	mmc->cid[1]=xmmc_cmd->response[1];
	mmc->cid[2]=xmmc_cmd->response[2];
	mmc->cid[3]=xmmc_cmd->response[3];

	sd_send_cmd(mmc,xmmc_cmd,MMC_CMD_SET_RELATIVE_ADDR,MMC_RSP_R6,0);

	mmc->rca = (xmmc_cmd->response[0]&0xffff0000)>>16;
	SD_READ_CSD(mmc,xmmc_cmd);
	// End of standby State
	sd_send_cmd(mmc,xmmc_cmd,MMC_CMD_SELECT_CARD,MMC_RSP_R1b,(mmc->rca<<16)); // CMD7 // going to transfer state

	sd_send_cmd(mmc,xmmc_cmd,MMC_CMD_APP_CMD,MMC_RSP_R1,(mmc->rca<<16));
	sd_send_cmd(mmc,xmmc_cmd,SD_CMD_APP_SET_BUS_WIDTH,MMC_RSP_R1,DATA_WIDTH);
	sd_send_cmd(mmc,xmmc_cmd,MMC_CMD_SET_BLOCKLEN,MMC_RSP_R1,BLOCK_SIZE);

	if(DEBUG_PRINTF_EN)
		bsp_printf("disk_initialize done\r\n");

	free(data);

	return pdPASS;
}

time_t FreeRTOS_time( time_t * pxTime )
{
	i2c_readData_b(I2C_CTRL,RTC_ADDR,RTC_SECONDS,get_data,19);
	float LSB;
	time_data rtc_time;

	//READ TIME FROM RTC
	getdata(&rtc_time);
	uint8_t seconds = rtc_time.seconds;
	uint8_t minutes = rtc_time.minutes;
	uint8_t hours;

    if(rtc_time.timesystem && rtc_time.PM)
		hours = rtc_time.hours +12;
	else
		hours =rtc_time.hours;
        
	uint8_t days = rtc_time.days;
	uint8_t weekdays = rtc_time.weekdays;
	uint8_t months = rtc_time.months;
	uint8_t years = rtc_time.years;

	years = years + 2000 - 1900;
	uint8_t days_jan = 31;
	uint8_t days_feb = ((years % 4 == 0)? 29 : 28);
	uint8_t days_mar = 31;
	uint8_t days_apr = 30;
	uint8_t days_may = 31;
	uint8_t days_jun = 30;
	uint8_t days_jul  =31;
	uint8_t days_aug = 31;
	uint8_t days_sep = 30;
	uint8_t days_oct = 31;
	uint8_t days_nov = 30;
	uint8_t days_dec = 31;
	uint16_t days_since_1jan = 0;

	switch (months) {
	case 1:
		days_since_1jan = days;
		break;
	case 2:
		days_since_1jan = days + days_jan;
		break;
	case 3:
		days_since_1jan = days + days_jan + days_feb;
		break;
	case 4:
		days_since_1jan = days + days_jan + days_feb + days_mar;
		break;
	case 5:
		days_since_1jan = days + days_jan + days_feb + days_mar + days_apr;
		break;
	case 6:
		days_since_1jan = days + days_jan + days_feb + days_mar + days_apr + days_may;
		break;
	case 7:
		days_since_1jan = days + days_jan + days_feb + days_mar + days_apr + days_may + days_jun;
		break;
	case 8:
		days_since_1jan = days + days_jan + days_feb + days_mar + days_apr + days_may + days_jun + days_jul;
		break;
	case 9:
		days_since_1jan = days + days_jan + days_feb + days_mar + days_apr + days_may + days_jun + days_jul + days_aug;
		break;
	case 10:
		days_since_1jan = days + days_jan + days_feb + days_mar + days_apr + days_may + days_jun + days_jul + days_aug + days_sep;
		break;
	case 11:
		days_since_1jan = days + days_jan + days_feb + days_mar + days_apr + days_may + days_jun + days_jul + days_aug + days_sep + days_oct;
		break;
	case 12:
		days_since_1jan = days + days_jan + days_feb + days_mar + days_apr + days_may + days_jun + days_jul + days_aug + days_sep + days_oct + days_nov;
		break;
	}
	// Formula to convert date time to elapsed seconds since Jan 1st, 1970, UTC
	// https://cboard.cprogramming.com/c-programming/169847-convert-date-time-seconds-since-epoch.html
	uint32_t second_since_1970 = seconds + minutes*60 + hours*3600 + (days_since_1jan-1)*86400 + (years-70)*31536000 + ((years-69)/4)*86400 - ((years-1)/100)*86400 + ((years+299)/400)*86400;

	return second_since_1970;
}

uint32_t get_sector_count(struct mmc *mmc, struct mmc_cmd *cmd)
{
	uint32_t sector_count;
	// Formula to calculate card size for SD 2.00
	// Size =  (C_SIZE + 1) * 2^19
	// https://www.hjreggel.net/cardspeed/special-sd.html
	uint32_t c_size = (mmc->capacity / 1024 / 512) - 1;
	uint64_t size = ((uint64_t)c_size + 1) * 524288; // 2^19=524288
	sector_count = size / 512;
	if(DEBUG_PRINTF_EN) {
		bsp_printf("SD c_size: %d\r\n", c_size);
		bsp_printf("SD sector count: %d\r\n", sector_count);
	}

	return sector_count;
}

static const char* FF_SDDiskGetVolumeLabel( FF_IOManager_t *pxIOManager )
{
	BaseType_t xIndex;
	const uint8_t *pucEntryBuffer = 0;
	uint8_t ucAttrib;
	FF_FetchContext_t xFetchContext;
	FF_Error_t pxError;

	pxError = FF_InitEntryFetch( pxIOManager, pxIOManager->xPartition.ulRootDirCluster, &xFetchContext );
	if (!FF_isERR( pxError ))
	{
		for ( xIndex = 0; xIndex < FF_MAX_ENTRIES_PER_DIRECTORY; xIndex++ )
		{
			/* Call FF_FetchEntryWithContext only once for every 512-byte block */
			if ( !xIndex || pucEntryBuffer >= xFetchContext.pxBuffer->pucBuffer + ( pxIOManager->usSectorSize - FF_SIZEOF_DIRECTORY_ENTRY ) )
			{
				pxError = FF_FetchEntryWithContext( pxIOManager, ( uint32_t ) xIndex, &xFetchContext, 0 );
				if ( FF_isERR( pxError ) )
				{
					break;
				}
				pucEntryBuffer = xFetchContext.pxBuffer->pucBuffer;
			}
			else
			{
				/* Advance 32 bytes to get the next directory entry. */
				pucEntryBuffer += FF_SIZEOF_DIRECTORY_ENTRY;
			}

			if ( FF_isEndOfDir( pucEntryBuffer ) )
			{
				break;
			}
			if (!FF_isDeleted( pucEntryBuffer ))
			{
				ucAttrib = FF_getChar( pucEntryBuffer, FF_FAT_DIRENT_ATTRIB );
				if ( ucAttrib == FF_FAT_ATTR_VOLID )
				{
					memcpy( pxIOManager->xPartition.pcVolumeLabel, pucEntryBuffer, sizeof(pxIOManager->xPartition.pcVolumeLabel) - 1 );
					break;
				}
			}
		} /* for ( xIndex = 0; xIndex < FF_MAX_ENTRIES_PER_DIRECTORY; xIndex++ ) */
	}
	FF_CleanupEntryFetch( pxIOManager, &xFetchContext );

	return (const char*)pxIOManager->xPartition.pcVolumeLabel;
}
