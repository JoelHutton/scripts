#!/usr/bin/python
import time
metrics=[
'/sys/class/power_supply/BAT0/capacity'
,'/sys/class/power_supply/BAT0/charge_full'
,'/sys/class/power_supply/BAT0/charge_full_design'
,'/sys/class/power_supply/AC/online'
,'/sys/class/backlight/intel_backlight/brightness'
,'/sys/class/backlight/intel_backlight/max_brightness'
,'/sys/class/power_supply/BAT0/charge_now']
values=[]
for i in range(0,len(metrics)+1):
    values.append('')

while True:
    logFile=open('/var/log/scripts/power_monitor.py','a')
    i=0
    changed=False
    for i in range(0,len(metrics)):
        metric=metrics[i]
        metricFile=open(metric,'r')
        for line in metricFile:
            if line.strip()!=values[i]:
                values[i]=line.strip()
                changed=True
            break
        i+=1
    if changed:
        values[-1]=time.time()
        writeString=''
        for i in range(len(values)):
            writeString += str(values[i])
            if i != len(values)-1:
                writeString += ','
        print writeString
        logFile.write(writeString)
        logFile.write('\n')
    logFile.close() 
    time.sleep(10)

