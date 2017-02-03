#!/usr/bin/python

import sqlite3
import signal
import sys
import time

record_file=open('./log','w')
def signal_handler(signal, frame):
        print('exitting')
        conn.close()
        record_file.close()
        sys.exit(0)

signal.signal(signal.SIGINT, signal_handler)

conn = sqlite3.connect('battery.db')

while True:
    battery_current=open('/sys/class/power_supply/BAT0/current_now','r')
    line=battery_current.readline()
    battery_current.close()
    print line
    record_file.write(line)
    time.sleep(1)
