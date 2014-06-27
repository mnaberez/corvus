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

    def read(self):
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

    def write(self, value):
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

    def request(self, request, response_length):
        # send request packet
        for byte in request:
            self.write(byte)

        # wait for bus to turn around
        while not(self.is_drive_ready()):
          pass
        while self.is_host_to_drive():
          pass

        # read error byte
        error = self.read()
        if error != 0:
            raise ValueError("CORVUS %02x ERROR" % error)

        # read response packet
        response = []
        for i in range(response_length):
            response.append(self.read())
        return error, response

    # Higher-Level Command Methods

    def init_drive(self):
        response = 0
        while response != 0x8f:
            while not(self.is_drive_ready()):
              pass
            while not(self.is_host_to_drive()):
              pass

            value = 0xff # 0xff is an invalid command
            self.write(value)

            while not(self.is_drive_ready()):
              pass
            while self.is_host_to_drive():
              pass

            # response should return 0x8f (invalid command)
            response = self.read()

    def get_drive_capacity(self, drive):
        '''Returns total capacity as count of 512-byte sectors'''
        cmd = 0x10 # get drive paramaters
        _, params = self.request([cmd, drive], 128)
        total_sectors = params[37] + (params[38] << 8) + (params[39] << 16)
        return total_sectors

    def read_sector_128(self, drive, sector):
        cmd = 0x12 # read 128-byte sector
        msn_drv, lsb, msb = self._make_dadr(drive, sector)
        _, sector_128 = self.request([cmd, msn_drv, lsb, msb], 128)
        return sector_128

    def read_sector_256(self, drive, sector):
        cmd = 0x22 # read 256-byte sector
        msn_drv, lsb, msb = self._make_dadr(drive, sector)
        _, sector_256 = self.request([cmd, msn_drv, lsb, msb], 256)
        return sector_256

    def read_sector_512(self, drive, sector):
        cmd = 0x32 # read 512-byte sector
        msn_drv, lsb, msb = self._make_dadr(drive, sector)
        _, sector_512 = self.request([cmd, msn_drv, lsb, msb], 512)
        return sector_512

    def write_sector_128(self, drive, sector, data):
        cmd = 0x13 # write 128-byte sector
        msn_drv, lsb, msb = self._make_dadr(drive, sector)
        req = [cmd, msn_drv, lsb, msb] + data
        error, _ = self.request(req, 0)
        return error

    def write_sector_256(self, drive, sector, data):
        cmd = 0x23 # write 256-byte sector
        msn_drv, lsb, msb = self._make_dadr(drive, sector)
        req = [cmd, msn_drv, lsb, msb] + data
        error, _ = self.request(req, 0)
        return error

    def write_sector_512(self, drive, sector, data):
        cmd = 0x33 # write 512-byte sector
        msn_drv, lsb, msb = self._make_dadr(drive, sector)
        req = [cmd, msn_drv, lsb, msb] + data
        error, _ = self.request(req, 0)
        return error

    def _make_dadr(self, drive, sector):
        # byte 0:
        #   upper nibble = bits 16-19 of sector address
        #   lower nibble = corvus unit id (1-15)
        b0 = ((sector & 0x0f0000) >> 12) + (drive & 0x0f)
        # byte 1: bits 0-7 of sector address
        b1 = sector & 0xff
        # byte 2: bits 8-15 of sector address
        b2 = (sector & 0xff00) >> 8
        return b0, b1, b2

if __name__ == "__main__":
    corvus = Corvus()
    corvus.init_drive()
    total_sectors = corvus.get_drive_capacity(1)
    with open("image.bin", "wb") as f:
        for i in range(total_sectors):
            data = corvus.read_sector_512(1, i)
            corvus.write_sector_512(1, i, data)
            data = corvus.read_sector_512(1, i)
            f.write(''.join([chr(d) for d in data]))
            f.flush()
            sys.stdout.write("\r%d bytes" % (i * 512))
            sys.stdout.flush()
