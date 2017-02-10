#!/usr/bin/python
import subprocess
import serial
import time
import sys

macs={}
subprocess.call('ls /dev/ttyU*', shell=True)
serial_device=raw_input('serial device:')
people=raw_input("who is here? seperate by commas, negate with ! :")
output_file=open(raw_input('output filename:'),'w')
listen_time=raw_input('time to listen for (default 500s):').strip()
is_digits=True
if len(listen_time)==0:
    listen_time=500
else:
    for char in listen_time:
        if not(char.isdigit()):
            is_digits=False
if is_digits:
    listen_time=int(listen_time)
else:
    listen_time=500
start_time=time.time()

def monitor():
    global serial_device
    global macs
    lastPrint=0
    printInterval=10
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
            print "\n\n"
            lastPrint=time.time()
            print "sniffing for {}, {} left".format(time.time()-start_time, listen_time-(time.time()-start_time))
        if time.time()-start_time>listen_time:
            dump()
            ser.close()
            sys.exit(0)

def dump():
    print "dumping to file..."
    output_file.write(people)
    output_file.write("\n")
    for mac in macs:
        output_file.write(mac)
        output_file.write("\n")
    output_file.close()


if __name__=='__main__':
    monitor()
ser.close()
