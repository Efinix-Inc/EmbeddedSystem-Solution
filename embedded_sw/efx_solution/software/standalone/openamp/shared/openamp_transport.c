////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2026 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

#include <stdint.h>
#include <stdbool.h>
#include <string.h>

#include "bsp.h"
#include "sbi.h"
#include "shm_layout.h"

#include "openamp/open_amp.h"
#include "openamp/remoteproc.h"
#include "openamp/remoteproc_virtio.h"
#include "openamp/rpmsg_virtio.h"
#include "openamp_transport.h"
#include "metal/io.h"
#include "metal/sys.h"

static struct metal_io_region g_shm_io;
static struct rpmsg_virtio_shm_pool g_shpool;
static struct rpmsg_virtio_device g_rvdev;
static struct virtio_device *g_vdev;

#define DRAM_BASE   SHM_BASE
#define DRAM_SIZE   SHM_SIZE

static const metal_phys_addr_t g_shm_physmap[] = { DRAM_BASE };

struct demo_rsc_table {
    uint32_t ver;
    uint32_t num;
    uint32_t reserved[2];
    uint32_t offset[1];
    struct fw_rsc_vdev vdev;
    struct fw_rsc_vdev_vring vring[2];
};

int openamp_kick_linux(void *priv, uint32_t id)
{
    volatile uint32_t *kick = (volatile uint32_t *)SHM_KICK_R2L_ADDR;
    unsigned long mask;

    *kick = *kick + 1;

    /* ensure all memory reads/writes complete before proceeding */
    __asm__ volatile ("fence rw, rw" ::: "memory");

    mask = 1UL << LINUX_BOOT_HARTID;
    sbi_send_ipi(&mask);

    return 0;
}

static int init_libmetal(void)
{
    struct metal_init_params params = METAL_INIT_DEFAULTS;

    int rc = metal_init(&params);
    if (rc) {
        bsp_printf("BareMetal: metal_init failed: %d\r\n", rc);
        return rc;
    }

    metal_io_init(&g_shm_io,
                  (void *)DRAM_BASE,
                  g_shm_physmap,
                  DRAM_SIZE,
                  -1U,
                  0,
                  NULL);

    return 0;
}

static int validate_rsc_table(void)
{
    volatile struct demo_rsc_table *rsc =
        (volatile struct demo_rsc_table *)SHM_RSC_ADDR;

    for (;;) {
        if (rsc->ver == 1 &&
            rsc->num == 1 &&
            rsc->vdev.type == RSC_VDEV &&
            rsc->vdev.id == VIRTIO_ID_RPMSG &&
            rsc->vdev.num_of_vrings == 2 &&
            rsc->vring[0].da == SHM_VRING0_ADDR &&
            rsc->vring[1].da == SHM_VRING1_ADDR) {
            __asm__ volatile ("fence rw, rw" ::: "memory");
            return 0;
        } else {
            bsp_printf("BareMetal: validate_rsc_table failed\r\n");
            return -1;
        }
    }
}

static struct rpmsg_device *bring_up_rpmsg(uint32_t timeout_ms)
{
    struct demo_rsc_table *rsc = (struct demo_rsc_table *)SHM_RSC_ADDR;
    int rc;

    g_vdev = rproc_virtio_create_vdev(VIRTIO_DEV_DEVICE,
                                      VDEV_NOTIFY_ID,
                                      &rsc->vdev,
                                      &g_shm_io,
                                      NULL,
                                      openamp_kick_linux,
                                      NULL);
    if (!g_vdev) {
        bsp_printf("BareMetal: rproc_virtio_create_vdev failed\r\n");
        return NULL;
    }

    rc = rproc_virtio_init_vring(g_vdev, 0, VRING0_NOTIFY_ID,
                                 (void *)SHM_VRING0_ADDR, &g_shm_io,
                                 VRING_NUM_DESCS, VRING_ALIGN);
    if (rc) {
        bsp_printf("BareMetal: init_vring(0) failed: %d\r\n", rc);
        return NULL;
    }

    rc = rproc_virtio_init_vring(g_vdev, 1, VRING1_NOTIFY_ID,
                                 (void *)SHM_VRING1_ADDR, &g_shm_io,
                                 VRING_NUM_DESCS, VRING_ALIGN);
    if (rc) {
        bsp_printf("BareMetal: init_vring(1) failed: %d\r\n", rc);
        return NULL;
    }

    rpmsg_virtio_init_shm_pool(&g_shpool,
                               (void *)SHM_BUFPOOL_ADDR,
                               SHM_BUFPOOL_SIZE);

    (void)timeout_ms;
    rc = rpmsg_init_vdev(&g_rvdev, g_vdev,
                         NULL,
                         &g_shm_io,
                         &g_shpool);
    if (rc) {
        bsp_printf("BareMetal: rpmsg_init_vdev failed: %d\r\n", rc);
        return NULL;
    }

    return &g_rvdev.rdev;
}

struct rpmsg_device *openamp_init(uint32_t timeout_ms)
{
    if (init_libmetal())
        return NULL;

    if (validate_rsc_table())
        return NULL;

    return bring_up_rpmsg(timeout_ms);
}

void openamp_notified(void)
{
    if (g_vdev) {
        rproc_virtio_notified(g_vdev, RSC_NOTIFY_ID_ANY);
    }
}
