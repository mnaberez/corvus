#!/usr/bin/env python

import LabJackPython
import u3


def setup(dev):
    # configure inputs
    dev.getDIState(u3.FIO3)  # /reset
    dev.getDIState(u3.FIO6)  # ready
    dev.getDIState(u3.FIO7)  # dirc

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

        strobe(dev)
        print("strobe")

        while not(is_drive_ready(dev)):
          pass
        print("drive is ready")

        while is_host_to_drive(dev):
          pass
        print("direction is drive-to-host")

        strobe(dev)
        print("strobe")
