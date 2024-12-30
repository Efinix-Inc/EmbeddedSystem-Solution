# Embedded Solution Platform - Address Mapping

This guide show the address mapping for the example design of the Soft Sapphire Soc.

## Address Mapping for Soft Sapphire Soc
This is an example design to showcase the Efinix Sapphire SoC integrate with triple speed ethernet, SD host Controller, MIPI Picam and HDMI Display for Ti180J484 and T120F576 devices.

The base address of AXI Interconnect ``SYSTEM_AXI_A_BMB`` is ``0xe1000000``.

| Address    | Bus          | Peripheral                      | Interrupt number |
| ---------- | ------------ | ------------------------------- | ---------------- |
| SYSTEM_AXI_A_BMB | Axi Slave 0  | Vision Hardware Accelerator     | -                |
| SYSTEM_AXI_A_BMB + 0x00800000 | Axi Slave 1  | SD Host Controller              | 23               |
| SYSTEM_AXI_A_BMB + 0x00810000 | Axi Slave 2  | Triple Speed Ethernet           | -                |
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
| 0xf8130000 | Apb3 Slave 3 | Unused                          | -                |
| 0xf8140000 | Apb3 Slave 4 | Unused                          |                  |