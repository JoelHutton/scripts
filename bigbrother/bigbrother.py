#!/usr/bin/python
import subprocess
import serial
import time
import datetime
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
longest_name=0

def monitor():
    global serial_device
    global macs
    global last_load
    global longest_name
    started=time.time()
    lastPrint=0
    printInterval=10
    mac_timeout=300
    known_macs_file=open('/tmp/known','r').readlines()
    known_macs={}
    for line in known_macs_file:
        line=line.strip().split(' ',1)
        known_macs[line[0]]=line[1]
        if len(line[1])>longest_name:longest_name=len(line[1])
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
            printstrs=[]
            for mac in known_macs:
                total_seconds=0
                last_seen=0
                if mac in macs:
                    last_seen=macs[mac]
                total_seconds=int(time.time()-last_seen)
                seconds=str(total_seconds%60)
                minutes=str((total_seconds/60)%60)
                hours=str((total_seconds/3600)%24)
                days=str(total_seconds/(3600*24))
                if len(seconds)==1:seconds="0"+seconds
                if len(minutes)==1:minutes="0"+minutes
                if len(hours)==1:hours="0"+hours
                if len(days)==1:days="0"+days
                formatted_time=datetime.datetime.fromtimestamp(last_seen).strftime('%Y-%m-%d %H:%M:%S')
                padding= " "*(longest_name-(len(known_macs[mac])))
                printstrs.append((last_seen,"{} {}last seen: {} days {}:{}:{} ago at {}".format(known_macs[mac], padding, days, hours, minutes, seconds, formatted_time))) 
            for p in sorted(printstrs):
                print p[1]
                tmp_file.write(p[1]+"\n")
            time_since_start=int(time.time()-started)
            days=(time_since_start/(3600*24))
            hours=(time_since_start/3600)%24
            minutes=((time_since_start/60)%60)
            seconds=(time_since_start%60)
            uptime="uptime is {} days {}:{}:{}".format(days, hours, minutes, seconds)
            busyness="busyness index is {}".format(len(macs))
            print busyness
            print uptime
            tmp_file.write(busyness+"\n")
            tmp_file.write(uptime+"\n")
            print "\n"
            lastPrint=time.time()
            tmp_file.close()
        if time.time()-last_load>load_time:
            known_macs_file=open('/tmp/known','r').readlines()
            known_macs={}
            for line in known_macs_file:
                line=line.strip().split(' ',1)
                known_macs[line[0]]=line[1]
                if len(line[1])>longest_name:longest_name=len(line[1])
            last_load=time.time()

if __name__=='__main__':
    monitor()
ser.close()
