////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2025 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

#include "platform/sd/sd.h"

// Define buffer for BMP data
uint8_t Buff[BMP_MAX_FILE_SIZE] __attribute__((aligned(4)));
//uint8_t small_buff[1024] __attribute__((aligned(4)));

// FATFS File System Objects
FATFS FatFs;
FIL File[2];
DIR Dir;
FILINFO Finfo;
FATFS *fs;

char Line[256];
char *ptr, *ptr2 = 0;
unsigned char v = 0;
long p1 = 0, p2= 0, p3= 0;
BYTE res = 0, b = 0, drv = 0;
UINT s1 = 0, s2 = 0, cnt = 0, blen = sizeof Buff;
DWORD ofs = 0, sect = 0, blk[2] = {0, 0}, dw = 0;
QWORD acc_size = 0; //, acc_files = 0, acc_dirs = 0;
UINT acc_dirs = 0, acc_files = 0;  // Change from QWORD to UINT


// SD/MMC Variables
volatile UINT Timer;
struct mmc *mmc;
struct mmc_cmd *xmmc_cmd;
struct mmc_data *data;
struct mmc_config *cfg;
struct mmc_ops *ops;

// File System Type Strings
const char *ft[] = {"", "FAT12", "FAT16", "FAT32", "exFAT"};

// Initialize the BMP structure
BMP bmp_data = {
.file_byte_number = BMP_MAX_FILE_SIZE,
.file_byte_contents = Buff,  // Buffer to hold the BMP data
.pixel_array_start = 0,      // Will be populated by bmp_read()
.width = 0,                  // Will be populated by bmp_read()
.height = 0,                 // Will be populated by bmp_read()
.depth = 0                   // Will be populated by bmp_read()
};


//////////////////////////////////////////////////////////////////////////////////////////////
/******************************************************************************
 *
 * This function is used to monitor the files.
 *
 ******************************************************************************/
FRESULT scan_files (
	char* path,		/* Pointer to the path name working buffer */
	UINT* n_dir,
	UINT* n_file,
	QWORD* sz_file
)
{
	DIR dirs;
	FRESULT res;
	BYTE i;


	if ((res = f_opendir(&dirs, path)) == FR_OK) {
		i = strlen(path);
		while (((res = f_readdir(&dirs, &Finfo)) == FR_OK) && Finfo.fname[0]) {
			if (Finfo.fattrib & AM_DIR) {
				(*n_dir)++;
				*(path+i) = '/'; strcpy(path+i+1, Finfo.fname);
				res = scan_files(path, n_dir, n_file, sz_file);
				*(path+i) = '\0';
				if (res != FR_OK) break;
			} else {
				(*n_file)++;
				*sz_file += Finfo.fsize;
			}
		}
	}

	return res;
}

/******************************************************************************
 *
 * This function initialize the file system.
 *
 ******************************************************************************/
void putChar(char c) {
	bsp_printf("%c", c);
}

void put_rc (FRESULT rc) {
	const char *str =
		"OK\0" "DISK_ERR\0" "INT_ERR\0" "NOT_READY\0" "NO_FILE\0" "NO_PATH\0"
		"INVALID_NAME\0" "DENIED\0" "EXIST\0" "INVALID_OBJECT\0" "WRITE_PROTECTED\0"
		"INVALID_DRIVE\0" "NOT_ENABLED\0" "NO_FILE_SYSTEM\0" "MKFS_ABORTED\0" "TIMEOUT\0"
		"LOCKED\0" "NOT_ENOUGH_CORE\0" "TOO_MANY_OPEN_FILES\0" "INVALID_PARAMETER\0";
	FRESULT i;

	for (i = 0; i != rc && *str; i++) {
		while (*str++) ;
	}
	bsp_printf("rc=%u\n", (UINT)rc);
	bsp_printf("FR_%s\n\r", str);
}

void sd_init() {
	//time_data myConfig; //Initialize timedata struct


	xdev_out(putChar);

	mmc=malloc(sizeof(struct mmc));
	cfg=malloc(sizeof(struct mmc_config));
	ops=malloc(sizeof(struct mmc_ops));
	xmmc_cmd=malloc(sizeof(struct mmc_cmd));
	data=malloc(sizeof(struct mmc_data));

	bsp_printf("\n\r***Welcome to SD FatFs***\n\r");
	bsp_printf("Initialize...\r\n");

	//Allocation Struct Space
	memset(mmc, 0, sizeof(struct mmc));
	memset(cfg, 0, sizeof(struct mmc_config));
	memset(ops, 0, sizeof(struct mmc_ops));
	memset(xmmc_cmd, 0, sizeof(struct mmc_cmd));
	memset(data, 0, sizeof(struct mmc_data));

	mmc->cfg = cfg;		//pass the pointer after malloc in struct
	mmc->cfg->ops = ops;//pass the pointer after malloc in struct

	sd_ctrl_mmc_probe(mmc,SDHC_BASE); //init SD Card driver

	IntcInitialize(mmc);	// init interrupt

	if(f_mount(&FatFs, "", 1) == FR_OK) // Mount SD Card
	{
		bsp_printf("Filesystem found in SD card .. \r\n");
	} else
	{
		bsp_printf("Filesystem not found, please create it using command below .. \r\n");	}

	xputs(HelpMsg);
}


