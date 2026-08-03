#ifndef OPENAMP_TRANSPORT_H
#define OPENAMP_TRANSPORT_H

#include <stdint.h>

struct rpmsg_device;

struct rpmsg_device *openamp_init(uint32_t timeout_ms);

void openamp_notified(void);

int openamp_kick_linux(void *priv, uint32_t id);

#endif
