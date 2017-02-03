#!/usr/bin/python
import subprocess
import serial
import time
import sys

macs={}
subprocess.call('ls /dev/ttyU*', shell=True)
serial_device=raw_input('serial device:')

def monitor():
    global serial_device
    global macs
    lastPrint=0
    printInterval=10
    mac_timeout=600
    known_macs_file=open('known_macs','r').readlines()
    known_macs={}
    for line in known_macs_file:
        line=line.strip().split(' ',1)
        known_macs[line[0]]=line[1]
    ser = serial.Serial(serial_device, 115200)  # open serial port
    while True:
        line=ser.readline().strip()
        if len(line)>0:
            if line[0]!="j":
                macs[line]=time.time()
        if time.time()-lastPrint > printInterval:
            for mac in macs:
                if mac in known_macs:
                    print "{} last seen: {} seconds ago".format(known_macs[mac], time.time()-macs[mac]) 
                else:
                    print "{} last seen: {} seconds ago".format(mac, time.time()-macs[mac]) 
                if time.time()-macs[mac]>mac_timeout:
                    del macs[mac]
            print "\n\n"
            lastPrint=time.time()

if __name__=='__main__':
    monitor()
ser.close()
