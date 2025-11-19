////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2025 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

#ifndef SRC_BMP_H_
#define SRC_BMP_H_
#include <stdint.h>
#include "efx_mmc_driver.h"
#include "device_config.h"
#include "fatfs/ff.h"
#include "fatfs/diskio.h"
#include "fatfs/xprintf.h"
#include "vision/apb3_cam.h"




typedef struct {
    unsigned int file_byte_number;
    unsigned char *file_byte_contents;
    unsigned int pixel_array_start;
    unsigned int width;
    unsigned int height;
    unsigned int depth;
} BMP;

FRESULT img_flush ();
FRESULT bmp_read(FIL *fp, BMP *bmp_data, uint8_t *buffer, UINT *bytes_read);
FRESULT bmp_write(FIL *fp, uint8_t *bmp_buffer, uint32_t width, uint32_t height);
FRESULT dump_buffer_to_file(const char* filename, const void* buf, UINT size);
void clear_ddr_memory();
void ppm_printf(BMP *bmp_data, int padding, int row_size, uint8_t *buffer);






#endif //SRC_BMP_H_
