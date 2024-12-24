# Embedded Solution Platform - Address Mapping

This guide show the address mapping for the example design of the Soft Sapphire Soc and High Performance Sapphire Soc.

## Address Mapping for High Performance Sapphire Soc
This is an example design to showcase the Efinix Sapphire High Performance SoC integrate with triple speed ethernet, SD host Controller, MIPI Picam and HDMI Display for Ti375C529 devices.

| Address    | Bus          | Peripheral                      | Interrupt number |
| ---------- | ------------ | ------------------------------- | ---------------- |
| 0xe8000000 | Axi Slave 0  | Soft Logic Block                | -                |
| 0xe8010000 |              | uart0                           | 9                |
| 0xe8020000 |              | i2c0 (MIPI Picam)               | 10               |
| 0xe8021000 |              | i2c1 (RTC: PCF8523)             | 11               |
| 0xe8030000 |              | spi0                            | 12               |
| 0xe8040000 |              | gpio0                           | 14, 15           |
| 0xe8100000 | Apb3 Slave 0 | dma0 (Camera & Display)         | 1                |
| 0xe8200000 | Apb3 Slave 1 | reg: camera & display           | -                |
| 0xe8300000 | Apb3 Slave 2 | dma1 (TSEMAC)                   | 2, 3             |
| 0xe9000000 | Axi Slave 1  | SD Host Controller              | 4                |
| 0xe9100000 | Axi Slave 2  | Triple Speed Ethernet           | -                |
| 0xe9200000 | Axi Slave 3  | Vision Hardware Accelerator     | -                |


## Address Mapping for Soft Sapphire Soc
This is an example design to showcase the Efinix Sapphire SoC integrate with triple speed ethernet, SD host Controller, MIPI Picam and HDMI Display for Ti180J484 and T120F576 devices.

| Address    | Bus          | Peripheral                      | Interrupt number |
| ---------- | ------------ | ------------------------------- | ---------------- |
| 0xe1000000 | Axi Slave 0  | Vision Hardware Accelerator     | -                |
| 0xe1800000 | Axi Slave 1  | SD Host Controller              | 23               |
| 0xe1810000 | Axi Slave 2  | Triple Speed Ethernet           | -                |
| 0xf8010000 |              | uart0                           | 1                |
| 0xf8014000 |              | spi0                            | 4                |
| 0xf8015000 |              | spi1                            | 5                |
| 0xf8016000 |              | gpio0                           | 12, 13           |
| 0xf8017000 |              | i2c0 (MIPI Picam)               | 8                |
| 0xf8018000 |              | i2c1 (RTC: PCF8523)             | 9                |
| 0xf8019000 |              | i2c2 (Unused)                   | 10               |
| 0xf8130000 | Apb3 Slave 0 | dma0 (Camera & Display)         | 16               |
| 0xf8110000 | Apb3 Slave 1 | reg: camera & display           | -                |
| 0xf8120000 | Apb3 Slave 2 | dma1 (TSEMAC)                   | 17, 22           |
| 0xf8130000 | Apb3 Slave 3 | APB3_demo                       | -                |
| 0xf8140000 | Apb3 Slave 4 | Unused                          |                  |