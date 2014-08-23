#!/usr/bin/env python

import u3

class LabjackInterface(object):
    def __init__(self, labjack=None):
        if labjack is None:
            labjack = u3.U3()
        self._labjack = labjack

        # disable timers so they don't interfere with dio
        self._labjack.configIO(NumberOfTimersEnabled=0)

        # configure inputs
        self._labjack.getDIState(u3.FIO3)  # /reset
        self._labjack.getDIState(u3.FIO6)  # ready
        self._labjack.getDIState(u3.FIO7)  # dirc

        # configure eio port as input
        self._labjack.getFeedback(self._DISCONNECT_DATA_BUS)

        # configure outputs
        self._labjack.setDOState(u3.FIO0, 1)  # 74hct245 /oe for data bus
        self._labjack.setDOState(u3.FIO1, 1)  # /strobe

    _CONNECT_DATA_BUS = [
        # set eio port to input
        u3.PortDirWrite(Direction=[0, 0x00, 0],
                        WriteMask=[0, 0xff, 0]),

        # set fio0 low (/oe on 74hct245)
        u3.PortStateWrite(State=[0,0,0],
                          WriteMask=[0x01, 0, 0])
    ]

    _DISCONNECT_DATA_BUS = [
        # set fio0 high (/oe on 74hct245)
        u3.PortStateWrite(State=[0x01,0,0],
                          WriteMask=[0x01, 0, 0]),

        # set eio port as input
        u3.PortDirWrite(Direction=[0, 0x00, 0],
                        WriteMask=[0, 0xff, 0])
    ]

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

    def read_status(self, fio=None):
        '''Read the status bits from the drive'''
        if fio is None:
            cmd = u3.PortStateRead()
            fio = self._labjack.getFeedback(cmd)[0]['FIO']
        ready = bool(fio & 0x40) # fio6 (ready high = drive is ready)
        dirc  = bool(fio & 0x80) # fio7 (dirc high = host-to-drive)
        return ready, dirc

    def read(self):
        '''Read one byte from the drive'''
        # wait until ready=high
        ready = False
        while not(ready):
            ready, _ = self.read_status()

        data_read = u3.PortStateRead()

        cmds = (self._CONNECT_DATA_BUS +
                [ data_read ] +
                self._STROBE +
                self._DISCONNECT_DATA_BUS)

        responses = self._labjack.getFeedback(cmds)
        ports = responses[cmds.index(data_read)]
        return ports['EIO']

    def read_multi(self, count):
        '''Read multiple bytes from the drive.  This method optimizes the
        number of packets sent to the LabJack so that it will perform
        faster than calling read() for each byte.'''
        if count == 0:
            return []
        elif count == 1:
            return [ self.read() ]

        buffer = []
        pos = 0
        while pos < count:
            data_read = u3.PortStateRead()
            status_read = u3.PortStateRead()

            if pos == 0:
                # for first byte only, we have to wait for ready
                # before connecting the data bus
                ready = False
                while not(ready):
                    ready, _ = self.read_status()

                # connect data bus, read data byte, strobe, wait 128us,
                # and read the status byte.  the data bus is left connected.
                cmds = (self._CONNECT_DATA_BUS +
                        [ data_read ] +
                        self._STROBE +
                        [ u3.WaitShort(Time=1) ] +
                        [ status_read ])
                responses = self._labjack.getFeedback(cmds)

                # data byte
                ports = responses[cmds.index(data_read)]
                buffer.append(ports['EIO'])

                # status bits
                ports = responses[cmds.index(status_read)]
                ready, _ = self.read_status(ports['FIO'])
                while not(ready):
                    ready, _ = self.read_status()

            elif pos < count-1:
                # for each successive byte except the last, we know
                # that the drive is ready and that the data bus is connected.
                # read the data, strobe, wait 128us, and then read the status
                # byte.  the data bus will be left connected.
                cmds = ([ data_read ] +
                        self._STROBE +
                        [ u3.WaitShort(Time=1) ] +
                        [ status_read ])
                responses = self._labjack.getFeedback(cmds)

                # data byte
                ports = responses[cmds.index(data_read)]
                buffer.append(ports['EIO'])

                # status bits
                ports = responses[cmds.index(status_read)]
                ready, _ = self.read_status(ports['FIO'])
                while not(ready):
                    ready, _ = self.read_status()

            else:
                # for the last byte, read the data byte, strobe, and
                # then disconnect the data bus.
                cmds = ([ data_read ] +
                        self._STROBE +
                        self._DISCONNECT_DATA_BUS)
                responses = self._labjack.getFeedback(cmds)

                # data byte
                ports = responses[cmds.index(data_read)]
                buffer.append(ports['EIO'])
            pos += 1
        return buffer

    def write(self, value):
        # wait until ready=high
        ready = False
        while not(ready):
            ready, _ = self.read_status()

        # put data byte on eio port
        data_write = u3.PortStateWrite(State=[0, value, 0],
                                       WriteMask=[0, 0xff, 0])

        cmds = (self._CONNECT_DATA_BUS +
                [ data_write ] +
                self._STROBE +
                self._DISCONNECT_DATA_BUS)
        self._labjack.getFeedback(cmds)

    def write_multi(self, values):
        '''Write multiple bytes to the drive.  This method optimizes the
        number of packets sent to the LabJack so that it will perform
        faster than calling write() for each byte.'''

        count = len(values)
        if count == 1:
            return self.write(values[0])

        pos = 0
        while pos < count:
            data_write = u3.PortStateWrite(State=[0, values[pos], 0],
                                           WriteMask=[0, 0xff, 0])
            status_read = u3.PortStateRead()

            if pos == 0:
                # for first byte only, we have to wait for ready
                # before connecting the data bus
                ready = False
                while not(ready):
                    ready, _ = self.read_status()

                # connect data bus, write data byte, strobe, wait 128us,
                # and read the status byte.  the data bus is left connected.
                cmds = (self._CONNECT_DATA_BUS +
                        [ data_write ] +
                        self._STROBE +
                        [ u3.WaitShort(Time=1) ] +
                        [ status_read ])
                responses = self._labjack.getFeedback(cmds)

                # status bits
                ports = responses[cmds.index(status_read)]
                ready, _ = self.read_status(ports['FIO'])
                while not(ready):
                    ready, _ = self.read_status()

            elif pos < count-1:
                # for each successive byte except the last, we know
                # that the drive is ready and that the data bus is connected.
                # write the data, strobe, wait 128us, and then read the status
                # byte.  the data bus will be left connected.
                cmds = ([ data_write ] +
                        self._STROBE +
                        [ u3.WaitShort(Time=1) ] +
                        [ status_read ])
                responses = self._labjack.getFeedback(cmds)

                # status bits
                ports = responses[cmds.index(status_read)]
                ready, _ = self.read_status(ports['FIO'])
                while not(ready):
                    ready, _ = self.read_status()

            else:
                # for the last byte, write the data byte, strobe, and
                # then disconnect the data bus.
                cmds = ([ data_write ] +
                        self._STROBE +
                        self._DISCONNECT_DATA_BUS)
                self._labjack.getFeedback(cmds)
            pos += 1
        return

    def init_drive(self):
        response = None
        while response != 0x8f:
            # wait until ready=high and dirc=high (host-to-drive)
            ready, dirc = False, False
            while not(ready) or not(dirc):
                ready, dirc = self.read_status()

            # send command 0xff (invalid command)
            self.write(0xff)

            # bus turn-around
            # wait until ready=high and dirc=low (drive-to-host)
            ready, dirc = False, True
            while not(ready) or dirc:
                ready, dirc = self.read_status()

            # response should return 0x8f (invalid command)
            response = self.read()

    def request(self, request, response_length):
        # send request packet
        self.write_multi(request)

        # bus turn-around
        # wait until ready=high and dirc=low (drive-to-host)
        ready, dirc = False, True
        while not(ready) or dirc:
            ready, dirc = self.read_status()

        # read error byte
        error = self.read()
        if error & 0x80:
            raise ValueError("CORVUS %02x ERROR" % error)

        # read response packet
        response = self.read_multi(response_length)
        return error, response


