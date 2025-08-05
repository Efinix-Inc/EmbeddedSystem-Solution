////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2025 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////
#ifndef ISP_H
#define ISP_H

#include <stdint.h>
#define ABS(x)       (x < 0 ? -x : x)

void rgb2grayscale (volatile uint32_t in_array [], volatile uint32_t out_array [], uint32_t width, uint32_t height);
void sobel_edge_detection (volatile uint32_t in_array [], volatile uint32_t out_array [], uint32_t width, uint32_t height);
void binary_erosion (volatile uint32_t in_array [], volatile uint32_t out_array [], uint32_t width, uint32_t height);
void binary_dilation (volatile uint32_t in_array [], volatile uint32_t out_array [], uint32_t width, uint32_t height);

#endif