#!/usr/bin/python
import subprocess
import serial
import time
import sys

macs={}
subprocess.call('ls /dev/ttyU*', shell=True)
subprocess.call('touch /tmp/prescence', shell=True)
subprocess.call('chmod 777 /tmp/prescence', shell=True)
serial_device=raw_input('serial device:')

def monitor():
    global serial_device
    global macs
    lastPrint=0
    printInterval=10
    mac_timeout=300
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
            macs_to_delete=[]
            tmp_file=open('/tmp/prescence','w')
            for mac in macs:
                if time.time()-macs[mac] > mac_timeout and mac not in known_macs:
                    macs_to_delete.append(mac)
            for mac in macs_to_delete:
                del macs[mac]
            for mac in known_macs:
                if mac in macs:
                    print "{} last seen: {} seconds ago".format(known_macs[mac], time.time()-macs[mac]) 
                    tmp_file.write("{} last seen: {} seconds ago\n".format(known_macs[mac], time.time()-macs[mac]))
            print "busyness index is {}".format(len(macs))
            tmp_file.write("busyness index is {}\n".format(len(macs)))
            print "\n"
            lastPrint=time.time()
            tmp_file.close()

if __name__=='__main__':
    monitor()
ser.close()
