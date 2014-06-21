#!/usr/bin/env python

import LabJackPython
import u3


def setup(dev):
    # configure inputs
    dev.getDIState(u3.FIO3)  # /reset
    dev.getDIState(u3.FIO6)  # ready
    dev.getDIState(u3.FIO7)  # dirc

    # configure outputs
    dev.setDOState(u3.FIO0, 1)  # 74hct245 /oe for corvus data bus

    # configure timers
    # fio4: timer 0 (frequency out)
    # fio5: timer 1 (timer stop)
    # connect /strobe to fio4 and fio5
    dev.configIO(TimerCounterPinOffset=4,
                 NumberOfTimersEnabled=2)

    # use 48 MHz timer clock
    cmd = dev.configTimerClock(LabJackPython.LJ_tc48MHZ_DIV, 1)
    dev.getFeedback(cmd)

def strobe(dev):
    # set timer 1 mode as timer stop.  this will stop timer 0 after a
    # single pulse (Value=1).  this must be done before starting timer 0
    # or else it will be too late to stop the pulses.
    cmd = u3.Timer1Config(TimerMode=LabJackPython.LJ_tmTIMERSTOP, Value=1)
    dev.getFeedback(cmd)

    # set timer 0 mode as frequency out.  this will start immediately after
    # the command is sent.  it should output one pulse (the line is normally
    # high and will be pulled low temporarily) and then be stopped by timer 1.
    cmd = u3.Timer0Config(TimerMode=LabJackPython.LJ_tmFREQOUT, Value=0)
    dev.getFeedback(cmd)

def is_drive_ready(dev):
    return dev.getDIState(u3.FIO6) == 1

def is_host_to_drive(dev):
    return dev.getDIState(u3.FIO7) == 1

DATA_LINES = (u3.EIO0, u3.EIO1, u3.EIO2, u3.EIO3,
              u3.EIO4, u3.EIO5, u3.EIO6, u3.EIO7)

def connect_data_bus(dev):
    # set pins as input
    for line in DATA_LINES:
        dev.getDIState(line)

    # set /oe on 74hct245 to low to connect
    dev.setDOState(u3.FIO0, 0)

def disconnect_data_bus(dev):
    # set /oe on 74hct245 to high to disconnect
    dev.setDOState(u3.FIO0, 1)

    # set pins as input
    for line in DATA_LINES:
        dev.getDIState(line)

def read_data(dev):
    # lines must already be configured as input
    # read each line to build the byte
    value = 0
    for bit, line in enumerate(DATA_LINES):
        if dev.getDIState(line) == 1:
            value |= 2**bit
    return value

def write_data(dev, value):
    # set pins as output low
    for line in DATA_LINES:
        dev.setDOState(line, 0)

    # turn on lines for bits that are high
    for bit, line in enumerate(DATA_LINES):
        if (value & 2**bit) != 0:
            dev.setDOState(line, 1)


if __name__ == "__main__":
    dev = u3.U3()
    setup(dev)

    for i in range(100):
        while not(is_drive_ready(dev)):
          pass
        print("drive is ready")

        while not(is_host_to_drive(dev)):
          pass
        print("direction is host-to-drive")

        connect_data_bus(dev)
        value = 0xff # 0xff is an invalid command
        write_data(dev, value)
        print("wrote %02x" % value)
        strobe(dev)
        print("strobe")
        disconnect_data_bus(dev)

        while not(is_drive_ready(dev)):
          pass
        print("drive is ready")

        while is_host_to_drive(dev):
          pass
        print("direction is drive-to-host")

        connect_data_bus(dev)
        value = read_data(dev) # should return 0x8f (invalid command)
        print("read %02x" % value)
        strobe(dev)
        print("strobe")
        disconnect_data_bus(dev)