void sd_main(){
for (;;) {
		xputc('>');
		xgets(Line, sizeof Line);
		ptr = Line;
		switch (*ptr++) {
		case 'z':
			asm("fence w,w");
    		evsoc_reset_f = 1;
    		display_enabled =0;
    		camera_enabled =0;
			break;
		case 'c':
		      {   if (!camera_enabled) { xprintf("Camera is disabled!!!\r\n"); break; }
		    	  while(dmasg_busy(DMASG_BASE, DMASG_CAM_S2MM_CHANNEL));
		          uart_writeStr(BSP_UART_TERMINAL, "Camera Captured!\n\r");
		          capture_enabled = 1;
		          // File name buffer
		          char filename[16];
		          uint32_t file_index = 1;
		          FRESULT res;

		          // Find the next available file name
		          while (1) {
		              snprintf(filename, sizeof(filename), "%lu.bmp", file_index); // Generate file name
		              res = f_stat(filename, NULL);  // Check if the file exists

		              if (res == FR_NO_FILE) {
		                  // File does not exist, we can use this name
		                  break;
		              } else if (res != FR_OK) {
		                  uart_writeStr(BSP_UART_TERMINAL, "Error checking file existence!\n\r");
		                  return;  // Exit on error
		              }

		              file_index++;  // Increment file index and try again
		          }

		          // Create and write to the BMP file
		          res = f_open(&File[0], filename, FA_WRITE | FA_CREATE_ALWAYS);
		          if (res == FR_OK) {
		              uart_writeStr(BSP_UART_TERMINAL, "Saving file: ");
		              uart_writeStr(BSP_UART_TERMINAL, filename);
		              uart_writeStr(BSP_UART_TERMINAL, "\n\r");

		              bsp_uDelay(10000);
		              bmp_write(&File[0], Buff, FRAME_WIDTH, FRAME_HEIGHT);
		              f_close(&File[0]);
		          } else {
		              uart_writeStr(BSP_UART_TERMINAL, "Failed to create file!\n\r");
		          }
		          capture_enabled = 0;
		      }
		      break;
		case 'd': // Toggle Display
			if (h1_state == IDLE || h1_state == RESET){
				display_enabled = 1;
				evsoc_reset_f = 0;
				h1_state = INIT;
				xprintf("Display is enabled.\r\n");
			}
			else {
				xprintf("Camera & Display already enabled !!!\r\n");
			}
			break;
		case '?' :	/* Show Command List */
			xputs(HelpMsg);
			break;
		case 'm' :	/* Memory dump/fill/edit */
			switch (*ptr++) {
			case 'd' :	/* md[b|h|w] <address> [<count>] - Dump memory */
				switch (*ptr++) {
				case 'w': p3 = 4; break;
				case 'h': p3 = 2; break;
				default: p3 = 1;
				}
				if (!xatoi(&ptr, &p1)) break;
				if (!xatoi(&ptr, &p2)) p2 = 128 / p3;
				for (ptr = (char*)p1; p2 >= 16 / p3; ptr += 16, p2 -= 16 / p3)
					put_dump(ptr, (DWORD)ptr, 16
							/ p3, p3);
				if (p2) put_dump((BYTE*)ptr, (UINT)ptr, p2, p3);
				break;
			case 'f' :	/* mf <address> <value> <count> - Fill memory */
				if (!xatoi(&ptr, &p1) || !xatoi(&ptr, &p2) || !xatoi(&ptr, &p3)) break;
				while (p3--) {
					*(BYTE*)p1 = (BYTE)p2;
					p1++;
				}
				break;
			case 'e' :	/* me[b|h|w] <address> [<value> ...] - Edit memory */
				switch (*ptr++) {	/* Get data width */
				case 'w': p3 = 4; break;
				case 'h': p3 = 2; break;
				default: p3 = 1;
				}
				if (!xatoi(&ptr, &p1)) break;	/* Get start address */
				if (xatoi(&ptr, &p2)) {	/* 2nd parameter is given (direct mode) */
					do {
						switch (p3) {
						case 4: *(DWORD*)p1 = (DWORD)p2; break;
						case 2: *(WORD*)p1 = (WORD)p2; break;
						default: *(BYTE*)p1 = (BYTE)p2;
						}
						p1 += p3;
					} while (xatoi(&ptr, &p2));	/* Get next value */
					break;
				}
				for (;;) {				/* 2nd parameter is not given (interactive mode) */
					switch (p3) {
					case 4: xprintf("%08X 0x%08X-", p1, *(DWORD*)p1); break;
					case 2: xprintf("%08X 0x%04X-", p1, *(WORD*)p1); break;
					default: xprintf("%08X 0x%02X-", p1, *(BYTE*)p1);
					}
					ptr = Line; xgets(ptr, sizeof Line);
					if (*ptr == '.') break;
					if ((BYTE)*ptr >= ' ') {
						if (!xatoi(&ptr, &p2)) continue;
						switch (p3) {
						case 4: *(DWORD*)p1 = (DWORD)p2; break;
						case 2: *(WORD*)p1 = (WORD)p2; break;
						default: *(BYTE*)p1 = (BYTE)p2;
						}
					}
					p1 += p3;
				}
				break;
			}
			break;

		case 'b' :	/* Buffer controls */
			switch (*ptr++) {
			case 'd' :	/* bd <ofs> - Dump R/W buffer */
				if (!xatoi(&ptr, &p1)) break;
				xprintf("Address of Buff: %u\r\n", (void *)Buff);
				for (ptr=(char*)&Buff[p1], ofs = p1, cnt = 32*2; cnt; cnt--, ptr+=16, ofs+=16)
					put_dump((BYTE*)ptr, ofs, 16, 1);
				break;

			case 'e' :	/* be <ofs> [<data>] ... - Edit R/W buffer */
				if (!xatoi(&ptr, &p1)) break;
				if (xatoi(&ptr, &p2)) {
					do {
						Buff[p1++] = (BYTE)p2;
					} while (xatoi(&ptr, &p2));
					break;
				}
				for (;;) {
					xprintf("%04X %02X-", (WORD)(p1), (WORD)Buff[p1]);
					xgets(Line, sizeof Line);
					ptr = Line;
					if (*ptr == '.') break;
					if (*ptr < ' ') { p1++; continue; }
					if (xatoi(&ptr, &p2))
						Buff[p1++] = (BYTE)p2;
					else
						xputs("???\n");
				}
				break;

			case 'r' :	/* br <pd#> <lba> [<num>] - Read disk into R/W buffer */
				if (!xatoi(&ptr, &p1) || !xatoi(&ptr, &p2)) break;
				if (!xatoi(&ptr, &p3)) p3 = 1;
				xprintf("rc=%u\n", (WORD)disk_read((BYTE)p1, Buff, p2, p3));
				break;

			case 'w' :	/* bw <pd#> <lba> [<num>] - Write R/W buffer into disk */
				if (!xatoi(&ptr, &p1) || !xatoi(&ptr, &p2)) break;
				if (!xatoi(&ptr, &p3)) p3 = 1;
				xprintf("rc=%u\n", (WORD)disk_write((BYTE)p1, Buff, p2, p3));
				break;

			case 'f' :	/* bf <val> - Fill working buffer */
				if (!xatoi(&ptr, &p1)) break;
				unsigned char p2 = 0;
//				memset(Buff, (BYTE)p1, sizeof Buff);
				for (int i = 0; i < sizeof(Buff); i++) {
						Buff[i] = p2;
						p2++;
					}
				break;

			}
			break;
		case 'v': //Toggle Vision
			if (h1_state == IDLE || h1_state == RESET){
			asm("fence w,w");
			camera_enabled = 1;
			evsoc_reset_f = 0;
			h1_state = INIT;
			xprintf("Camera & Display is enabled.\r\n");
			} else xprintf("Camera & Display already enabled!\r\n");

			break;

		case 'x':  /* x <file> - Open and read BMP */
			    while (*ptr == ' ') ptr++;  // Skip spaces
			    res = f_open(&File[0], ptr, FA_READ);  // Use proper read-only mode
			    bsp_uDelay(10000);
			    res = bmp_read(&File[0],&bmp_data, Buff, &cnt);
			    if (res == FR_OK) {
			        xprintf("%lu bytes read from BMP file.\n", cnt);
			    } else {
			        put_rc(res);
			    }

			    f_close(&File[0]);  // Close the file after reading
			    break;

		case 'f' :	/* FatFS API controls */
			switch (*ptr++) {

			case 'i' :	/* fi [<opt>]- Initialize logical drive */
				if (!xatoi(&ptr, &p2)) p2 = 0;
				put_rc(f_mount(&FatFs, "", (BYTE)p2));
				break;

			case 's' :	/* fs [<path>] - Show volume status */
				while (*ptr == ' ') ptr++;
				res = f_getfree(ptr, (DWORD*)&p1, &fs);
				if (res) {
					put_rc(res);
					break;
				}
				xprintf("FAT type = %s\n", ft[fs->fs_type]);
				xprintf("Bytes/Cluster = %lu\n", (DWORD)fs->csize * 512);
				xprintf("Number of FATs = %u\n", fs->n_fats);
				if (fs->fs_type < FS_FAT32) xprintf("Root DIR entries = %u\n", fs->n_rootdir);
				xprintf("Sectors/FAT = %lu\n", fs->fsize);
				xprintf("Number of clusters = %lu\n", (DWORD)fs->n_fatent - 2);
				xprintf("Volume start (lba) = %lu\n", fs->volbase);
				xprintf("FAT start (lba) = %lu\n", fs->fatbase);
				xprintf("DIR start (lba,clustor) = %lu\n", fs->dirbase);
				xprintf("Data start (lba) = %lu\n\n", fs->database);
#if FF_USE_LABEL
				res = f_getlabel(ptr, (char*)Buff, (DWORD*)&p2);
				if (res) { put_rc(res); break; }
				xprintf(Buff[0] ? "Volume name is %s\n" : "No volume label\n", (char*)Buff);
				xprintf("Volume S/N is %04X-%04X\n", (DWORD)p2 >> 16, (DWORD)p2 & 0xFFFF);
#endif
				acc_size = acc_files = acc_dirs = 0;
				xprintf("...");
				res = scan_files(ptr, &acc_dirs, &acc_files, &acc_size);
				if (res) { put_rc(res); break; }
				xprintf("\r%u files, %llu bytes.\n%u folders.\n"
						"%lu KiB total disk space.\n%lu KiB available.\n",
						acc_files, acc_size, acc_dirs,
						(fs->n_fatent - 2) * (fs->csize / 2), (DWORD)p1 * (fs->csize / 2)
				);
				break;

			case 'l' :	/* fl [<path>] - Directory listing */
				while (*ptr == ' ') ptr++;
				res = f_opendir(&Dir, ptr);
				if (res) { put_rc(res); break; }
				acc_size = acc_dirs = acc_files = 0;
				for(;;) {
					res = f_readdir(&Dir, &Finfo);
					if ((res != FR_OK) || !Finfo.fname[0]) break;
					if (Finfo.fattrib & AM_DIR) {
						acc_dirs++;
					} else {
						acc_files++; acc_size += Finfo.fsize;
					}
					xprintf("%c%c%c%c%c %u/%02u/%02u %02u:%02u %9lu  %s\n",
							(Finfo.fattrib & AM_DIR) ? 'D' : '-',
							(Finfo.fattrib & AM_RDO) ? 'R' : '-',
							(Finfo.fattrib & AM_HID) ? 'H' : '-',
							(Finfo.fattrib & AM_SYS) ? 'S' : '-',
							(Finfo.fattrib & AM_ARC) ? 'A' : '-',
							(Finfo.fdate >> 9) + 1980, (Finfo.fdate >> 5) & 15, Finfo.fdate & 31,
							(Finfo.ftime >> 11), (Finfo.ftime >> 5) & 63,
							Finfo.fsize, Finfo.fname);
				}
				xprintf("%4u File(s),%10llu bytes total\n%4u Dir(s)", acc_files, acc_size, acc_dirs);
				res = f_getfree(ptr, &dw, &fs);
				if (res == FR_OK) {
					xprintf(", %10llu bytes free\n", (QWORD)dw * fs->csize * 512);
				} else {
					put_rc(res);
				}
				break;

			case 'o' :	/* fo <mode> <file> - Open a file */
				if (!xatoi(&ptr, &p1)) break;
				while (*ptr == ' ') ptr++;
				put_rc(f_open(&File[0], ptr, (BYTE)p1));
				break;

			case 'c' :	/* fc - Close a file */
				put_rc(f_close(&File[0]));
				break;

			case 'e' :	/* fe - Seek file pointer */
				if (!xatoi(&ptr, &p1)) break;
				res = f_lseek(&File[0], p1);
				put_rc(res);
				if (res == FR_OK) {
					xprintf("fptr=%lu(0x%lX)\n", File[0].fptr, File[0].fptr);
				}
				break;

			case 'd' :	/* fd <len> - read and dump file from current fp */
				if (!xatoi(&ptr, &p1)) break;
				ofs = File[0].fptr;
				while (p1) {
					if ((UINT)p1 >= 16) { cnt = 16; p1 -= 16; }
					else				{ cnt = p1; p1 = 0; }
					res = f_read(&File[0], Buff, cnt, &cnt);
					if (res != FR_OK) { put_rc(res); break; }
					if (!cnt) break;
					put_dump(Buff, ofs, cnt, 1);
					ofs += 16;
				}
				break;

			case 'r' :	/* fr <len> - read file */
				if (!xatoi(&ptr, &p1)) break;
				p2 = 0;
				Timer = 0;
				while (p1) {
					if ((UINT)p1 >= blen) {
						cnt = blen; p1 -= blen;
					} else {
						cnt = p1; p1 = 0;
					}
					res = f_read(&File[0], Buff, cnt, &s2);
					if (res != FR_OK) { put_rc(res); break; }
					p2 += s2;
					if (cnt != s2) break;
				}
				xprintf("%lu bytes read with %lu kB/sec.\n", p2, Timer ? (p2 / Timer) : 0);
				break;

			case 'w' :	/* fw <len> <val> - write file */
				if (!xatoi(&ptr, &p1) || !xatoi(&ptr, &p2)) break;
				memset(Buff, (BYTE)p2, blen);
				p2 = 0;
				Timer = 0;
				while (p1) {
					if ((UINT)p1 >= blen) {
						cnt = blen; p1 -= blen;
					} else {
						cnt = p1; p1 = 0;
					}
					res = f_write(&File[0], Buff, cnt, &s2);
					if (res != FR_OK) { put_rc(res); break; }
					p2 += s2;
					if (cnt != s2) break;
				}
				xprintf("%lu bytes written with %lu kB/sec.\n", p2, Timer ? (p2 / Timer) : 0);
				break;

			case 'n' :	/* fn <org.name> <new.name> - Change name of an object */
				while (*ptr == ' ') ptr++;
				ptr2 = strchr(ptr, ' ');
				if (!ptr2) break;
				*ptr2++ = 0;
				while (*ptr2 == ' ') ptr2++;
				put_rc(f_rename(ptr, ptr2));
				break;

			case 'u' :	/* fu <name> - Unlink an object */
				while (*ptr == ' ') ptr++;
				put_rc(f_unlink(ptr));
				break;

			case 'v' :	/* fv - Truncate file */
				put_rc(f_truncate(&File[0]));
				break;

			case 'k' :	/* fk <name> - Create a directory */
				while (*ptr == ' ') ptr++;
				put_rc(f_mkdir(ptr));
				break;

			case 'a' :	/* fa <atrr> <mask> <name> - Change attribute of an object */
				if (!xatoi(&ptr, &p1) || !xatoi(&ptr, &p2)) break;
				while (*ptr == ' ') ptr++;
				put_rc(f_chmod(ptr, p1, p2));
				break;

			case 't' :	/* ft <year> <month> <day> <hour> <min> <sec> <name> - Change timestamp of an object */
				if (!xatoi(&ptr, &p1) || !xatoi(&ptr, &p2) || !xatoi(&ptr, &p3)) break;
				Finfo.fdate = ((p1 - 1980) << 9) | ((p2 & 15) << 5) | (p3 & 31);
				if (!xatoi(&ptr, &p1) || !xatoi(&ptr, &p2) || !xatoi(&ptr, &p3)) break;
				ptr++;
				Finfo.ftime = ((p1 & 31) << 11) | ((p2 & 63) << 5) | ((p3 >> 1) & 31);
				put_rc(f_utime(ptr, &Finfo));
				break;

			case 'x' : /* fx <src.name> <dst.name> - Copy a file */
				while (*ptr == ' ') ptr++;
				ptr2 = strchr(ptr, ' ');
				if (!ptr2) break;
				*ptr2++ = 0;
				while (*ptr2 == ' ') ptr2++;
				xprintf("Opening \"%s\"", ptr);
				res = f_open(&File[0], ptr, FA_OPEN_EXISTING | FA_READ);
				xputc('\n');
				if (res) {
					put_rc(res);
					break;
				}
				xprintf("Creating \"%s\"", ptr2);
				res = f_open(&File[1], ptr2, FA_CREATE_ALWAYS | FA_WRITE);
				xputc('\n');
				if (res) {
					put_rc(res);
					f_close(&File[0]);
					break;
				}
				xprintf("Copying file...");
				Timer = 0;
				p1 = 0;
				for (;;) {
					res = f_read(&File[0], Buff, blen, &s1);
					if (res || s1 == 0) break;   /* error or eof */
					res = f_write(&File[1], Buff, s1, &s2);
					p1 += s2;
					if (res || s2 < s1) break;   /* error or disk full */
				}
				xprintf("\n%lu bytes copied with %lu kB/sec.\n", p1, p1 / Timer);
				f_close(&File[0]);
				f_close(&File[1]);
				break;
#if FF_FS_RPATH
			case 'g' :	/* fg <path> - Change current directory */
				while (*ptr == ' ') ptr++;
				put_rc(f_chdir(ptr));
				break;
#if FF_FS_RPATH >= 2
			case 'q' :	/* fq - Show current dir path */
				res = f_getcwd(Line, sizeof Line);
				if (res)
					put_rc(res);
				else
					xprintf("%s\n", Line);
				break;
#endif
#endif
#if FF_USE_LABEL
			case 'b' :	/* fb <name> - Set volume label */
				while (*ptr == ' ') ptr++;
				put_rc(f_setlabel(ptr));
				break;
#endif	/* FF_USE_LABEL */
#if FF_USE_MKFS
			case 'm' :	/* fm - Create/ Reformat to FAT32 file system */
				{
					MKFS_PARM opt, *popt = 0;
					popt->fmt = FM_FAT32;
					xprintf("The volume will be formatted. Are you sure? (Y/n)=");
					xgets(Line, sizeof Line);
					if (Line[0] == 'Y') put_rc(f_mkfs("", popt, Buff, sizeof Buff));
					break;
				}
#endif	/* FF_USE_MKFS */
			case 'z' :	/* fz [<size>] - Change/Show R/W length for fr/fw/fx command */
				if (xatoi(&ptr, &p1) && p1 >= 1 && p1 <= (long)sizeof Buff)
					blen = p1;
				xprintf("blen=%u\n", blen);
				break;
			}
			break;

		case 't' :	/* t [<hour> <min> <sec> <dayOfTheWeek> <day> <month> <year>] - Set/Show RTC */
			printOrSetRTCTime(ptr);
			break;

		}
	}
}


