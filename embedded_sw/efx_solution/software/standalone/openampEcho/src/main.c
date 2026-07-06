////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2026 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////
/*
 * openampEcho -- minimal rpmsg echo remote app.
 *
 */

#include <stdint.h>
#include <stddef.h>
#include <string.h>
#include <stdio.h>

#include "bsp.h"

#include "openamp/open_amp.h"
#include "openamp_transport.h"
#include "amp_remote.h"
#include "shm_layout.h"

static struct rpmsg_endpoint demo_ept;
static uint32_t msg_counter = 0;

static int demo_ept_cb(struct rpmsg_endpoint *ept, void *data,
                       size_t len, uint32_t src, void *priv)
{
    /* Echo the exact received data back to the sender */
    rpmsg_sendto(ept, data, len, src);

    return RPMSG_SUCCESS;
}

void main(void)
{
    uint8_t dat;

    struct rpmsg_device *rdev = amp_remote_bringup();
    if (!rdev) {
        bsp_printf("BareMetal: openamp_init returned NULL (expected without peer)\r\n");
    } else {
        bsp_printf("BareMetal: openamp_init OK -- creating demo endpoint\r\n");
        int rc = rpmsg_create_ept(&demo_ept, rdev,
                                  DEMO_CHANNEL_NAME,
                                  DEMO_EPT_ADDR,
                                  RPMSG_ADDR_ANY,
                                  demo_ept_cb,
                                  NULL);
        if (rc) {
            bsp_printf("BareMetal: rpmsg_create_ept failed: %d\r\n", rc);
        } else {
            bsp_printf("BareMetal: endpoint created at addr %d\r\n",
                       (int)DEMO_EPT_ADDR);
        }
    }

    bsp_printf("BareMetal: NS announcement Completed, idling\r\n");

    while (1) {
        while (uart_readOccupancy(BSP_UART_TERMINAL)) {
            dat = uart_read(BSP_UART_TERMINAL);
            bsp_printf("Char From Keyboard: %c \r\n", dat);
        }
    }
}
