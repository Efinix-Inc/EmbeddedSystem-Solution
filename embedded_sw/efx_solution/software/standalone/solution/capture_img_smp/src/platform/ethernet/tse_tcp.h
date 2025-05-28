////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2025 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////
#ifndef HEADER_TSE_TCP_H_
#define HEADER_TSE_TCP_H_

#include <stdint.h>
#include "bsp.h"
#include "userDef.h"
#include "device_config.h"
#include "prescaler.h"
#include "clint.h"
#include "plic.h"

//Lwip Library
#include "lwip/init.h"
#include "lwip/ip4_addr.h"
#include "lwip/ip_addr.h"
#include "lwip/netif.h"
#include "lwip/timeouts.h"
#include "netif/ethernet.h"
#include "ethernetif.h"
#include "lwiperf.h"
#include "lwip/tcp.h"
#include "platform/sd/sd.h"

//Phy Driver
#include "efx_tse_mac.h"
#include "efx_tse_phy.h"

/**************************** TSE **************************/
/*Static IP ADDRESS: IP_ADDR0.IP_ADDR1.IP_ADDR2.IP_ADDR3 */
 #define IP_ADDR0                    configIP_ADDR0
 #define IP_ADDR1                    configIP_ADDR1
 #define IP_ADDR2                    configIP_ADDR2
 #define IP_ADDR3                    configIP_ADDR3
 #define MIN(a,b)  ((a) < (b) ? (a) : (b))
 /*NETMASK*/
 #define NETMASK_ADDR0               255
 #define NETMASK_ADDR1               255
 #define NETMASK_ADDR2               255
 #define NETMASK_ADDR3                 0

 /*Gateway Address*/
 #define GW_ADDR0                    configIP_ADDR0
 #define GW_ADDR1                    configIP_ADDR1
 #define GW_ADDR2                    configIP_ADDR2
 #define GW_ADDR3                    1
 /* USER CODE END 0 */
#define MAX_RETRIES					30

 ip4_addr_t ipaddr;
 ip4_addr_t netmask;
 ip4_addr_t gw;
 ip4_addr_t client_addr;

 err_t tcp_server_accept(void *arg, struct tcp_pcb *newpcb, err_t err);
 err_t tcp_server_recv(void *arg, struct tcp_pcb *tpcb, struct pbuf *p, err_t err);
 u64_t sys_now();
 u64_t sys_jiffies();
 void isrInit();
 void additionalSetting();
 void start_tcp_server( uint8_t send_f);
 void trap_entry();
 void LwIP_Init();
 void tse_tcp_init();
 void tse_tcp_main();
 err_t send_file_data(struct tcp_pcb *tpcb);
 err_t tcp_server_sendfile(void *arg, struct tcp_pcb *newpcb, err_t err);
 struct netif gnetif;
 extern int incoming_packet;
 static struct tcp_pcb *pcb;
 err_t tcp_server_receive(void *arg, struct tcp_pcb *tpcb, struct pbuf *p, err_t err);
 struct tcp_pcb *tcp_server_init(void);
 err_t my_sent_callback(void *arg, struct tcp_pcb *pcb, u16_t len) ;
 UINT read_file(const char *filename);
 void send_file(UINT bytes_read, struct tcp_pcb *tpcb, const char *filename);

 UINT bytes_read;
 char filename[32];

int i;
uint8_t *ptr_Buff;
uint32_t chunk_size;
uint32_t remaining;
uint32_t total_bytes_sent;
#endif
