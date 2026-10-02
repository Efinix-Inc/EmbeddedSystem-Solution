# eMMC Host Controller User Guide

## Contents

*   **[1 Important Note](#1-important-note)**
*   **[2 Introduction](#2-introduction)**
*   **[3 Features](#3-features)**
*   **[4 Functional Description](#4-functional-description)**
    *   [4.1 Initialization](#41-initialization)
    *   [4.2 Block Read Operation](#42-block-read-operation)
    *   [4.3 Block Write Operation](#43-block-write-operation)
    *   [4.4 ADMA transfer](#44-adma-transfer)
*   **[5 Parameter Configuration](#5-parameter-configuration)**
    *   [5.1 IP Configuration](#51-ip-configuration)
    *   [5.2 PLL Configuration](#52-pll-configuration)
*   **[6 High/Low Temperature Operation](#6-highlow-temperature-operation)**
    *   [6.1 Temperature Drift](#61-temperature-drift)
    *   [6.2 Tested Working Conditions](#62-tested-working-conditions)
*   **[7 Resource Utilization](#7-resource-utilization)**
*   **[8 Interface Description](#8-interface-description)**
    *   [8.1 System Signal](#81-system-signal)
    *   [8.2 Phase Adjustment Signal](#82-phase-adjustment-signal)
    *   [8.3 AXI4-Lite Interface Signal](#83-axi4-lite-interface-signal)
    *   [8.4 AXI4 Interface Signal](#84-axi4-interface-signal)
    *   [8.5 eMMC Interface Signal](#85-emmc-interface-signal)
*   **[9 Register Space](#9-register-space)**
    *   [9.1 Version (0x000)](#91-version-0x000)
    *   [9.2 Base Register 0 (0x004)](#92-base-register-0-0x004)
    *   [9.3 Base Status Register 0 (0x008)](#93-base-status-register-0-0x008)
    *   [9.4 Base Register 1 (0x00C)](#94-base-register-1-0x00c)
    *   [9.5 Argument 2 Register (0x100)](#95-argument-2-register-0x100)
    *   [9.6 Block Size Register (0x104)](#96-block-size-register-0x104)
    *   [9.7 Argument 1 Register (0x108)](#97-argument-1-register-0x108)
    *   [9.8 Transfer Mode Register (0x10C)](#98-transfer-mode-register-0x10c)
    *   [9.9 Command Response Register0 (0x110)](#99-command-response-register0-0x110)
    *   [9.10 Command Response Register1 (0x114)](#910-command-response-register1-0x114)
    *   [9.11 Command Response Register2 (0x118)](#911-command-response-register2-0x118)
    *   [9.12 Command Response Register3 (0x11C)](#912-command-response-register3-0x11c)
    *   [9.13 Buffer Data Port Register (0x120)](#913-buffer-data-port-register-0x120)
    *   [9.14 Present State Register (0x124)](#914-present-state-register-0x124)
    *   [9.15 Host Control Register (0x128)](#915-host-control-register-0x128)
    *   [9.16 Interrupt Status Register (0x130)](#916-interrupt-status-register-0x130)
    *   [9.17 Interrupt Status Enable Register (0x134)](#917-interrupt-status-enable-register-0x134)
    *   [9.18 Interrupt Signal Enable Register (0x138)](#918-interrupt-signal-enable-register-0x138)
    *   [9.19 Host Capabilities Register (0x140)](#919-host-capabilities-register-0x140)
    *   [9.20 Host Adjustment Register (0x144)](#920-host-adjustment-register-0x144)
    *   [9.21 ADMA System Address Register (0x158)](#921-adma-system-address-register-0x158)
    *   [9.22 ADMA System Address Register (0x15C)](#922-adma-system-address-register-0x15c)
*   **[10 Example Design Description](#10-example-design-description)**
    *   [10.1 Block Diagram](#101-block-diagram)
    *   [10.2 System Register](#102-system-register)
*   **[11 Driver Description](#11-driver-description)**
    *   [11.1 User Parameter](#111-user-parameter)
    *   [11.2 Functions](#112-functions)
    *   [11.3 Test Function](#113-test-function)
*   **[12 Usage](#12-usage)**

---

## 1. Important Note

This eMMC host controller is not a full-featured implementation; it implements a subset of the eMMC 5.1 specification. Essential operations such as read/write/erase/trim are supported. It supports HS200 SDR x4/x8, HS400 DDR x8, and frequency up to 200MHz.

## 2. Introduction

The eMMC Host Controller is a standard storage controller for accessing embedded multimedia cards (eMMC), and its basic functional block diagram is shown below.

![ip-diagram.png](../images/emmc/ip_diagram.png)
> **Figure 1:** eMMC Host Controller Block Diagram


*   **Clock Management:** Generates clock to eMMC device.
*   **Command Control:** Sends commands and receives responses from eMMC devices.
*   **Data Control:** Sends data from the host and receives data from the eMMC device.
*   **Buffer Control:** Caches data sent by the host and read data responded by the eMMC device.
*   **DMA Engine:** Implements the ADMA data transfer protocol.
*   **Register:** Contains control registers of eMMC host controller, response registers of eMMC device.
*   **DDIO Adapt:** Converts SDR to DDR and vice versa.

## 3. Features

**Table 1: Supported Mode**

| Mode | Data Rate | Bus Width | Frequency |
| :--- | :--- | :--- | :--- |
| HS200 | Single | 4/8 | 0~200MHz <sup>(2)</sup> |
| HS400 <sup>(1)</sup> | Dual | 8 | 0~200MHz <sup>(2)</sup> |

*   Supports ADMA and non-ADMA <sup>(3)</sup> data transfer.
*   Supports single and multi-block data transfer.
*   Supports commands and data CRC checksums.
*   Supports interrupts such as command completion, data transfer completion, command timeout error, command checksum error, command parameter error, data checksum error, etc.
*   AXI4-lite interface for register configuration, AXI4 interface for data transfer.

> **Note 1:** Only eMMC chips that support CMD21 commands in HS400 mode are supported.
> **Note 2:** Supports 200 MHz and its even sub-frequencies.
> **Note 3:** non-ADMA refers to data transfer via register reads and writes.

## 4. Functional Description

### 4.1 Initialization

During the power-up process, the eMMC Host Controller must go through the initialization and device identification process before data transmission. During the device identification process, the eMMC Host Controller needs to read the basic information of the eMMC device (including information such as OCR register, CID number, CSD register, etc.), and it also needs to assign a relative address to the eMMC device, and at the same time ensure that the eMMC device is ready to be accessed.

### 4.2 Block Read Operation

The eMMC Host Controller supports single block read and multi-block read operations and supports a maximum block length of 512 bytes.
For single block read, `CMD17` (READ_SINGLE_BLOCK) command is sent to the eMMC device.
For multi-block read, `CMD18` (READ_MULTIPLE_BLOCK) command is sent to the eMMC device as a start indication, and then consecutive blocks are received, and finally `CMD12` (STOP_TRANSMISSION) command as a stop transmission indication.

### 4.3 Block Write Operation

The eMMC Host Controller supports single block write and multi-block write operations, and the maximum block length supported is 512 bytes.
For single block write, send `CMD24` (WRITE_BLOCK) command to eMMC device.
For multi-block write, send `CMD25` (WRITE_MULTIPLE_BLOCK) command to the eMMC device as a start indication, then write data blocks continuously, and finally send `CMD12` (STOP_TRANSMISSION) command to stop the transmission.

### 4.4 ADMA transfer

The eMMC Host Controller supports Advanced Direct Memory Access (ADMA) data transfers, which are generally used in situations where large amounts of data are being moved.
First, users need to create a descriptor list in the system memory, each descriptor can transfer up to 65536 bytes, if you need to transfer more data, you need to create more descriptors. After creating the descriptor list, start ADMA, the eMMC Host Controller automatically fetches the descriptors from the system memory and starts the data transfer.
The last descriptor must contain a stop bit message to indicate that it is the last data to be transferred. When the last descriptor is executed and the data transfer is complete, ADMA generates an interrupt to the CPU.

## 5. Parameter Configuration

### 5.1 IP Configuration

**Table 2: IP User Parameter Definitions**

| Parameter | Value | Description |
| :--- | :--- | :--- |
| `ADMA_DATA_WIDTH` | 32/64/128/256/512 | AXI master interface data width |
| `BASE_CLK_FREQ` | 200 | Frequency of `emmc_base_clk`, unit in MHz |
| `BUFFER_BLOCK_SIZE` | 512 | Largest block length, unit in byte, default is 512 bytes |
| `BUFFER_BLOCK_COUNT` | 4 | Block count that can be stored in FIFO. FIFO buffer capacity = `BUFFER_BLOCK_COUNT` * `BUFFER_BLOCK_SIZE` |
| `STOP_CLK_POSITION` | 4 | Stop output clock after N cycles during block gap, used to implement read pause. N = `STOP_CLK_POSITION`. Default is 4. |

### 5.2 PLL Configuration

When HS200 or HS400 is selected, the PLL configuration must meet the following requirements:

*   All three clocks `emmc_base_clk`, `emmc_base_clk_cal` and `emmc_base_clk_shift` must have the same frequency, set to 200MHz, and must be in the same PLL.
*   Phase shift of `emmc_base_clk` should be set to 0°. `emmc_base_clk` and `emmc_base_clk_shift` should not be set to asynchronous clock group.
*   Set phase shift of `emmc_base_clk_cal` and `emmc_base_clk_shift` to 0° and Dynamic. `emmc_base_clk_cal` must be at Clock 2, and `emmc_base_clk_shift` must be at Clock 3.

![pll-setting.png](../images/emmc/pll_setting.png)
> **Figure 2:** PLL configuration

Based on Base Register 1 (0x00C) bit[8:6], for every increment of `pll_SHIFT` value, `emmc_base_clk_cal` and `emmc_base_clk_shift` will be delayed by 45°. Based on the Titanium Interfaces User Guide, for every increment in `pll_SHIFT`, `emmc_base_clk_cal` and `emmc_base_clk_shift` will be delayed by 0.5 F<sub>PLL</sub> clock cycle. Therefore:

*   (45° / 360°) * T<sub>emmc_base_clk_cal</sub> = 0.5 * T<sub>FPLL</sub>
*   T<sub>FPLL</sub> = T<sub>emmc_base_clk_cal</sub> / 4
*   F<sub>PLL</sub> = 4 * F<sub>emmc_base_clk_cal</sub> = 4 * 200MHz = 800MHz

In PLL Auto Mode, if F<sub>PLL</sub> is not equal to 800MHz, users can utilize Manual Mode to get F<sub>PLL</sub> of 800MHz. Below are some PLL configurations for different input reference frequencies:

![pll-25m.png](../images/emmc/pll_25m.png)
> **Figure 3:** Sample PLL configuration for 25MHz input

![pll-50m.png](../images/emmc/pll_50m.png)
> **Figure 4:** Sample PLL configuration for 50MHz input

![pll-100m.png](../images/emmc/pll_100m.png)
> **Figure 5:** Sample PLL configuration for 100MHz input

![pll-200m.png](../images/emmc/pll_200m.png)
> **Figure 6:** Sample PLL configuration for 200MHz input

## 6. High/Low Temperature Operation

### 6.1 Temperature Drift

As can be seen in the following figure, the output data of eMMC will suffer from temperature drift. In other words, sampling points that were trained at the initial temperature might suffer from data sampling errors when the temperature rises or drops.

Users can mitigate the data sampling error due to temperature drift by reducing eMMC clock frequency. The frequency can be set in the driver, no PLL modification is needed.

![temp-drift.png](../images/emmc/temp_drift.png)
> **Figure 7:** Sampling point deviation due to temperature drift

### 6.2 Tested Working Conditions

This IP has been verified to work stably in the temperature ranges below.

**Table 3: Working conditions**

| Mode | eMMC device input clock | Temperature range |
| :--- | :--- | :--- |
| HS200 | 200MHz | -20℃ ~ 80℃ |
| HS400 | 200MHz | -10℃ ~ 60℃ |

## 7. Resource Utilization

When `ADMA_DATA_WIDTH` = 128 and `BUFFER_BLOCK_COUNT` = 4, resource utilization is as follows:

**Table 4: Resource utilization**

| FPGA | Logic Elements (Logic, Adders, FlipFlops, etc.) | Memory Blocks | DSP Blocks | Efinity® Version |
| :--- | :--- | :--- | :--- | :--- |
| Ti375C529 C4 | 7237 / 362880 (1.99%) | 14 | 0 | 2025.2 |

## 8. Interface Description

### 8.1 System Signal

| Name | Direction | Description |
| :--- | :--- | :--- |
| `emmc_rst` | Input | Global reset (active high). |
| `emmc_base_clk` | Input | Base clock. |
| `emmc_base_clk_cal` | Input | Same frequency as `emmc_base_clk`, phase can be dynamically adjusted. |
| `emmc_base_clk_shift` | Input | Same frequency as `emmc_base_clk`, phase can be dynamically adjusted. |
| `s_axi_aclk` | Input | AXI4-Lite clock. |
| `m_axi_clk` | Input | AXI4 clock. |
| `emmc_int` | Output | Interrupt signal |

### 8.2 Phase Adjustment Signal

| Name | Direction | Description |
| :--- | :--- | :--- |
| `pll_SHIFT[2:0]` | Output | Output to the PLL hard block to dynamically shift the phase of `emmc_base_clk_cal` and `emmc_base_clk_shift` |
| `pll_SHIFT_SEL[4:0]` | Output | |
| `pll_SHIFT_ENA` | Output | |

### 8.3 AXI4-Lite Interface Signal

| Name | Direction | Description |
| :--- | :--- | :--- |
| `s_axi_awaddr[9:0]` | Input | AXI4-Lite write address bus. |
| `s_axi_awvalid` | Input | AXI4-Lite write address valid strobe. |
| `s_axi_awready` | Output | AXI4-Lite write address ready signal. |
| `s_axi_wdata[31:0]` | Input | AXI4-Lite write data. |
| `s_axi_wstrb[3:0]` | Input | AXI4-Lite write strobe. |
| `s_axi_wvalid` | Input | AXI4-Lite write data valid strobe. |
| `s_axi_wready` | Output | AXI4-Lite write ready signal. |
| `s_axi_bresp[1:0]` | Output | AXI4-Lite write response. |
| `s_axi_bvalid` | Output | AXI4-Lite write response valid strobe. |
| `s_axi_bready` | Input | AXI4-Lite write response ready signal. |
| `s_axi_araddr[9:0]` | Input | AXI4-Lite read address bus. |
| `s_axi_arvalid` | Input | AXI4-Lite read address valid strobe. |
| `s_axi_arready` | Output | AXI4-Lite read address ready signal. |
| `s_axi_rresp[1:0]` | Output | AXI4-Lite read response. |
| `s_axi_rdata[31:0]` | Output | AXI4-Lite read data. |
| `s_axi_rvalid` | Output | AXI4-Lite read data valid strobe. |
| `s_axi_rready` | Input | AXI4-Lite read data ready signal. |

### 8.4 AXI4 Interface Signal

| Name | Direction | Description |
| :--- | :--- | :--- |
| `m_axi_awvalid` | Output | AXI4 write address valid. |
| `m_axi_awaddr[31:0]` | Output | AXI4 write address. |
| `m_axi_awlen[7:0]` | Output | AXI4 write burst length. |
| `m_axi_awsize[2:0]` | Output | AXI4 write burst size. |
| `m_axi_awburst[1:0]` | Output | AXI4 write burst type. |
| `m_axi_awprot[2:0]` | Output | AXI4 write protection type. |
| `m_axi_awlock[1:0]` | Output | AXI4 write lock type. |
| `m_axi_awcache[3:0]` | Output | AXI4 write cache type. |
| `m_axi_awready` | Input | AXI4 write address ready. |
| `m_axi_wdata[ADMA_DATA_WIDTH-1:0]` | Output | AXI4 write data. |
| `m_axi_wstrb[ADMA_DATA_WIDTH/8-1:0]` | Output | AXI4 write strobes. |
| `m_axi_wlast` | Output | AXI4 write last. |
| `m_axi_wvalid` | Output | AXI4 write valid. |
| `m_axi_wready` | Input | AXI4 write ready. |
| `m_axi_bresp[1:0]` | Input | AXI4 write response. |
| `m_axi_bvalid` | Input | AXI4 write response valid. |
| `m_axi_bready` | Output | AXI4 write response ready. |
| `m_axi_arvalid` | Output | AXI4 read address valid. |
| `m_axi_araddr[31:0]` | Output | AXI4 read address |
| `m_axi_arlen[7:0]` | Output | AXI4 read burst length. |
| `m_axi_arsize[2:0]` | Output | AXI4 read burst size. |
| `m_axi_arburst[1:0]` | Output | AXI4 read burst type. |
| `m_axi_arprot[2:0]` | Output | AXI4 read protection type. |
| `m_axi_arlock[1:0]` | Output | AXI4 read lock type. |
| `m_axi_arcache[3:0]` | Output | AXI4 read cache type. |
| `m_axi_arready` | Input | AXI4 read address ready. |
| `m_axi_rvalid` | Input | AXI4 read valid. |
| `m_axi_rdata[ADMA_DATA_WIDTH-1:0]` | Input | AXI4 read data. |
| `m_axi_rlast` | Input | AXI4 read last. |
| `m_axi_rresp[1:0]` | Input | AXI4 read response. |
| `m_axi_rready` | Output | AXI4 read ready. |

### 8.5 eMMC Interface Signal

| Name | Direction | Description |
| :--- | :--- | :--- |
| `emmc_clk_HI` | Output | eMMC clock signal |
| `emmc_clk_LO` | Output | |
| `emmc_cmd_IN_HI` | Input | Command input signal |
| `emmc_cmd_IN_LO` | Input | |
| `emmc_cmd_OUT_HI` | Output | Command output signal |
| `emmc_cmd_OUT_LO` | Output | |
| `emmc_cmd_OE` | Output | Command output enable signal |
| `emmc_dat_IN_HI[7:0]` | Input | Data input signal |
| `emmc_dat_IN_LO[7:0]` | Input | |
| `emmc_dat_OUT_HI[7:0]` | Output | Data output signal |
| `emmc_dat_OUT_LO[7:0]` | Output | |
| `emmc_dat_OE` | Output | Data output enable signal |

## 9. Register Space

**Table 5: Register access types**

| Attribute | Definition |
| :--- | :--- |
| R/W | Readable and writable |
| RC | Read and self-clear |
| RO | Read-only |

### 9.1 Version (0x000)

| Bit | Default Value | Description | Attribute |
| :--- | :--- | :--- | :--- |
| 31-0 | - | Version register | RO |

### 9.2 Base Register 0 (0x004)

| Bit | Default Value | Description | Attribute |
| :--- | :--- | :--- | :--- |
| 31-17 | - | Reserved | - |
| 16 | 1'b0 | Clock Enable. | R/W |
| 15-0 | 16'h0 | clk_div, clock divider factor.<br>Valid value is 1 or an even number. | R/W |

### 9.3 Base Status Register 0 (0x008)

| Bit | Default Value | Description | Attribute |
| :--- | :--- | :--- | :--- |
| 31-2 | - | Reserved | - |
| 1 | 1'b0 | Data line is busy:<br>0: Not Busy<br>1: Busy | RO |
| 0 | 1'b0 | Command line is busy:<br>0: Not Busy<br>1: Busy | RO |

### 9.4 Base Register 1 (0x00C)

| Bit | Default Value | Description | Attribute |
| :--- | :--- | :--- | :--- |
| 31-16 | 16'h0 | Sampling counter, sample_cnt < clk_div | R/W |
| 15-9 | - | Reserved | - |
| 8-6 | 3'h0 | pll_SHIFT, PLL clock phase shift value:<br>000b: 0°<br>001b: 45°<br>010b: 90°<br>011b: 135°<br>100b: 180°<br>101b: 225°<br>110b: 270°<br>111b: 315° | R/W |
| 5-1 | 5'h0 | pll_SHIFT_SEL, used to select the PLL output port that needs dynamic phase shifting:<br>00001b: Clock0 port<br>00010b: Clock1 port<br>00100b: Clock2 port<br>01000b: Clock3 port<br>10000b: Clock4 port | R/W |
| 0 | 1'b0 | Phase shift pulse sent by the CPU | R/W |

### 9.5 Argument 2 Register (0x100)

| Bit | Default Value | Description | Attribute |
| :--- | :--- | :--- | :--- |
| 31-0 | 32'h0 | Argument 2.<br>Contains the physical system memory address used for ADMA transfers. | R/W |

### 9.6 Block Size Register (0x104)

| Bit | Default Value | Description | Attribute |
| :--- | :--- | :--- | :--- |
| 31-16 | 16'h0 | Blocks Count for Current Transfer.<br>Enabled when Block Count Enable in the Transfer Mode register is set to 1 and is valid only for multiple block transfers. The host driver sets this register to a value between 1 and the maximum block count.<br>0000h: Stop Count<br>0001h: 1 block<br>0002h: 2 blocks<br>...<br>FFFFh: 65535 blocks | R/W |
| 15 | - | Reserved. | R/W |
| 14-12 | 3'h0 | Host ADMA Buffer Boundary.<br>Specifies the size of contiguous buffer in the system memory. The ADMA transfer waits at every boundary specified by these fields and the host controller generates the ADMA Interrupt to request the host driver to update the ADMA System Address register.<br>000b: 4 KB<br>001b: 8 KB<br>010b: 16 KB<br>011b: 32 KB<br>100b: 64 KB<br>101b: 128 KB<br>110b: 256 KB<br>111b: 512 KB | R/W |
| 11-0 | 12'h0 | Transfer Block Size.<br>Specifies the block size of data transfers for CMD17, CMD18, CMD24, CMD25, and CMD53. Values ranging from 1 up to the maximum buffer size can be set. For memory, set to 512 bytes.<br>0000h: No data transfer<br>0001h: 1 byte<br>0002h: 2 bytes<br>...<br>0200h: 512 bytes<br>...<br>0800h: 2048 bytes | R/W |

### 9.7 Argument 1 Register (0x108)

| Bit | Default Value | Description | Attribute |
| :--- | :--- | :--- | :--- |
| 31-0 | 32'h0 | Command Argument 1. The eMMC command argument is specified as bit 39-8 of Command-Format in the Physical Layer Specification. | R/W |

### 9.8 Transfer Mode Register (0x10C)

| Bit | Default Value | Description | Attribute |
| :--- | :--- | :--- | :--- |
| 31-30 | - | Reserved. | - |
| 29-24 | 6'h0 | Command Index.<br>Set to the command number (CMD0-63, ACMD0-63). | R/W |
| 23-22 | 2'h0 | Reserved. | - |
| 21 | 1'b0 | Data Present Select.<br>Set to 1 to indicate that data is present | R/W |
| 20 | 1'b0 | Command Index Check Enable.<br>Set to 1 for the host controller to check the index field in the response to see if it has the same value as the command index. | R/W |
| 19 | 1'b0 | Command CRC Check Enable.<br>Set to 1 for the host controller to check the CRC field in the response. If an error is detected, it is reported as a Command CRC Error. | R/W |
| 18 | - | Reserved | - |
| 17-16 | 2'h0 | Response Type Select.<br>00b: No Response<br>01b: Response Length 136<br>10b: Response Length 48<br>11b: Response Length 48 check Busy after response | R/W |
| 15-6 | - | Reserved | - |
| 5 | 1'b0 | Multi/Single Block Select.<br>Set when issuing multiple-block transfer commands using DATA line.<br>0: Single Block<br>1: Multiple Block | R/W |
| 4 | 1'b0 | Data Transfer Direction Select.<br>Defines the direction of DAT line data transfers.<br>0: Write (Host to Card)<br>1: Read (Card to Host) | R/W |
| 3-2 | 2'h0 | Auto CMD Enable.<br>Sets the auto command functions.<br>00b: Auto Command Disabled<br>01b: Auto CMD12 Enable<br>10b: Auto CMD23 Enable<br>11b: Reserved | R/W |
| 1 | 1'b0 | Block Count Enable<br>Enables the Block Count register, which is only relevant for multiple block transfers. If ADMA data transfer is more than 65535 blocks, this bit shall be set to 0. In this case, data transfer length is designated by the descriptor table.<br>0: Disable<br>1: Enable | R/W |
| 0 | 1'b0 | DMA Enable.<br>Enables the DMA functionality.<br>0: No data transfer or Non DMA data transfer<br>1: DMA Data transfer | R/W |

### 9.9 Command Response Register0 (0x110)

| Bit | Default Value | Description | Attribute |
| :--- | :--- | :--- | :--- |
| 31-0 | 32'h0 | Command Response [31:0] | RC |

### 9.10 Command Response Register1 (0x114)

| Bit | Default Value | Description | Attribute |
| :--- | :--- | :--- | :--- |
| 31-0 | 32'h0 | Command Response [63:32] | RC |

### 9.11 Command Response Register2 (0x118)

| Bit | Default Value | Description | Attribute |
| :--- | :--- | :--- | :--- |
| 31-0 | 32'h0 | Command Response [95:64] | RC |

### 9.12 Command Response Register3 (0x11C)

| Bit | Default Value | Description | Attribute |
| :--- | :--- | :--- | :--- |
| 31-24 | - | Reserved | - |
| 23-0 | 24'h0 | Command Response [119:96] | RC |

### 9.13 Buffer Data Port Register (0x120)

| Bit | Default Value | Description | Attribute |
| :--- | :--- | :--- | :--- |
| 31-0 | 32'h0 | 32-bit data port register to access internal buffer. | R/W |

### 9.14 Present State Register (0x124)

| Bit | Default Value | Description | Attribute |
| :--- | :--- | :--- | :--- |
| 31-12 | - | Reserved. | - |
| 11 | 1'b0 | Buffer Read Enable.<br>Used for non-DMA read transfers.<br>0: Read Disable<br>1: Read Enable | RO |
| 10 | 1'b0 | Buffer Write Enable.<br>Used for non-DMA write transfers.<br>0: Write Disable<br>1: Write Enable | RO |
| 9 | 1'b0 | Read Transfer Active.<br>Indicates a read transfer is active.<br>0: No valid data<br>1: Transferring data | RO |
| 8 | 1'b0 | Write Transfer Active.<br>Indicates a write transfer is active.<br>0: No valid data<br>1: Transferring data | RO |
| 7-4 | - | Reserved | - |
| 3 | 1'b0 | Re-Tuning Request. Not supported. | R/W |
| 2 | 1'b0 | DAT Line Active.<br>Indicates whether one of the DAT line on eMMC bus is in use.<br>0: DAT Line Inactive<br>1: DAT Line Active | RO |
| 1 | 1'b0 | Command Inhibit (DAT).<br>Indicates if either the DAT Line Active or the Read Transfer Active is set to 1.<br>0: Can issue command which uses the DAT line<br>1: Cannot issue command which uses the DAT line | RO |
| 0 | 1'b0 | Command Inhibit (CMD).<br>Indicates that the CMD line is not in use and the host controller can issue an eMMC Command using the CMD line.<br>0: Can issue command using only CMD line<br>1: Cannot issue command | RO |

### 9.15 Host Control Register (0x128)

| Bit | Default Value | Description | Attribute |
| :--- | :--- | :--- | :--- |
| 31-20 | - | Reserved | - |
| 19 | 1'b0 | Interrupt At Block Gap.<br>Enables interrupt detection at the block gap for a multiple block transfer.<br>0: Disable<br>1: Enable | R/W |
| 18 | 1'b0 | Read Wait Control.<br>If the card supports read wait, set this bit to enable use of the read wait protocol to stop read data using the DAT[2] line.<br>0: Disable Read Wait Control<br>1: Enable Read Wait Control | R/W |
| 17 | 1'b0 | Continue Request.<br>Restart a transaction, which was stopped by the Stop At Block Gap Request.<br>0: Not affect<br>1: Restart | R/W |
| 16 | 1'b0 | Stop At Block Gap Request.<br>Stop executing read and write transaction at the next block gap for non-DMA and ADMA transfers<br>0: Transfer<br>1: Stop | R/W |
| 15-4 | - | Reserved | - |
| 3 | 1'b0 | Data Sampling Mode.<br>0: SDR mode<br>1: DDR mode | R/W |
| 2-1 | 2'h0 | Data Transfer Width.<br>Selects the data width of the host controller.<br>00b: 1 line<br>01b: 4 lines<br>10b: 8 lines | R/W |
| 0 | 1'b0 | LED Control.<br>Not used currently.<br>Reminds the user not to remove the card while the eMMC is being accessed.<br>0: LED off<br>1: LED on | R/W |

### 9.16 Interrupt Status Register (0x130)

| Bit | Default Value | Description | Attribute |
| :--- | :--- | :--- | :--- |
| 31-22 | - | Reserved. | - |
| 21 | 1'b0 | Data CRC Error.<br>0: No interrupt<br>1: Interrupt Detected | RO |
| 20 | - | Reserved. | - |
| 19 | 1'b0 | Command Index Error.<br>0: No interrupt<br>1: Interrupt Detected | RO |
| 18 | 1'b0 | Command End Bit Error.<br>0: No interrupt<br>1: Interrupt Detected | RO |
| 17 | 1'b0 | Command CRC Error.<br>0: No interrupt<br>1: Interrupt Detected | RO |
| 16 | 1'b0 | Command Timeout Error.<br>0: No interrupt<br>1: Interrupt Detected | RO |
| 15-6 | - | Reserved. | - |
| 5 | 1'b0 | Buffer Read Ready.<br>0: No interrupt<br>1: Interrupt Detected | RO |
| 4 | 1'b0 | Buffer Write Ready.<br>0: No interrupt<br>1: Interrupt Detected | RO |
| 3 | 1'b0 | Reserved. | - |
| 2 | 1'b0 | Block Gap Event.<br>0: No interrupt<br>1: Interrupt Detected | RO |
| 1 | 1'b0 | Transfer Complete.<br>0: No interrupt<br>1: Interrupt Detected | RO |
| 0 | 1'b0 | Command Complete.<br>0: No interrupt<br>1: Interrupt Detected | RO |

### 9.17 Interrupt Status Enable Register (0x134)

| Bit | Default Value | Description | Attribute |
| :--- | :--- | :--- | :--- |
| 31-22 | - | Reserved. | - |
| 21 | 1'b0 | Data CRC Error.<br>0: No interrupt<br>1: Enable interrupt | R/W |
| 20 | - | Reserved. | - |
| 19 | 1'b0 | Command Index Error.<br>0: No interrupt<br>1: Enable interrupt | R/W |
| 18 | 1'b0 | Command End Bit Error.<br>0: No interrupt<br>1: Enable interrupt | R/W |
| 17 | 1'b0 | Command CRC Error.<br>0: No interrupt<br>1: Enable interrupt | R/W |
| 16 | 1'b0 | Command Timeout Error.<br>0: No interrupt<br>1: Enable interrupt | R/W |
| 15-6 | - | Reserved. | - |
| 5 | 1'b0 | Buffer Read Ready.<br>0: No interrupt<br>1: Enable interrupt | R/W |
| 4 | 1'b0 | Buffer Write Ready.<br>0: No interrupt<br>1: Enable interrupt | R/W |
| 3 | - | Reserved. | - |
| 2 | 1'b0 | Block Gap Event.<br>0: No interrupt<br>1: Enable interrupt | R/W |
| 1 | 1'b0 | Transfer Complete.<br>0: No interrupt<br>1: Enable interrupt | R/W |
| 0 | 1'b0 | Command Complete.<br>0: No interrupt<br>1: Enable interrupt | R/W |

### 9.18 Interrupt Signal Enable Register (0x138)

| Bit | Default Value | Description | Attribute |
| :--- | :--- | :--- | :--- |
| 31-22 | - | Reserved. | - |
| 21 | 1'b0 | Data CRC Error.<br>0: Masked<br>1: Enabled | R/W |
| 20 | - | Reserved. | - |
| 19 | 1'b0 | Command Index Error.<br>0: Masked<br>1: Enabled | R/W |
| 18 | 1'b0 | Command End Bit Error.<br>0: Masked<br>1: Enabled | R/W |
| 17 | 1'b0 | Command CRC Error.<br>0: Masked<br>1: Enabled | R/W |
| 16 | 1'b0 | Command Timeout Error.<br>0: Masked<br>1: Enabled | R/W |
| 15-6 | - | Reserved. | - |
| 5 | 1'b0 | Buffer Read Ready.<br>0: Masked<br>1: Enabled | R/W |
| 4 | 1'b0 | Buffer Write Ready.<br>0: Masked<br>1: Enabled | R/W |
| 3 | - | Reserved. | - |
| 2 | 1'b0 | Block Gap Event.<br>0: Masked<br>1: Enabled | R/W |
| 1 | 1'b0 | Transfer Complete.<br>0: Masked<br>1: Enabled | R/W |
| 0 | 1'b0 | Command Complete.<br>0: Masked<br>1: Enabled | R/W |

### 9.19 Host Capabilities Register (0x140)

| Bit | Default Value | Description | Attribute |
| :--- | :--- | :--- | :--- |
| 31-16 | 16'd512 | Max block length, unit is byte<br>This field indicates the maximum block length that the driver can read or write to the buffer in the host controller | RO |
| 15-10 | - | Reserved. | - |
| 9-0 | - | Frequency of the IP clock `emmc_base_clk`, unit is MHz | RO |

### 9.20 Host Adjustment Register (0x144)

| Bit | Default Value | Description | Attribute |
| :--- | :--- | :--- | :--- |
| 31-11 | - | Reserved | - |
| 10 | 1'b0 | DDR sampling result for `emmc_base_clk_cal` data line<br>1: Some mismatches in data line<br>0: All data lines match | RO |
| 9 | 1'b0 | DDR sampling result for `emmc_base_clk_cal` data line<br>1: All data lines do not match<br>0: Some matches in data lines | RO |
| 8 | 1'b0 | DDR sampling result for `emmc_base_clk_cal` cmd line<br>1: Mismatch<br>0: Match | RO |
| 7-0 | - | Reserved | - |

### 9.21 ADMA System Address Register (0x158)

| Bit | Default Value | Description | Attribute |
| :--- | :--- | :--- | :--- |
| 31-0 | 32'h0 | ADMA System Address (Lower Word). Holds byte address of executing command of the descriptor table. | R/W |

### 9.22 ADMA System Address Register (0x15C)

| Bit | Default Value | Description | Attribute |
| :--- | :--- | :--- | :--- |
| 31-0 | 32'h0 | ADMA System Address (Upper Word). Holds byte address of executing command of the descriptor table | R/W |

## 10. Example Design Description

### 10.1 Block Diagram

![design-diagram.png](../images/emmc/design_diagram.png)
> **Figure 8:** Example Design Block Diagram

As shown above, the system reg / eMMC Host Controller is connected to the hardened RISC-V core via an Interconnect IP. The system reg generates a reset signal to soft reset the eMMC Host Controller and eMMC Device.
RISC-V can initialize the eMMC Device and select the transmission mode through the eMMC Host Controller; initiate the read/write/erase operation of the eMMC Device by sending cmd commands, and then realize the data transfer between DDR and eMMC Host Controller through ADMA.

### 10.2 System Register

#### 10.2.1 Date Register (0x000)

| Bit | Default Value | Description | Attribute |
| :--- | :--- | :--- | :--- |
| 31-0 | - | Date register | RO |

#### 10.2.2 Test Register (0x004)

| Bit | Default Value | Description | Attribute |
| :--- | :--- | :--- | :--- |
| 31-0 | 32'h0 | Read and Write Test Registers | R/W |

#### 10.2.3 Reset Register (0x008)

| Bit | Default Value | Description | Attribute |
| :--- | :--- | :--- | :--- |
| 31-2 | - | Reserved. | - |
| 1 | 1'b0 | eMMC device reset signal, active high | R/W |
| 0 | 1'b0 | eMMC IP reset signal, active high | R/W |

## 11. Driver Description

Bare metal eMMC demo can be found at `embedded_sw/efx_solution/software/standalone/emmc/emmcDemo`.

### 11.1 User Parameter

The user parameters in the `device_config.h` and `userDef.h` file are shown below:

**Table 6: Driver User Parameter Description**

| Name | Default Value | Description |
| :--- | :--- | :--- |
| `EMMC_ADDR` | `SYSTEM_AXI_A_BMB + 0x01300000` | Starting address of the `emmc_host_controller` module registers, where the offset address `0x01300000` is configured in the IP (`gAXIS_1to6_switch`) of the example design project |
| `SYS_REG_ADDR` | `SYSTEM_AXI_A_BMB + 0x01400000` | Starting address of the system register module, where the offset address `0x01400000` is configured in the IP (`gAXIS_1to6_switch`) of the example design project |
| `EMMC_INTERRUPT` | `SYSTEM_PLIC_USER_INTERRUPT_U_INTERRUPT` | `userInterruptU` is chosen as the interrupt for `emmc_host_controller` in the design project `top_soc.v` |
| `EMMC_VCCQ` | 1.8 | VCCQ of on board eMMC circuitry, unit in V |
| `EMMC_LARGE_DENSITY` | 1 | 0: eMMC device capacity <= 2GB<br>1: eMMC device capacity > 2GB |
| `EMMC_RCA` | 2 | The relative address assigned to the emmc device, the bit width is 16bit, the value of `EMMC_RCA` should be greater than 1, the value range is 2~65535 |
| `EMMC_BLOCK_LEN` | 512 | Block length in bytes, recommended block length is set to 512 bytes |
| `EMMC_SAFE_TUNING` | 0 | If enabled, when tuning fails, `emmc_clk` will be automatically reduced, then re-tuning is performed |
| `EMMC_BASE_CLK_CAL_PORT` | 2 | Port number of `emmc_base_clk_cal` in PLL configuration. Fixed to 2. |
| `EMMC_BASE_CLK_SHIFT_PORT` | 3 | Port number of `emmc_base_clk_shift` in PLL configuration. Fixed to 3. |
| `EMMC_SAMPLE_LAST_HALF` | 1 | 0: Sampling in first half of data window<br>1: Sampling in second half of data window |

### 11.2 Functions

#### 11.2.1 efx_emmc_init
Initialize the eMMC device, after the initialization is completed, the eMMC device enters Transfer State. During the initialization process, the device will go through Idle State / Ready State / Identification State / Stand-by State / Transfer State.

#### 11.2.2 efx_emmc_switch_bus_speed_mode

**Table 7: `efx_emmc_switch_bus_speed_mode` Parameter Description**

| Name | Description |
| :--- | :--- |
| `mode` | Speed mode<br>Valid options: hs200/hs400 |
| `bus_width` | Data bus width<br>Valid options: x4/x8 |
| `clk_mhz` | Output clock to eMMC device in unit MHz<br>Valid options: 200MHz or an even division of 200MHz. |
| `driver_type` | Drive strength type, default is 0x0, refer to Figure 9. |

![io-strength.png](../images/emmc/io_strength.png)
> **Figure 9:** Drive Strength Types

#### 11.2.3 efx_emmc_block_write

**Table 8: `efx_emmc_block_write` Parameter Description**

| Name | Description |
| :--- | :--- |
| `block_cnt` | Number of write blocks |
| `addr` | Write operation start address, when emmc device capacity > 2GB, the data address is 32bit sector (512 bytes) address; when emmc device capacity <= 2GB, the data address is 32bit byte address |
| `dma_en` | 1: Enable ADMA data transfer<br>0: Enable non-ADMA data transfer |

#### 11.2.4 efx_emmc_block_read

**Table 9: `efx_emmc_block_read` Parameter Description**

| Name | Description |
| :--- | :--- |
| `block_cnt` | Number of read blocks |
| `addr` | Read operation start address, when emmc device capacity > 2GB, the data address is 32bit sector (512 bytes) address; when emmc device capacity <= 2GB, the data address is 32bit byte address |
| `dma_en` | 1: Enable ADMA data transfer<br>0: Enable non-ADMA data transfer |

#### 11.2.5 erase_unit_size_calculate
Calculates the size of the erase unit in bytes corresponding to different erase types (erase or trim). The erase operation (erase or trim) has the erase unit as its smallest unit.

#### 11.2.6 efx_emmc_erase
`efx_emmc_erase` is generally used for large area erase, such as erasing the entire card or certain partitions.

**Table 10: `efx_emmc_erase` Parameter Description**

| Name | Description |
| :--- | :--- |
| `start_addr` | 1) Erase operation start address, when emmc device capacity > 2GB, the data address is 32bit sector (512 bytes) address; when emmc device capacity <= 2GB, the data address is 32bit byte address<br>2) For erase operations, the minimum erase unit size is `erase_unit_size` = `erase_unit_size_calculate` (erase) bytes. The starting address must be on the boundary of the minimum erase unit. |
| `erase_unit_num` | Number of erase units, actual bytes erased = `erase_unit_num` * `erase_unit_size_calculate` (erase) |

#### 11.2.7 efx_emmc_trim
`efx_emmc_trim` is generally used for small area erases, such as erasing only a write block.

**Table 11: `efx_emmc_trim` Parameter Description**

| Name | Description |
| :--- | :--- |
| `start_addr` | 1) Trim operation start address, when emmc device capacity > 2GB, the data address is 32bit sector (512 bytes) address; when emmc device capacity <= 2GB, the data address is 32bit byte address<br>2) For trim operations, the minimum erase unit size is `erase_unit_size` = `erase_unit_size_calculate` (trim) bytes. The starting address must be on the boundary of the minimum erase unit. |
| `erase_unit_num` | Number of trim units, actual bytes erased = `erase_unit_num` * `erase_unit_size_calculate` (trim) |

#### 11.2.8 uda_density_calculate
Calculates the size of the user data area in bytes.

#### 11.2.9 efx_emmc_boot_write

**Table 12: `efx_emmc_boot_write` Parameter Description**

| Name | Description |
| :--- | :--- |
| `bus_width` | Data bus width<br>Valid options: x1/x4/x8 |
| `par_num` | Boot partition<br>Valid options: 1/2 |
| `block_cnt` | Number of write blocks |
| `addr` | Write starting address, when eMMC capacity > 2GB, data address is the 32bit sector (512 bytes) address; when capacity <= 2GB, data address is 32bit byte address |
| `dma_en` | 1: Enable ADMA data transfer<br>0: Enable non-ADMA data transfer |

#### 11.2.10 efx_emmc_boot_read_all
Read all data from the selected boot partition.

**Table 13: `efx_emmc_boot_read_all` Parameter Description**

| Name | Description |
| :--- | :--- |
| `bus_width` | Data bus width, x4/x8 is suggested |
| `par_num` | Boot partition<br>Valid options: 1/2 |
| `dma_en` | 1: Enable ADMA data transfer<br>0: Enable non-ADMA data transfer |

#### 11.2.11 efx_emmc_boot_read_single
Read data in the selected boot partition; the range to read is configurable.

**Table 14: `efx_emmc_boot_read_single` Parameter Description**

| Name | Description |
| :--- | :--- |
| `bus_width` | Data bus width, x4/x8 is suggested |
| `par_num` | Boot partition number<br>Valid options: 1/2 |
| `block_cnt` | Number of read blocks |
| `addr` | Read starting address, when eMMC capacity > 2GB, data address is the 32bit sector (512 bytes) address; when capacity <= 2GB, data address is 32bit byte address |
| `dma_en` | 1: Enable ADMA data transfer<br>0: Enable non-ADMA data transfer |

#### 11.2.12 efx_emmc_boot_erase

**Table 15: `efx_emmc_boot_erase` Parameter Description**

| Name | Description |
| :--- | :--- |
| `par_num` | Boot partition number<br>Valid options: 1/2 |
| `erase_mode` | Erase mode<br>Valid options: erase/trim |
| `start_addr` | 1) Erase starting address, when eMMC capacity > 2GB, data address is the 32bit sector (512 bytes) address; when capacity <= 2GB, data address is 32bit byte address<br>2) The minimum erase unit size is `erase_unit_size` = `erase_unit_size_calculate` (`erase_mode`) bytes. The starting address must be on the boundary of the minimum erase unit. |
| `erase_unit_num` | Number of erase units, actual bytes erased = `erase_unit_num` * `erase_unit_size_calculate` (`erase_mode`) |

### 11.3 Test Function

#### 11.3.1 test_entire_emmc
The `test_entire_emmc` function implements a full-space write/read/erase test of the user data area and also calculates the write/read/erase rate.

**Table 16: `test_entire_emmc` Parameter Description**

| Name | Description |
| :--- | :--- |
| `dma` | 1: Enable DMA mode<br>0: Enable non-DMA mode |
| `transfer_mode` | Speed mode<br>Valid options: hs200/hs400 |
| `bus_width` | Data bus width<br>Valid options: x4/x8 |
| `clk_freq` | Output clock of eMMC device in MHz<br>Valid option: 200MHz or an even division of 200MHz. |
| `len_mode` | 0: Read/write fixed blocks<br>1: Read/write random blocks |
| `fixed_bk_num` | When `len_mode` is 0, the number of fixed blocks ranges from 1 to 65535. |
| `erase_mode` | Erase mode<br>Valid options: erase/trim |
| `whole_space_test_num` | Number of full-space tests of user data areas |
| `test_size_mb` | Single test area size in MByte |

#### 11.3.2 dma_wr_rd_erase
The `dma_wr_rd_erase` function implements a write/read/erase test on a single area, transferring data using dma mode while calculating the write/read/erase rate.

**Table 17: `dma_wr_rd_erase` Parameter Description**

| Name | Description |
| :--- | :--- |
| `len_mode` | 0: Read/write fixed blocks<br>1: Read/write random blocks |
| `fixed_bk_num` | When `len_mode` is 0, the number of fixed blocks ranges from 1 to 65535. |
| `start_addr` | Starting address, when emmc device capacity > 2GB, data address is 32bit sector (512 bytes) address; when emmc device capacity <= 2GB, data address is 32bit byte address |
| `erase_mode` | Erase mode, erase or trim |
| `erase_en` | Erase Enable |
| `test_size_mb` | Test area size in MByte |

#### 11.3.3 non_dma_wr_rd
The `non_dma_wr_rd` function implements a write/read test for a single region, transferring data using non-dma mode while calculating the write/read rate.

**Table 18: `non_dma_wr_rd` Parameter Description**

| Name | Description |
| :--- | :--- |
| `len_mode` | 0: Read/write fixed blocks<br>1: Read/write random blocks |
| `fixed_bk_num` | When `len_mode` is 0, the number of fixed blocks ranges from 1 to 65535. |
| `start_addr` | Starting address, when emmc device capacity > 2GB, data address is 32bit sector (512 bytes) address; when emmc device capacity <= 2GB, data address is 32bit byte address |
| `test_size_mb` | Test area size in MByte |

## 12. Usage
1. In Efinity RISC-V IDE, open the main.c from emmcDemo
2. Clean and run the project by right click emmcDemo_ti.launch. 
3. Go to the serial terminal. User should see the following messages display:

    ![run-result](../images/emmc/run_result.png)
