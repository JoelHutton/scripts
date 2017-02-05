#!/usr/bin/python
import subprocess
import serial
import time
import sys

macs={}
subprocess.call('ls /dev/ttyU*', shell=True)
subprocess.call('touch /tmp/presence', shell=True)
subprocess.call('chmod 755 /tmp/presence', shell=True)
subprocess.call('cp known_macs /tmp/known', shell=True)
subprocess.call('chmod 700 /tmp/known', shell=True)
#serial_device=raw_input('serial device:')
serial_device='/dev/ttyUSB0'
last_load=time.time()
load_time=30

def monitor():
    global serial_device
    global macs
    global last_load
    lastPrint=0
    printInterval=10
    mac_timeout=300
    known_macs_file=open('/tmp/known','r').readlines()
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
            tmp_file=open('/tmp/presence','w')
            for mac in macs:
                if time.time()-macs[mac] > mac_timeout and mac not in known_macs:
                    macs_to_delete.append(mac)
            for mac in macs_to_delete:
                del macs[mac]
            for mac in known_macs:
                if mac in macs:
                    total_seconds=int(time.time()-macs[mac])
                    seconds=total_seconds%60
                    minutes=(total_seconds/60)%60
                    hours=(total_seconds/3600)
                    formatted_time=datetime.datetime.fromtimestamp(known_macs[mac]).strftime('%Y-%m-%d %H:%M:%S')
                    printstr="{} last seen: {}:{}:{} ago at {}".format(known_macs[mac], hours, minutes, seconds) 
                    print printstr
                    tmp_file.write(printstr+"\n")
            print "busyness index is {}".format(len(macs))
            tmp_file.write("busyness index is {}\n".format(len(macs)))
            print "\n"
            lastPrint=time.time()
            tmp_file.close()
        if time.time()-last_load>load_time:
            known_macs_file=open('/tmp/known','r').readlines()
            known_macs={}
            for line in known_macs_file:
                line=line.strip().split(' ',1)
                known_macs[line[0]]=line[1]
            last_load=time.time()

if __name__=='__main__':
    monitor()
ser.close()
