/*
 * bmp.h
 *
 *  Created on: Jan 8, 2025
 *      Author: JasonLau
 */

#ifndef SRC_BMP_H_
#define SRC_BMP_H_
#include <stdint.h>
#include "efx_mmc_driver.h"
#include "device_config.h"
#include "fatfs/ff.h"
#include "fatfs/diskio.h"
#include "fatfs/xprintf.h"
#include "vexriscv.h"
#include "vision/apb3_cam.h"
#include "userDef.h"

typedef struct {
    unsigned int file_byte_number;
    unsigned char *file_byte_contents;
    unsigned int pixel_array_start;
    unsigned int width;
    unsigned int height;
    unsigned int depth;
} BMP;

void ppm_printf(BMP *bmp_data, int padding, int row_size, uint8_t *buffer);
void clear_ddr_memory();

FRESULT bmp_read(FIL *fp, BMP *bmp_data, uint8_t *buffer, UINT *bytes_read) {
    FRESULT res;

    //clear_ddr_memory();

    // Read BMP file in one go
    res = f_read(fp, buffer, bmp_data->file_byte_number, bytes_read);
    if (res != FR_OK) {
        xprintf("Error reading BMP file.\n");
        return res;
    }

    // Populate BMP struct fields
    bmp_data->pixel_array_start = buffer[10] | (buffer[11] << 8) | (buffer[12] << 16) | (buffer[13] << 24);
    bmp_data->width = buffer[18] | (buffer[19] << 8) | (buffer[20] << 16) | (buffer[21] << 24);
    bmp_data->height = buffer[22] | (buffer[23] << 8) | (buffer[24] << 16) | (buffer[25] << 24);
    bmp_data->depth = buffer[28] | (buffer[29] << 8);


    if (bmp_data->depth != 24) {
        xprintf("Unsupported BMP format. Only 24-bit is supported.\n");
        return FR_INVALID_OBJECT;
    }

    xprintf("BMP Info - Width: %u, Height: %u, Bit Depth: %u\n", bmp_data->width, bmp_data->height, bmp_data->depth);

    int row_size = ((bmp_data->width * bmp_data->depth + 31) / 32) * 4;
    int padding = row_size - (bmp_data->width * 3);
    memset(img_array, 0xFF, FRAME_HEIGHT * FRAME_WIDTH * sizeof(uint32_t));
    // Copy pixel data to cam_array
    // Calculate padding to center the image
    unsigned int x_offset = (FRAME_WIDTH - bmp_data->width) / 2;
    unsigned int y_offset = (FRAME_HEIGHT - bmp_data->height) / 2;

    for (unsigned int y = 0; y < FRAME_HEIGHT; y++) {
        for (unsigned int x = 0; x < FRAME_WIDTH; x++) {
            unsigned int index = y * FRAME_WIDTH + x;

#if IMG_POS_CENTER ==1
            // Check if current coordinates fall inside the centered image bounds
            if (y >= y_offset && y < (y_offset + bmp_data->height) &&
                x >= x_offset && x < (x_offset + bmp_data->width)) {

                // Map coordinates from centered frame space to BMP data space
                unsigned int bmp_x = x - x_offset;
                unsigned int bmp_y = bmp_data->height - 1 - (y - y_offset);
                unsigned int pixel_offset = bmp_data->pixel_array_start + (bmp_y * row_size) + (bmp_x * 3);

                // Store pixel as 0x00BBGGRR in img_array
                img_array[index] = (0x00 << 24) |
                                   (buffer[pixel_offset + 0] << 16) |  // Blue
                                   (buffer[pixel_offset + 1] << 8)  |  // Green
                                   (buffer[pixel_offset + 2]);         // Red
#else
             if (y < bmp_data->height && x < bmp_data->width) {
                 // BMP Storing MethodL: Bottom to Top
            	 unsigned int pixel_offset = bmp_data->pixel_array_start + ((bmp_data->height - 1 - y) * row_size) + (x * 3);

                // Store pixel as 0x00BBGGRR in cam_array
                img_array[index] = (0x00 << 24) |
                    			   (buffer[pixel_offset + 0] << 16) |  // Blue
                                   (buffer[pixel_offset + 1] << 8)  |  // Green
                                   (buffer[pixel_offset+ 2]);          // Red

#endif
            } else {
                img_array[index] = 0x00FFFFFF;  // Fill remaining with white
            }
        }
    }

#if PPM_PRINT == 1
    ppm_printf(bmp_data,padding,row_size,buffer);
#endif
    xprintf("Successfully read BMP pixel data.\n");
    return FR_OK;
}


FRESULT img_flush (){

    Set_MipiRst(1);
    Set_MipiRst(0);
	xprintf("Flushing Image buffer\r\n");
//    for (unsigned int y = 0; y < FRAME_HEIGHT; y++) {
//        for (unsigned int x = 0; x < FRAME_WIDTH; x++) {
//            unsigned int index = y * FRAME_WIDTH + x;
//
//                img_array[index] = 0x00FFFFFF;  // Fill remaining with white
//            }
//    }
    return FR_OK;


}

void clear_ddr_memory() {
    volatile uint32_t *ddr_ptr = (volatile uint32_t *)DDR_START_ADDRESS;

    for (size_t i = 0; i < (DDR_SIZE / sizeof(uint32_t)); i++) {
        ddr_ptr[i] = 0x00;  // Clear to zero
    }
}

void ppm_printf(BMP *bmp_data, int padding, int row_size, uint8_t *buffer){
    unsigned int index;
    xprintf("P3\r\n%u %u\r\n255\r\n",bmp_data->width,bmp_data->height);
    for (unsigned int y = 0; y < bmp_data->height; y++) {
        for (unsigned int x = 0; x < bmp_data->width; x++) {
        	index = y * (bmp_data->width) + x;
        	unsigned int pixel_offset = bmp_data->pixel_array_start + ((bmp_data->height - 1 - y) * row_size) + (x * 3);  // 3 for BGR (Blue, Green, Red)

            // BMP stores pixels in BGR format (Blue, Green, Red)
            //unsigned int pixel_offset = (y * width + x) * 3;
            uint8_t b = buffer[pixel_offset];
            uint8_t g = buffer[pixel_offset + 1];
            uint8_t r = buffer[pixel_offset + 2];

            xprintf("%u %u %u\n", r, g, b); // Write RGB values
        }
    }
}






#endif //SRC_BMP_H_
