#!/usr/bin/python
import serial
import serial
import time

macs={}
lastPrint=0
printInterval=30

ser = serial.Serial('/dev/ttyUSB0', 115200)  # open serial port
while True:
    line=ser.readline().strip()
    if len(line)>0:
        print line
        if line[0]!="j":
            macs[line]=time.time()
    if time.time()-lastPrint > printInterval:
        for mac in macs:
            print "{} last seen: {} seconds ago".format(mac, time.time()-macs[mac]) 
        lastPrint=time.time()
ser.close()             # close port
