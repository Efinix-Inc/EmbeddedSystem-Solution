#ifndef AMP_REMOTE_H
#define AMP_REMOTE_H

#include <stdint.h>

struct rpmsg_device;

struct rpmsg_device *amp_remote_bringup(void);

#endif /* AMP_REMOTE_H */
