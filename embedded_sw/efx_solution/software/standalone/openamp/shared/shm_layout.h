#ifndef SHARED_LAYOUT_H
#define SHARED_LAYOUT_H

#include <stdint.h>

#define REMOTE_ENTRY_ADDR    0x04000000UL
#define REMOTE_REGION_SIZE   (2UL * 1024UL * 1024UL)

#define SHM_BASE             0x04200000UL
#define SHM_SIZE             (62UL * 1024UL * 1024UL)

#define SHM_RSC_OFF          0x0000UL
#define SHM_RSC_SIZE         0x0100UL

#define SHM_KICK_R2L_OFF     0x0100UL
#define SHM_KICK_L2R_OFF     0x0104UL
#define SHM_REMOTE_READY_OFF 0x0110UL
#define SHM_LINUX_READY_OFF  0x0114UL
#define SHM_LINUX_CTRL_OFF   0x0118UL

#define REMOTE_READY_MAGIC   0x524D4554UL    /* 'RMET' */
#define LINUX_READY_MAGIC    0x4C4E5852UL    /* 'LNXR' */

#define SHM_VRING0_OFF       0x2000UL        /* Remote TX / Linux RX */
#define SHM_VRING1_OFF       0x4000UL        /* Linux TX  / Remote RX */
#define SHM_VRING_SIZE       0x2000UL

#define SHM_BUFPOOL_OFF      0x10000UL
#define SHM_BUFPOOL_SIZE     0x3C00000

#define VRING_NUM_DESCS      16
#define VRING_ALIGN          4096

#define VDEV_NOTIFY_ID       0
#define VRING0_NOTIFY_ID     1
#define VRING1_NOTIFY_ID     2

#define DEMO_CHANNEL_NAME    "rpmsg-raw"
#define DEMO_EPT_ADDR        30
#define DEMO_MAX_PAYLOAD     496           /* 512 - sizeof(rpmsg_hdr) */

#define REMOTE_HARTID        3
#define LINUX_HARTID         0

#define SHM_RSC_ADDR            (SHM_BASE + SHM_RSC_OFF)
#define SHM_KICK_R2L_ADDR       (SHM_BASE + SHM_KICK_R2L_OFF)
#define SHM_KICK_L2R_ADDR       (SHM_BASE + SHM_KICK_L2R_OFF)
#define SHM_REMOTE_READY_ADDR   (SHM_BASE + SHM_REMOTE_READY_OFF)
#define SHM_LINUX_READY_ADDR    (SHM_BASE + SHM_LINUX_READY_OFF)
#define SHM_LINUX_CTRL_ADDR     (SHM_BASE + SHM_LINUX_CTRL_OFF)
#define SHM_VRING0_ADDR         (SHM_BASE + SHM_VRING0_OFF)
#define SHM_VRING1_ADDR         (SHM_BASE + SHM_VRING1_OFF)
#define SHM_BUFPOOL_ADDR        (SHM_BASE + SHM_BUFPOOL_OFF)

#endif
