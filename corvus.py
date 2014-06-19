#!/usr/bin/env python

import LabJackPython
import u3

dev = u3.U3()

# fio4: timer 0 (frequency out)
# fio5: timer 1 (timer stop)
# a wire must be connected between fio4 and fio5
dev.configIO(TimerCounterPinOffset=4,
             NumberOfTimersEnabled=2)

# use 48 MHz timer clock
cmd = dev.configTimerClock(LabJackPython.LJ_tc48MHZ_DIV, 1)
dev.getFeedback(cmd)

# Generate a single pulse of ~5 microseconds on FIO4.

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