/******************************************************************************
 *
 * @brief Manages Real Time Clock features
 *
 * This function handles Real Time Clock features. If 't' is input without any
 * argument, it prints the current date and time. If 't' is followed by correct
 * arguments, it attempts to configure the RTC. To configure the RTC argument
 * by argument, input 't' followed by any number, e.g., "t 1".
 *
 * @param ptr Pointer to characters input by user
 * @return true if no error; false if an error occurred
 *
 ******************************************************************************/

bool printOrSetRTCTime(char* ptr){
	long p[7] = {0}; // Initialize all elements to 0
	int i;

	// Passing each argument into p array
	for (i = 0; i < 7; i++) {
	    xatoi(&ptr, &p[i]);
	}

	// If there is no argument provided by the user, print the current time from RTC
	if (!p[0] && !p[1] && !p[2] && !p[3] && !p[4] && !p[5] && !p[6]) {
		getdata(&myConfig);
		bsp_printf("%d/%d/20%s%d \r\n", get_days(&myConfig),
				get_months(&myConfig), (get_years(&myConfig)<10)? "0" : "",get_years(&myConfig));
		bsp_printf("%s,%d%s %s 20%s%d\r\n",
				DayStrings[get_weekdays(&myConfig) - 1], get_days(&myConfig),
				get_days_ordinalno(&myConfig),
				MonthStrings[get_months(&myConfig) - 1], (get_years(&myConfig)<10)? "0" : "",get_years(&myConfig));
		if (myConfig.timesystem == 1){
			//12 hour time system is selected.
			bsp_printf("Current Time: %d:%s%d:%s%d%s  \r\n\n",
					get_hours(&myConfig),
					(get_minutes(&myConfig) < 10) ? "0" : "",
					get_minutes(&myConfig),
					(get_seconds(&myConfig) < 10) ? "0" : "",
					get_seconds(&myConfig),
					(myConfig.PM) ? (meridiem[1]) : (meridiem[0]));
		}
		else{
			// 24 hour time system is selected
			bsp_printf("Current Time: %d:%s%d:%s%d  \r\n\n",
					get_hours(&myConfig),
					(get_minutes(&myConfig) < 10) ? "0" : "",
					get_minutes(&myConfig),
					(get_seconds(&myConfig) < 10) ? "0" : "",
					get_seconds(&myConfig));
		}
		return true;
	}
	// Configure the time and date based on the input
	else { //if (!p[0] && !p[1] && !p[2] && !p[3] && !p[4] && !p[5] && !p[6])
		u8 config = 0x01;
		u8 setting = STATE_HOUR;
		u8 single_line_setting_pass = 0x00;
		//time_data temp;
		// If all argument are there, use the argument parsed in
		if (p[3] && p[4] && p[5] && p[6]){
			uint8_t error = 0;
			uint8_t temp_hours 			= p[0];
    		uint8_t temp_minutes 		= p[1];
    		uint8_t temp_seconds 		= p[2];
    		uint8_t temp_dayofweek 		= p[3];
    		uint8_t temp_day 			= p[4];
    		uint8_t temp_month 			= p[5];
    		uint8_t temp_year 			= p[6];
    		uint8_t alarm_tt  			= p[0];

			error = check_month_error(temp_month, temp_day, temp_year);
			if ((temp_hours > 23) | (temp_minutes > 59) | (temp_seconds > 59) | (temp_dayofweek < 1) | (temp_dayofweek > 7) | (temp_month > 12) | (temp_day < 1) | (temp_month < 1) | (error)) {
				bsp_printf("Invalid input, please try again... \r\n");
				single_line_setting_pass = 0x00;
			} else {
				bsp_printf("\n(24hour System) Time set to %d:%d:%d\r\n", temp_hours, temp_minutes, temp_seconds);
				bsp_printf("%s,%d %s 20%s%d\r\n", DayStrings[temp_dayofweek - 1], temp_day, MonthStrings[temp_month - 1],(temp_year < 10) ? "0" : "", temp_year);
				set_timesystem(0);
				set_datetime(temp_seconds, temp_minutes, temp_hours, \
						temp_dayofweek, temp_day, temp_month, \
						temp_year);
				single_line_setting_pass = 0x01;
			}
		}

		// If failed during configuration or user did not provide correct argument, configure each argument 1 by 1
		// User may press q or Q to exit the configuration.
		if (!single_line_setting_pass){
			bsp_printf("Invalid input. Retrying configuration...\r\n");
			bsp_printf("Press 'q' or 'Q' to exit configuration\r\n");
			uint8_t temp_hours 			= p[0];
    		uint8_t temp_minutes 		= p[1];
    		uint8_t temp_seconds 		= p[2];
    		uint8_t temp_dayofweek 		= p[3];
    		uint8_t temp_day 			= p[4];
    		uint8_t temp_month 			= p[5];
    		uint8_t temp_year 			= p[6];
    		uint8_t alarm_tt  			= p[0];
			while (config){
				switch (setting){

					case STATE_HOUR: // configure hours
						bsp_printf("Enter Current Hour in 24-Hour Time System, i.e. 13 indicates current time 1P.M.\r\n");
						Line[0] = 0x00; // Reset the first char
						xgets(Line, sizeof Line);
						ptr = Line;
						if (ptr[0]== ASCII_LOWER_CASE_Q || ptr[0]== ASCII_UPPER_CASE_Q) { //exit with q or Q
							setting = STATE_EXIT;
						} else if (Line[0] == 0x00){ // If user directly enter
							bsp_printf("Invalid input, please try again\r\n");
						}
						else {
							temp_hours = (ptr[0] - UART_DECIMAL_OFFSET) * 10 + (ptr[1] - UART_DECIMAL_OFFSET);
							if (temp_hours > 24){
								bsp_printf("Invalid input, please try again\r\n");
							}else {
								bsp_printf("Configured to %d hour\r\n", temp_hours);
								setting = STATE_MINUTES;
							}

						}
						break;

					case STATE_MINUTES: // configure minutes
						bsp_printf("Enter Current Minutes, i.e. 00\r\n");
						Line[0] = 0x00;
						xgets(Line, sizeof Line);
						ptr = Line;
						if (ptr[0]== ASCII_LOWER_CASE_Q || ptr[0]== ASCII_UPPER_CASE_Q) { //exit with q or Q
							setting = STATE_EXIT;
						} else if (Line[0] == 0x00){ // If user directly enter
							bsp_printf("Invalid input, please try again\r\n");
						} else {
							temp_minutes = (ptr[0] - UART_DECIMAL_OFFSET) * 10 + (ptr[1] - UART_DECIMAL_OFFSET);
							if (temp_minutes > 59){
								bsp_printf("Invalid input, please try again\r\n");
							}else {
								bsp_printf("Configured to %d minutes\r\n", temp_minutes);
								setting = STATE_SECONDS;
							}

						}
						break;

					case STATE_SECONDS: // configure minutes
						bsp_printf("Enter Current Seconds, i.e. 00\r\n");
						Line[0] = 0x00;
						xgets(Line, sizeof Line);
						ptr = Line;
						if (ptr[0]== ASCII_LOWER_CASE_Q || ptr[0]== ASCII_UPPER_CASE_Q) { //exit with q or Q
							setting = STATE_EXIT;
						} else if (Line[0] == 0x00){ // If user directly enter
							bsp_printf("Invalid input, please try again\r\n");
						} else {
							temp_seconds = (ptr[0] - UART_DECIMAL_OFFSET) * 10 + (ptr[1] - UART_DECIMAL_OFFSET);
							if (temp_seconds > 59){
								bsp_printf("Invalid input, please try again\r\n");
							}else {
								bsp_printf("Configured to %d seconds\r\n", temp_seconds);
								setting = STATE_WEEK_DAY;
							}
						}

						break;

					case STATE_WEEK_DAY: //configure weekdays
						bsp_printf("Enter Current day of the week\r\n");
						bsp_printf("Day of week\r\n1.Sunday\r\n2.Monday\r\n3.Tuesday\r\n4.Wednesday\r\n5.Thursday\r\n6.Friday\r\n7.Saturday\r\n");
						Line[0] = 0x00;
						xgets(Line, sizeof Line);
						ptr = Line;
						if (ptr[0]== ASCII_LOWER_CASE_Q || ptr[0]== ASCII_UPPER_CASE_Q) { //exit with q or Q
							setting = STATE_EXIT;
						}else if (Line[0] == 0x00){ // If user directly enter
							bsp_printf("Invalid input, please try again\r\n");
						} else {
							temp_dayofweek = ptr[0] - UART_DECIMAL_OFFSET;
							if (temp_dayofweek == 0 || temp_dayofweek > 7 ){
								bsp_printf("Invalid input, please try again\r\n");
							}else {
								bsp_printf("Configured to %s\r\n",DayStrings[temp_dayofweek - 1]);
								setting = STATE_YEAR;
							}
						}

						break;

					case STATE_DAYS: //configure days
						bsp_printf("Enter Current day of the month, i.e. 01 for first day of the month \r\n");
						Line[0] = 0x00;
						xgets(Line, sizeof Line);
						ptr = Line;
						temp_day = (ptr[0] - UART_DECIMAL_OFFSET) * 10 + (ptr[1] - UART_DECIMAL_OFFSET);
						if (temp_day < 1 || temp_day > 31){
							bsp_printf("Invalid input, please try again\r\n");
						}else if (Line[0] == 0x00){ // If user directly enter
							bsp_printf("Invalid input, please try again\r\n");
						} else if((!isLeapYear(temp_year) && (temp_day > 29))||((temp_month == 2)&& (temp_day > 29))){
							bsp_printf("Invalid input, please try again\r\n");
						}else {
							bsp_printf("Configured to date %d\r\n",temp_day);
							setting = STATE_CONFIG;
						}
						break;

					case STATE_MONTH: //configure month
						bsp_printf("Enter Current month, i.e. January = 1; February = 2 ... \r\n");
						Line[0] = 0x00;
						xgets(Line, sizeof Line);
						ptr = Line;
						if (ptr[0]== ASCII_LOWER_CASE_Q || ptr[0]== ASCII_UPPER_CASE_Q) { //exit with q or Q
							setting = STATE_EXIT;
						} else if (Line[0] == 0x00){ // If user directly enter
							bsp_printf("Invalid input, please try again\r\n");
						} else {
							if (ptr[1] == 0){
								temp_month = ptr[0] - UART_DECIMAL_OFFSET;
							}else {
								temp_month = (ptr[0] - UART_DECIMAL_OFFSET) * 10 + (ptr[1] - UART_DECIMAL_OFFSET);
							}

							if (temp_month > 12){
								bsp_printf("Invalid input, please try again\r\n");
							}
							else if (temp_month < 1){
								bsp_printf("Invalid input, please try again\r\n");
							}else {
								setting = STATE_DAYS;
								bsp_printf("Configured to month %s\r\n",MonthStrings[temp_month - 1]);
							}
						}

						break;

					case STATE_YEAR: // configure year
						bsp_printf("Enter Current year, i.e. 24 indicates year 2024\r\n");
						Line[0] = 0x00;
						xgets(Line, sizeof Line);
						ptr = Line;
						if (ptr[0]== ASCII_LOWER_CASE_Q || ptr[0]== ASCII_UPPER_CASE_Q) { //exit with q or Q
							setting = STATE_EXIT;
						} else if (Line[0] == 0x00){ // If user directly enter
							bsp_printf("Invalid input, please try again\r\n");
						} else {
							temp_year = (ptr[0] - UART_DECIMAL_OFFSET) * 10 + (ptr[1] - UART_DECIMAL_OFFSET);
							bsp_printf("Configured to year 20%s%d\r\n", (temp_year<10)? "0" : "",temp_year);
							setting = STATE_MONTH;
						}

						break;

					case STATE_CONFIG:
						set_timesystem(0);
						set_datetime(temp_seconds, temp_minutes, temp_hours, temp_dayofweek, temp_day, temp_month, temp_year);
						bsp_printf("RTC configuration successful...\r\n");
						setting = STATE_HOUR;
						config = 0x00;
						continue;
						break;

					case STATE_EXIT:
						bsp_printf("Failed to configure RTC. Exit RTC configuration... \r\n");
						setting = STATE_HOUR;
						config = 0x00;
						return false;
						break;

					default:
						break;
				}

			}
		}
		return true;
	}
}




