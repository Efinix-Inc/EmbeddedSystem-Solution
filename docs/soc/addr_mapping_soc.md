# Embedded Solution Platform - Address Mapping

This guide show the address mapping for the example design of the High Performance Sapphire Soc.

## Address Mapping for High Performance Sapphire Soc
This is an example design to showcase the Efinix Sapphire High Performance SoC integrate with triple speed ethernet, SD host Controller, MIPI Picam and HDMI Display for Ti375C529 devices.

The base address of AXI Interconnect ``SYSTEM_AXI_A_BMB`` is ``0xe8000000``.

| Address    | Bus          | Peripheral                      | Interrupt number |
| ---------- | ------------ | ------------------------------- | ---------------- |
| 0xe8010000 |              | uart0                           | 9                |
| 0xe8020000 |              | i2c0 (MIPI Picam)               | 10               |
| 0xe8021000 |              | i2c1 (RTC: PCF8523)             | 11               |
| 0xe8030000 |              | spi0                            | 12               |
| 0xe8040000 |              | gpio0                           | 14, 15           |
| 0xe8100000 | Apb3 Slave 0 | dma0 (Camera & Display)         | 1                |
| 0xe8200000 | Apb3 Slave 1 | reg: camera & display           | -                |
| 0xe8300000 | Apb3 Slave 2 | dma1 (TSEMAC)                   | 2, 3             |
| SYSTEM_AXI_A_BMB | Axi Slave 0  | Soft Logic Block                | -                |
| SYSTEM_AXI_A_BMB + 0xe1000000  | Axi Slave 1  | SD Host Controller              | 4                |
| SYSTEM_AXI_A_BMB + 0xe1100000  | Axi Slave 2  | Triple Speed Ethernet           | -                |
| SYSTEM_AXI_A_BMB + 0xe1200000 | Axi Slave 3  | Vision Hardware Accelerator     | -                |
