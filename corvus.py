#!/usr/bin/env python

import u3

class Corvus(object):
    DATA_LINES = (u3.EIO0, u3.EIO1, u3.EIO2, u3.EIO3,
                  u3.EIO4, u3.EIO5, u3.EIO6, u3.EIO7)

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

        # configure timers
        # fio4: timer 0 (frequency out)
        # fio5: timer 1 (timer stop)
        # connect /strobe to fio4 and fio5
        self._labjack.configIO(TimerCounterPinOffset=4,
                               NumberOfTimersEnabled=2)

        # use 48 MHz timer clock
        cmd = self._labjack.configTimerClock(u3.LJ_tc48MHZ_DIV, 1)
        self._labjack.getFeedback(cmd)

    def strobe(self):
        # set timer 1 mode as timer stop.  this will stop timer 0 after a
        # single pulse (Value=1).  this must be done before starting timer 0
        # or else it will be too late to stop the pulses.
        cmd = u3.Timer1Config(TimerMode=u3.LJ_tmTIMERSTOP, Value=1)
        self._labjack.getFeedback(cmd)

        # set timer 0 mode as frequency out.  this will start immediately
        # after the command is sent.  it should output one pulse (the line is
        # normally high and will be pulled low temporarily) and then be
        # stopped by timer 1.
        cmd = u3.Timer0Config(TimerMode=u3.LJ_tmFREQOUT, Value=0)
        self._labjack.getFeedback(cmd)

    def is_drive_ready(self):
        return self._labjack.getDIState(u3.FIO6) == 1

    def is_host_to_drive(self):
        return self._labjack.getDIState(u3.FIO7) == 1

    def connect_data_bus(self):
        # set pins as input
        for line in self.DATA_LINES:
            self._labjack.getDIState(line)

        # set /oe on 74hct245 to low to connect
        self._labjack.setDOState(u3.FIO0, 0)

    def disconnect_data_bus(self):
        # set /oe on 74hct245 to high to disconnect
        self._labjack.setDOState(u3.FIO0, 1)

        # set pins as input
        for line in self.DATA_LINES:
            self._labjack.getDIState(line)

    def read_data(self):
        while not(self.is_drive_ready()):
            pass

        # set pins as input
        for line in self.DATA_LINES:
            self._labjack.getDIState(line)

        self.connect_data_bus()

        # lines must already be configured as input
        # read each line to build the byte
        value = 0
        for bit, line in enumerate(self.DATA_LINES):
            if self._labjack.getDIState(line) == 1:
                value |= 2**bit

        self.strobe()
        self.disconnect_data_bus()

        return value

    def write_data(self, value):
        while not(self.is_drive_ready()):
            pass

        # turn on lines for bits that are high
        self.connect_data_bus()
        for bit, line in enumerate(self.DATA_LINES):
            state = int((value & 2**bit) != 0)
            self._labjack.setDOState(line, state)
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


if __name__ == "__main__":
    corvus = Corvus()
    corvus.init_drive()
