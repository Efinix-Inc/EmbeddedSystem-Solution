////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2025 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////


#include "platform/misc/bmp.h"

FRESULT dump_buffer_to_file(const char* filename, const void* buf, UINT size) {
   FIL file;
   UINT bw;
   FRESULT res = f_open(&file, filename, FA_CREATE_ALWAYS | FA_WRITE);
   if (res != FR_OK) return res;
   res = f_write(&file, buf, size, &bw);
   f_close(&file);
   if (res != FR_OK || bw != size) return FR_INT_ERR;
   return FR_OK;
}

FRESULT bmp_write(FIL *fp, uint8_t *bmp_buffer, uint32_t width, uint32_t height) {
    FRESULT res;
    UINT bytes_written;

    data_cache_invalidate_all();
    uint32_t row_size = ((width * 24 + 31) / 32) * 4;  // Row size in bytes (padded to 4-byte boundaries)
    uint32_t pixel_array_size = row_size * height;
    uint32_t file_size = 54 + pixel_array_size;  // 54 = BMP Header (14) + DIB Header (40)

    // Fill BMP Header
    uint8_t *ptr = bmp_buffer;
    ptr[0] = 0x42; ptr[1] = 0x4D;  // Signature 'BM'
    ptr[2] = file_size & 0xFF; ptr[3] = (file_size >> 8) & 0xFF;
    ptr[4] = (file_size >> 16) & 0xFF; ptr[5] = (file_size >> 24) & 0xFF;  // File size
    ptr[6] = 0x00; ptr[7] = 0x00; ptr[8] = 0x00; ptr[9] = 0x00;           // Reserved
    ptr[10] = 0x36; ptr[11] = 0x00; ptr[12] = 0x00; ptr[13] = 0x00;       // Pixel data offset (54 bytes)

    // Fill DIB Header
    ptr[14] = 0x28; ptr[15] = 0x00; ptr[16] = 0x00; ptr[17] = 0x00;       // Header size (40 bytes)
    ptr[18] = width & 0xFF; ptr[19] = (width >> 8) & 0xFF;
    ptr[20] = (width >> 16) & 0xFF; ptr[21] = (width >> 24) & 0xFF;       // Image width
    ptr[22] = height & 0xFF; ptr[23] = (height >> 8) & 0xFF;
    ptr[24] = (height >> 16) & 0xFF; ptr[25] = (height >> 24) & 0xFF;     // Image height
    ptr[26] = 0x01; ptr[27] = 0x00;                                       // Planes (1)
    ptr[28] = 0x18; ptr[29] = 0x00;                                       // Bit count (24 bits per pixel)
    ptr[30] = 0x00; ptr[31] = 0x00; ptr[32] = 0x00; ptr[33] = 0x00;       // Compression (0 = BI_RGB)
    ptr[34] = pixel_array_size & 0xFF; ptr[35] = (pixel_array_size >> 8) & 0xFF;
    ptr[36] = (pixel_array_size >> 16) & 0xFF; ptr[37] = (pixel_array_size >> 24) & 0xFF; // Pixel array size
    ptr[38] = 0x13; ptr[39] = 0x0B; ptr[40] = 0x00; ptr[41] = 0x00;       // Horizontal resolution (72 DPI)
    ptr[42] = 0x13; ptr[43] = 0x0B; ptr[44] = 0x00; ptr[45] = 0x00;       // Vertical resolution (72 DPI)
    ptr[46] = 0x00; ptr[47] = 0x00; ptr[48] = 0x00; ptr[49] = 0x00;       // Colors in palette (0)
    ptr[50] = 0x00; ptr[51] = 0x00; ptr[52] = 0x00; ptr[53] = 0x00;       // Important colors (0)


    // Fill Pixel Data
    uint8_t *pixel_data = bmp_buffer + 54;
    for (int y = height - 1; y >= 0; y--) {  // BMP stores rows bottom-to-top
        uint8_t *row_ptr = pixel_data + (height - 1 - y) * row_size;  // Write rows in bottom-to-top order
        memset(row_ptr, 0, row_size);

        for (int x = 0; x < width; x++) {
            uint32_t pixel = ((uint32_t *)img_array)[y * width + x];  // Get pixel from DDR buffer
            row_ptr[x * 3 + 0] = (pixel >> 16) & 0xFF;  // Blue
            row_ptr[x * 3 + 1] = (pixel >> 8) & 0xFF;   // Green
            row_ptr[x * 3 + 2] = (pixel >> 0) & 0xFF;   // Red
        }
    }

    // Write the entire buffer to the file
    res = f_write(fp, bmp_buffer, file_size, &bytes_written);
    if (res != FR_OK || bytes_written != file_size) {
        xprintf("Failed to write BMP file.\n");
    } else {
        xprintf("Successfully saved BMP file.\n");
    }

    return FR_OK;

}


FRESULT bmp_read(FIL *fp, BMP *bmp_data, uint8_t *buffer, UINT *bytes_read) {
    FRESULT res;

    data_cache_invalidate_all();
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
                img_array[index] = 0x00FFFFFF; //   // Fill remaining with white
            }
        }
    }

#if PPM_PRINT == 1
    ppm_printf(bmp_data,padding,row_size,buffer);
#endif
    data_cache_invalidate_all();
    xprintf("Successfully read BMP pixel data.\n");
    return FR_OK;
}

//
//FRESULT img_flush (){
//
//    Set_MipiRst(1);
//    Set_MipiRst(0);
//	xprintf("Flushing Image buffer\r\n");
////    for (unsigned int y = 0; y < FRAME_HEIGHT; y++) {
////        for (unsigned int x = 0; x < FRAME_WIDTH; x++) {
////            unsigned int index = y * FRAME_WIDTH + x;
////
////                img_array[index] = 0x00FFFFFF;  // Fill remaining with white
////            }
////    }
//    return FR_OK;
//
//
//}
//
//void clear_ddr_memory() {
//    volatile uint32_t *ddr_ptr = (volatile uint32_t *)DDR_START_ADDRESS;
//
//    for (size_t i = 0; i < (DDR_SIZE / sizeof(uint32_t)); i++) {
//        ddr_ptr[i] = 0x00;  // Clear to zero
//    }
//}

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







