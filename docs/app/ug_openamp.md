# Bare-Metal OpenAMP for Efinix Sapphire RISC-V SoC

This guide show on how to run the OpenAMP application on baremetal.

Linux runs as the master on the application cores, while a dedicated RISC-V hart
runs a bare-metal remote firmware. The two communicate over shared memory.
Linux load and start the remote processor via 'remoteproc'.

- [Overview](#overview)
- [Key Features](#key-features)
- [Hardware / SoC Requirements](#hardware--soc-requirements)
- [Directory Structure](#directory-structure)
- [Software Requirements](#software-requirements)
- [Shared-Memory Address Map](#shared-memory-address-map)
- [Building the Firmware](#building-the-firmware)
- [Deploying to Linux](#deploying-to-linux)
- [Running the Echo Demo](#running-the-echo-demo)

## Overview

In this AMP topology one hart is removed from the Linux SMP set and runs a
standalone OpenAMP firmware image. The Linux acting as the OpenAMP master which loads
the baremetal firmware into a reserved region. The Linux start the remote processor
by sending request to OpenSBI and then exchanges messages with it over shared-memory.

The provided `openampEcho` sample application is a minimal firmware. It brings up
rpmsg, waits for a name-service announcement from Linux and echoes back every message
it receives. It serve as the template for further remote applications development.

## Key Features

* **Upstream OpenAMP / libmetal** — fetched automatically at build time.
* **remoteproc lifecycle** — firmware is loaded, started and stopped from Linux
  via the standard `remoteproc` sysfs interface.
* **SBI IPI doorbell** — remote-to-Linux or Linux-to-Remote notification uses
  an openSBI IPI.

## Hardware / SoC Requirements

This solution targets the High-Performance Sapphire SoC on the Titanium
TI375C529 development kit.

* One hart must be **excluded from the Linux SMP set** and reserved for the
  remote (Linux runs on harts 0–2). Bare-metal firmware runs on hart3.
* A **reserved-memory carveout** must be set aside for the remote firmware image
  and the OpenAMP shared region, and must not be handed to the Linux page
  allocator.
* The remote firmware runs in **S-mode** and relies on OpenSBI for IPI and HSM
  (`HART_START` and 'HART_STOP') services.

## Directory Structure

+---software
+---standalone
+---openamp
+---lib                 auto-fetched at build time
│   +---open-amp        upstream OpenAMP  (not committed)
│   +---libmetal        upstream libmetal (not committed)
+---port
│   +---metal/system/generic/efinix_ti375_rv32
│       +---sys.c       libmetal machine port
│       +---sys.h
+---shared
│   +---shm_layout.h    AMP shared-memory
│   +---sbi.h           openSBI inline helpers
│   +---openamp_transport.c/.h   libmetal init, vring bring-up
│   +---amp_rsc_table.c/.h       resource-table publication
│   +---amp_trap.c/.h            S-mode software-interrupt handler
│   +---amp_remote.c/.h          remote bring-up
+---openamp_libs.mk     builds libopen_amp.a + libmetal.a
+---openamp_app.mk      application facing
+---openampEcho         openAMP echo sample application
+---makefile
+---src/main.c      endpoint callback + main loop


## Software Requirements

### Efinity Software

- [Efinity 2025.2](https://www.efinixinc.com/support/efinity.php) or above.

### Efinity RISC-V Embedded Software IDE

- [v2025.2](https://www.efinixinc.com/support/efinity.php) or above. Follow the
  official [Sapphire user guide](https://www.efinixinc.com/support/docsdl.php?s=ef&pn=SAPPHIREUG)
  for installation.

### Build host

- **git** must be on the build environment's `PATH`. On the first build the
  makefiles clone `open-amp` and `libmetal` into `openamp/lib`. If the IDE build environment
  cannot reach the network, clone the two repos manually to populate the folder.

### Linux side

- The Linux image, device tree (`reserved-memory` + `remoteproc` nodes) and
  rootfs are produced by [br2-efinix](https://github.com/Efinix-Inc/br2-efinix).
  The compiled remote firmware is delivered to the target through that project's
  rootfs overlay (see [Deploying to Linux](#deploying-to-linux)).

## Shared-Memory Address Map

| Region           | Address        | Size     | Purpose                          |
| :---             | :---           | :---     | :---                             |
| Remote firmware  | `0x04000000`   | 2 MiB    | Execution code/data              |
| Shared base      | `0x04200000`   | 62 MiB   | OpenAMP shared region            |
| Resource table   | `+0x0000`      | 256 B    | vdev + 2 vring descriptors       |
| Kick R2L         | `+0x0100`      | word     | Doorbell (remote kick Linux)     |
| Remote ready     | `+0x0110`      | word     | `REMOTE_READY_MAGIC`             |
| Linux ready      | `+0x0114`      | word     | `LINUX_READY_MAGIC`              |
| Linux control    | `+0x0118`      | word     | Shutdown request (`0xFF00FF00`)  |
| Vring0           | `+0x2000`      | 8 KiB    | Remote TX / Linux RX             |
| Vring1           | `+0x4000`      | 8 KiB    | Linux TX / Remote RX             |
| Buffer pool      | `+0x10000`     | 60 MiB   | RPMsg payload buffers            |

## Building the Firmware

1. Launch the Efinity RISC-V Embedded Software IDE and import the
   `EfxSapphireSoc` BSP generated for your Ti375C529 project.
2. Import the `openampEcho` project from the standalone tree.
3. On the first build the OpenAMP and libmetal sources are cloned into
   `openamp/lib` automatically and compiled into
   `libopen_amp.a` / `libmetal.a` and linked with the app.

The build produces `openampEcho.elf` under the project `build/` directory.

## Deploying to Linux

The remote firmware is delivered to the target through the br2-efinix rootfs
overlay at `/lib/firmware/`:

/board/efinix//rootfs_overlay/lib/firmware/openampEcho.elf


On the running target, follow the below steps to load and start the firmware:

```bash
echo openampEcho.elf > /sys/class/remoteproc/remoteproc0/firmware
echo start           > /sys/class/remoteproc/remoteproc0/state
On start, the firmware console prints its bring-up info (SHM base, vring
addresses, "resource table published", endpoint creation).

Running the Echo Demo
Bash
modprobe efinix_ti375_remoteproc.ko
echo openampEcho.elf > /sys/class/remoteproc/remoteproc0/firmware
echo start > /sys/class/remoteproc/remoteproc0/state
./openamp_app
Output on the Linux terminal:

root@buildroot:~# ./openamp_app
Packet #47 (Len: 257, Token: U) -> PASSED
Packet #48 (Len: 496, Token: V) -> PASSED
Packet #49 (Len: 4, Token: W) -> PASSED
Packet #50 (Len: 15, Token: X) -> PASSED
--------------------------------------------------------
Echo Test Complete. Total: 50, Success: 50, Failures: 0
Output on the remote core terminal:

EEEEEEE  FFFFFFF  IIIII  NN   NN  IIIII  XX   XX
EE       FF         I    NNN  NN    I     XX XX
EEEEE    FFFFF      I    NN N NN    I      XXX
EE       FF         I    NN  NNN    I     XX XX
EEEEEEE  FF       IIIII  NN   NN  IIIII  XX   XX

FPGA Acceleration | RISC-V | OpenAMP
----------------------------------------

BareMetal: SHM_BASE        = 04200000
BareMetal: SHM_RSC_ADDR    = 04200000
BareMetal: SHM_VRING0_ADDR = 04202000
BareMetal: SHM_VRING1_ADDR = 04204000
BareMetal: resource table published
BareMetal: openamp_init OK -- creating demo endpoint
BareMetal: endpoint created at addr 30
BareMetal: NS announcement Completed, idling
