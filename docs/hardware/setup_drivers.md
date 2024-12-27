# Installing USB Driver

This guide cover in installing Windows USB driver, managing drivers when two or more Efinix Device are installed on the Windows. 

## Installing the Linux USB Driver
Before proceeding, ensure you have installed the latest version [Efinity](https://www.efinixinc.com/support/efinity.php).

 The following instructions explain how to install a USB driver for Linux operating systems:

 1. Disconnect your board from your computer.

 2. In a terminal, use these commands:
    ```
    > sudo <efinity directory>/bin/install_usb_driver.sh
    > sudo udevadm control --reload-rules
    ```

Note: If your board was connected to your computer before you executed these commands, you need to disconnect it and then reconnect it.

## Installing the Windows USB Driver

### Table 1: Efinix Development Boards with FTDI Chips from [AN 050: Managing Windows Drivers](https://www.efinixinc.com/support/docsdl.php?s=ef&pn=AN050)

| Board                                   | FTDI Chip | VID    | PID    | Interface 0 | Interface 1 | Interface 2     | Interface 3    |
|-----------------------------------------|-----------|--------|--------|-------------|-------------|-----------------|----------------|
| Trion T120 BGA576 Development Board     | FT2232H   | 0x0403 | 0x6010 | SPI         | JTAG        | —               | —              |
| Titanium Ti180 J484 Development Board   | FT2232H   | 0x0403 | 0x6010 | UART (FPGA) | JTAG        | —               | —              |

`[IMPORTANT]` 

If you have another Efinix board installed on the same Windows, you must manage drivers accordingly. Refer to [AN 050: Managing Windows Drivers](https://www.efinixinc.com/support/docsdl.php?s=ef&pn=AN050) for more information.

* To install driver for T120F576, refer to the ``Installing the Windows USB Drivers`` section in [Trion T120F576 Development Kit User Guide](https://www.efinixinc.com/support/docsdl.php?s=ef&pn=T120F576-DK-UG#page=4).
* To install driver for Ti180J484, refer to the ``Installing the Windows USB Drivers`` section in[Titanium Ti180J484 Development Kit User Guide](https://www.efinixinc.com/support/docsdl.php?s=ef&pn=Ti180J484-DK-UG#page=6).
* To install driver for Ti375C529, refer to the ``Installing the Windows USB Drivers`` section in[Titanium Ti375C529 Development Kit User Guide](https://www.efinixinc.com/support/docsdl.php?s=ef&pn=Ti375C529-DK-UG#page=5).