class Corvus(object):
    def __init__(self, iface=None):
        if iface is None:
            iface = LabjackInterface()
        self._iface = iface

    def init_drive(self):
        self._iface.init_drive()

    def get_drive_capacity(self, drive):
        '''Returns total capacity as count of 512-byte sectors'''
        cmd = 0x10 # get drive paramaters
        _, params = self._iface.request([cmd, drive], 128)
        total_sectors = params[37] + (params[38] << 8) + (params[39] << 16)
        return total_sectors

    def read_sector_128(self, drive, sector):
        cmd = 0x12 # read 128-byte sector
        msn_drv, lsb, msb = self._make_dadr(drive, sector)
        _, sector_128 = self._iface.request([cmd, msn_drv, lsb, msb], 128)
        return sector_128

    def read_sector_256(self, drive, sector):
        cmd = 0x22 # read 256-byte sector
        msn_drv, lsb, msb = self._make_dadr(drive, sector)
        _, sector_256 = self._iface.request([cmd, msn_drv, lsb, msb], 256)
        return sector_256

    def read_sector_512(self, drive, sector):
        cmd = 0x32 # read 512-byte sector
        msn_drv, lsb, msb = self._make_dadr(drive, sector)
        _, sector_512 = self._iface.request([cmd, msn_drv, lsb, msb], 512)
        return sector_512

    def write_sector_128(self, drive, sector, data):
        cmd = 0x13 # write 128-byte sector
        msn_drv, lsb, msb = self._make_dadr(drive, sector)
        req = [cmd, msn_drv, lsb, msb] + data
        error, _ = self._iface.request(req, 0)
        return error

    def write_sector_256(self, drive, sector, data):
        cmd = 0x23 # write 256-byte sector
        msn_drv, lsb, msb = self._make_dadr(drive, sector)
        req = [cmd, msn_drv, lsb, msb] + data
        error, _ = self._iface.request(req, 0)
        return error

    def write_sector_512(self, drive, sector, data):
        cmd = 0x33 # write 512-byte sector
        msn_drv, lsb, msb = self._make_dadr(drive, sector)
        req = [cmd, msn_drv, lsb, msb] + data
        error, _ = self._iface.request(req, 0)
        return error

    def enter_prep_mode(self, drive, prep_block=None):
        if prep_block is None:
            prep_block = _PREP_BLOCK
        cmd = 0x11 # put drive into prep mode
        req = [cmd, drive] + prep_block
        error, _ = self._iface.request(req, 0)
        return error

    def exit_prep_mode(self):
        cmd = 0x00 # reset (only works in prep mode)
        req = [cmd]
        error, _ = self._iface.request(req, 0)
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

