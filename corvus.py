#!/usr/bin/env python

import sys
import u3

class Corvus(object):
    def __init__(self, labjack=None):
        if labjack is None:
            labjack = u3.U3()
        self._labjack = labjack

        self._setup_labjack()

    # Low-Level Hardware Methods

    def _setup_labjack(self):
        # configure inputs
        self._labjack.getDIState(u3.FIO3)  # /reset
        self._labjack.getDIState(u3.FIO6)  # ready
        self._labjack.getDIState(u3.FIO7)  # dirc

        # configure outputs
        self._labjack.setDOState(u3.FIO0, 1)  # 74hct245 /oe for data bus
        self._labjack.setDOState(u3.FIO1, 1)  # /strobe

        # disable timers so they don't interfere with dio
        self._labjack.configIO(NumberOfTimersEnabled=0)

    def is_drive_ready(self):
        return self._labjack.getDIState(u3.FIO6) == 1

    def is_host_to_drive(self):
        return self._labjack.getDIState(u3.FIO7) == 1

    _STROBE = [
        # set fio1 low (/strobe)
        u3.PortStateWrite(State=[0x00, 0, 0],
                          WriteMask=[0x02, 0, 0]),

        # wait ~128 microseconds
        u3.WaitShort(Time=1),

        # set fio1 high
        u3.PortStateWrite(State=[0x02, 0, 0],
                          WriteMask=[0x02, 0, 0])
    ]

    def strobe(self):
        return self._labjack.getFeedback(self._STROBE)

    _CONNECT_DATA_BUS = [
        # set eio port to input
        u3.PortDirWrite(Direction=[0, 0x00, 0],
                        WriteMask=[0, 0xff, 0]),

        # set fio0 low (/oe on 74hct245)
        u3.PortStateWrite(State=[0,0,0],
                          WriteMask=[0x01, 0, 0])
    ]

    def connect_data_bus(self):
        self._labjack.getFeedback(self._CONNECT_DATA_BUS)

    _DISCONNECT_DATA_BUS = [
        # set fio0 high (/oe on 74hct245)
        u3.PortStateWrite(State=[0x01,0,0],
                          WriteMask=[0x01, 0, 0]),

        # set eio port as input
        u3.PortDirWrite(Direction=[0, 0x00, 0],
                        WriteMask=[0, 0xff, 0])
    ]

    def disconnect_data_bus(self):
        self._labjack.getFeedback(self._DISCONNECT_DATA_BUS)

    def read_data(self):
        while not(self.is_drive_ready()):
            pass

        port_state_read = u3.PortStateRead()

        cmds = (self._CONNECT_DATA_BUS +
                [ port_state_read ] +
                self._STROBE +
                self._DISCONNECT_DATA_BUS)

        responses = self._labjack.getFeedback(cmds)
        ports = responses[cmds.index(port_state_read)]
        return ports['EIO']

    def write_data(self, value):
        while not(self.is_drive_ready()):
            pass

        # put data byte on eio port
        port_state_write = u3.PortStateWrite(State=[0, value, 0],
                                             WriteMask=[0, 0xff, 0])

        cmds = (self._CONNECT_DATA_BUS +
                [ port_state_write ] +
                self._STROBE +
                self._DISCONNECT_DATA_BUS)
        self._labjack.getFeedback(cmds)

    # Higher-Level Command Methods

    def init_drive(self):
        response = 0
        while response != 0x8f:
            while not(self.is_drive_ready()):
              pass
            while not(self.is_host_to_drive()):
              pass

            value = 0xff # 0xff is an invalid command
            self.write_data(value)

            while not(self.is_drive_ready()):
              pass
            while self.is_host_to_drive():
              pass

            # response should return 0x8f (invalid command)
            response = self.read_data()

    def _make_dadr(self, drive, sector):
        # byte 0:
        #   upper nibble = bits 16-19 of sector address
        #   lower nibble = corvus unit id (1-15)
        b0 = ((sector & 0x0f0000) >> 12) + (drive & 0x0f)
        # byte 1: bits 0-7 of sector address
        b1 = sector & 0xff
        # byte 2: bits 8-15 of sector address
        b2 = (sector & 0xff00) >> 8
        return (b0, b1, b2)

    def _read_sector(self, drive, sector, cmd, size):
        # send command to read sector
        self.write_data(cmd)

        # send disk address
        for x in self._make_dadr(drive, sector):
            self.write_data(x)

        # wait for bus to turn around
        while not(self.is_drive_ready()):
          pass
        while self.is_host_to_drive():
          pass

        # read error byte
        result = self.read_data()
        if result != 0:
            raise ValueError("CORVUS %02x ERROR" % result)

        sector = []
        for i in range(size):
            sector.append(self.read_data())
        return sector

    def read_sector_128(self, drive, sector):
        return self._read_sector(drive, sector, 0x12, 128)

    def read_sector_256(self, drive, sector):
        return self._read_sector(drive, sector, 0x22, 256)

    def read_sector_512(self, drive, sector):
        return self._read_sector(drive, sector, 0x32, 512)

    def get_drive_capacity(self, drive):
        '''Returns total capacity as count of 512-byte sectors'''
        # send command to get drive parameters
        self.write_data(0x10)

        # send disk address
        self.write_data(drive)

        # read error byte
        result = self.read_data()
        if result != 0:
            raise ValueError("CORVUS %02x ERROR" % result)

        # read parameter block
        params = []
        for i in range(128):
            params.append(self.read_data())

        total_sectors = params[37] + (params[38] << 8) + (params[39] << 16)
        return total_sectors

if __name__ == "__main__":
    corvus = Corvus()
    corvus.init_drive()
    total_sectors = corvus.get_drive_capacity(1)
    with open("image.bin", "wb") as f:
        for i in range(total_sectors):
            sector = corvus.read_sector_512(1, i)
            f.write(''.join([chr(d) for d in sector]))
            sys.stdout.write("\r%d bytes read" % (i * 512))
            sys.stdout.flush()
