#!/usr/bin/env python

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
        self._labjack.setDOState(u3.FIO4, 1)  # /strobe

        # disable timers so they don't interfere with dio
        self._labjack.configIO(NumberOfTimersEnabled=0)

    def strobe(self):
        cmds = [
            # set fio4 low (/strobe)
            u3.PortStateWrite(State=[0x00, 0, 0],
                              WriteMask=[0x10, 0, 0]),

            # wait ~128 microseconds
            u3.WaitShort(Time=1),

            # set fio4 high
            u3.PortStateWrite(State=[0x10, 0, 0],
                              WriteMask=[0x10, 0, 0]),
        ]
        self._labjack.getFeedback(cmds)

    def is_drive_ready(self):
        return self._labjack.getDIState(u3.FIO6) == 1

    def is_host_to_drive(self):
        return self._labjack.getDIState(u3.FIO7) == 1

    def connect_data_bus(self):
        cmds = [
            # set eio port to input
            u3.PortDirWrite(Direction=[0, 0x00, 0],
                            WriteMask=[0, 0xff, 0]),

            # set fio0 low (/oe on 74hct245)
            u3.PortStateWrite(State=[0,0,0],
                              WriteMask=[0x01, 0, 0])
        ]
        self._labjack.getFeedback(cmds)

    def disconnect_data_bus(self):
        cmds = [
            # set fio0 high (/oe on 74hct245)
            u3.PortStateWrite(State=[0x01,0,0],
                              WriteMask=[0x01, 0, 0]),

            # set eio port as input
            u3.PortDirWrite(Direction=[0, 0x00, 0],
                            WriteMask=[0, 0xff, 0]),
        ]
        self._labjack.getFeedback(cmds)

    def read_data(self):
        while not(self.is_drive_ready()):
            pass

        # set pins as input
        cmd = u3.PortDirWrite(Direction=[0, 0x00, 0],
                              WriteMask=[0, 0xff, 0])
        self._labjack.getFeedback(cmd)

        self.connect_data_bus()

        # lines must already be configured as input
        # read each line to build the byte
        cmd = u3.PortStateRead()
        ports = self._labjack.getFeedback(cmd)[0]
        value = ports['EIO']
        self.strobe()
        self.disconnect_data_bus()

        return value

    def write_data(self, value):
        while not(self.is_drive_ready()):
            pass

        # turn on lines for bits that are high
        self.connect_data_bus()
        cmd = u3.PortStateWrite(State=[0, value, 0],
                                WriteMask=[0, 0xff, 0])
        self._labjack.getFeedback(cmd)
        self.strobe()
        self.disconnect_data_bus()

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

    def read_sector_128(self, dadr):
        self.write_data(0x12)                    # read 128-byte sector
        self.write_data( dadr & 0x0000ff)        # dadr byte 0
        self.write_data((dadr & 0x00ff00) >> 8)  # dadr byte 1
        self.write_data((dadr & 0xff0000) >> 16) # dadr byte 2

        # wait for bus to turn around
        while not(self.is_drive_ready()):
          pass
        while self.is_host_to_drive():
          pass

        # read error byte
        result = self.read_data()

        if result == 0:
            sector = []
            for i in range(128):
                sector.append(self.read_data())
            return sector
        else:
            raise ValueError("CORVUS %02x ERROR" % result)

if __name__ == "__main__":
    corvus = Corvus()
    corvus.init_drive()
    sector = corvus.read_sector_128(0x009201)
    print([chr(d) for d in sector])
