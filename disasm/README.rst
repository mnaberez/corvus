Corvus Hard Drive Disassemblies
-------------------------------

This directory contains disassemblies of Corvus hard disk controller code.
There are three types of code that run on a Corvus controller: the ROM, the
Firmware, and Prep Blocks.

ROM
===

The "ROM" is a 2732 EPROM at address 0x0000.  The Z80 jumps to ROM at startup.
It appears to contain low-level functions for accessing the drive, loading the
firmware, and has just enough of the host commands to enter prep mode.

- `rom-u62-c7.63.bin`: dump of the 2732 EPROM from my Corvus Rev B drive.
  It is identical to the ROM listed in `imi5000h.c` in the MESS emulator,
  which was dumped independently.

Firmware
========

The "firmware" is Z80 code that is stored in a protected area of the hard
disk.  This area can only be accessed by the ROM or by prep mode.  The ROM
loads the firmware code, and it implements the bulk of the host commands.

Not disassembled yet.

Prep Blocks
===========

To format a new drive or write firmware to it, the host sends the command to
enter "prep mode" (0x11).  The host sends a 512-byte payload with this
command that the Corvus manuals call the "prep block".  The prep block for
the Rev B/H drive is Z80 machine code.  The drive stores the prep block in
memory at `0x8000` and then jumps to it.

- `prep-corvus-diag.bin`: prep block sent by the Corvus diagnostics program
  `DIAG.COM` on the SSE SoftBox distribution disk.

- `prep-hardbox-configure.bin`: prep block sent by the `CONFIGURE` program on
  the SSE HardBox utility disk.

The prep block contains the actual implementation of all prep mode commands.
Since the host sends the prep block, and the prep block can contain any Z80
code, it's possible for a host to send a prep block that causes prep mode to
behave in a way that's completely different from what is described in the
Corvus manuals.

The two prep blocks above have code differences but both implement the prep
mode commands as described in the Corvus Mass Storage GTI.
