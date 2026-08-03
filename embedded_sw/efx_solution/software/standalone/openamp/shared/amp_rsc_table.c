////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2026 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

#include <stdint.h>
#include <stddef.h>
#include <string.h>

#include "openamp/open_amp.h"
#include "shm_layout.h"
#include "amp_rsc_table.h"

struct rsc_table_layout {
    uint32_t ver;
    uint32_t num;
    uint32_t reserved[2];
    uint32_t offset[1];
    struct fw_rsc_vdev vdev;
    struct fw_rsc_vdev_vring vring[2];
} __attribute__((packed));

void amp_publish_rsc_table(void)
{
    struct rsc_table_layout tmpl = {
        .ver       = 1,
        .num       = 1,
        .reserved  = { 0, 0 },
        .offset    = { offsetof(struct rsc_table_layout, vdev) },
        .vdev = {
            .type          = RSC_VDEV,
            .id            = VIRTIO_ID_RPMSG,
            .notifyid      = VDEV_NOTIFY_ID,
            .dfeatures     = 1u << VIRTIO_RPMSG_F_NS,
            .gfeatures     = 0,
            .config_len    = 0,
            .status        = 0,
            .num_of_vrings = 2,
            .reserved      = { 0, 0 },
        },
        .vring = {
            [0] = {
                .da       = SHM_VRING0_ADDR,
                .align    = VRING_ALIGN,
                .num      = VRING_NUM_DESCS,
                .notifyid = VRING0_NOTIFY_ID,
                .reserved = 0,
            },
            [1] = {
                .da       = SHM_VRING1_ADDR,
                .align    = VRING_ALIGN,
                .num      = VRING_NUM_DESCS,
                .notifyid = VRING1_NOTIFY_ID,
                .reserved = 0,
            },
        },
    };

    memcpy((void *)SHM_RSC_ADDR, &tmpl, sizeof(tmpl));

    *(volatile uint32_t *)SHM_KICK_R2L_ADDR     = 0;
    *(volatile uint32_t *)SHM_KICK_L2R_ADDR     = 0;
    *(volatile uint32_t *)SHM_REMOTE_READY_ADDR = 0;
    *(volatile uint32_t *)SHM_LINUX_READY_ADDR  = 0;
    *(volatile uint32_t *)SHM_LINUX_CTRL_ADDR   = 0;

    __asm__ volatile ("fence rw, rw" ::: "memory");
}