_PREP_BLOCK = [
    0x00,0x00,0x3e,0x03,0xd3,0x6a,0xd3,0x6b,0xaf,0x32,0x11,0x60,0x21,0x00,
    0x00,0x22,0x12,0x60,0xcd,0x74,0x00,0x3e,0x03,0xd3,0x7e,0xcd,0xaf,0x81,
    0xb7,0x28,0x1e,0xfe,0x01,0x28,0x29,0xfe,0x32,0x28,0x42,0xfe,0x33,0x28,
    0x54,0xfe,0x07,0x28,0x74,0x3e,0x8f,0x32,0x11,0x60,0x21,0x00,0x00,0x22,
    0x12,0x60,0xc3,0xa0,0x81,0xcd,0xa7,0x00,0x21,0x00,0x00,0x22,0x12,0x60,
    0xcd,0x74,0x00,0xc3,0x00,0x00,0x01,0x00,0x02,0xcd,0xe9,0x81,0x11,0x00,
    0x82,0xed,0xb0,0x21,0x00,0x00,0x22,0xfe,0x81,0xcd,0x3d,0x00,0x21,0x00,
    0x00,0x22,0x12,0x60,0xc3,0xa0,0x81,0xcd,0xaf,0x81,0x32,0xfd,0x81,0x21,
    0x00,0x00,0x22,0xfe,0x81,0xd7,0x21,0x00,0x76,0x22,0x12,0x60,0xc3,0xa0,
    0x81,0x01,0x01,0x02,0xcd,0xe9,0x81,0x7e,0x32,0xfd,0x81,0x21,0x00,0x00,
    0x22,0xfe,0x81,0xe7,0xc2,0xa0,0x81,0x21,0x01,0x00,0x22,0xfe,0x81,0xe7,
    0x21,0x00,0x00,0x22,0x12,0x60,0xc3,0xa0,0x81,0x21,0x01,0xa2,0x22,0x12,
    0x60,0xaf,0x32,0x00,0xa2,0x32,0xfd,0x81,0x21,0x00,0x00,0x22,0xfe,0x81,
    0xcd,0xdd,0x80,0xcd,0x0d,0x81,0x28,0xf8,0x21,0x00,0xa4,0xed,0x4b,0x00,
    0xa2,0x06,0x00,0x03,0xb7,0xed,0x42,0xeb,0xd5,0x21,0x00,0xa2,0xed,0xb0,
    0xe1,0x11,0x00,0x14,0x19,0x22,0x12,0x60,0xc3,0xa0,0x81,0xcd,0x0b,0x00,
    0xcd,0xa9,0x81,0xc0,0x3a,0xfd,0x81,0xe6,0xe0,0xcd,0x3b,0x81,0x3a,0xfd,
    0x81,0xe6,0xe0,0xc6,0x01,0xcd,0x3b,0x81,0x3a,0xfd,0x81,0xe6,0xe0,0xc6,
    0x02,0xcd,0x3b,0x81,0x3a,0xfd,0x81,0xe6,0xe0,0xc6,0x03,0xcd,0x3b,0x81,
    0xc3,0xa9,0x81,0x3a,0x09,0x60,0x0f,0x0f,0x0f,0x47,0x3a,0xfd,0x81,0xe6,
    0xe0,0xc6,0x20,0x32,0xfd,0x81,0xb8,0x38,0x17,0xaf,0x32,0xfd,0x81,0x2a,
    0xfe,0x81,0x23,0x22,0xfe,0x81,0xeb,0x2a,0x02,0x60,0xb7,0xed,0x52,0x30,
    0x03,0xf6,0xff,0xc9,0xc3,0xa4,0x00,0x21,0xca,0x60,0x47,0x3e,0x14,0xcb,
    0x3f,0xcb,0x3f,0x77,0x78,0x32,0xfd,0x81,0xf7,0xcd,0x13,0x00,0x30,0x43,
    0xd7,0x2a,0x12,0x60,0x3a,0xfd,0x81,0xcb,0x07,0xcb,0x07,0xcb,0x07,0xe6,
    0x07,0x77,0x23,0xed,0x4b,0xfe,0x81,0x71,0x23,0x70,0x23,0x3a,0xfd,0x81,
    0xe6,0x1f,0x77,0x23,0x22,0x12,0x60,0x3a,0x00,0xa2,0xc6,0x04,0x32,0x00,
    0xa2,0x30,0x07,0x3e,0x10,0x32,0x15,0x60,0x18,0x1c,0x21,0x00,0x62,0x11,
    0x00,0x82,0x01,0x00,0x02,0xed,0xb0,0xdf,0xcd,0xa7,0x00,0x3a,0xfd,0x81,
    0xc6,0x04,0x21,0xca,0x60,0x35,0xc2,0x47,0x81,0xc9,0x31,0xed,0x61,0xcd,
    0x74,0x00,0xc3,0x15,0x80,0x3a,0x14,0x60,0xfe,0xff,0xc9,0xf3,0x3e,0xc3,
    0x32,0x0c,0x48,0x21,0xd5,0x81,0x22,0x0d,0x48,0xdb,0x74,0xcd,0x77,0x00,
    0x3e,0x4f,0xd3,0x6b,0xdb,0x69,0x3e,0x44,0xd3,0x6b,0x3e,0x83,0xd3,0x6b,
    0x3e,0xed,0xd3,0x68,0xfb,0x18,0xfe,0x3e,0xcd,0xd3,0x68,0x3e,0x01,0xd3,
    0x7f,0x3e,0x03,0xd3,0x6b,0xd3,0x6a,0xdb,0x69,0xe1,0xfb,0xed,0x4d,0x3e,
    0xd5,0xd3,0x68,0xc3,0x7d,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
    0xf8,0x01,0x00,0x00,0x02,0x00,0x01,0x01
]
