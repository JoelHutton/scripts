#!/usr/bin/python
#will plot the distance, speed and acceleration of robot

import matplotlib.pyplot as plt
from os import listdir
import time

times=[]
values=[]
#in hours
maxTime=1

fileName = "/var/log/scripts/power_monitor.py" 

output=open(fileName,'r')
power=0
prevTime=0
prevCharge=0
for line in output:
    lineSplit=line.strip().split(',')
    charge=100*(float(lineSplit[6])/float(lineSplit[1]))
    brightness= 100*(float(lineSplit[4])/float(lineSplit[5]))
    t=(float(lineSplit[-1])/(3600))
    deltaCharge=charge-prevCharge
    deltaTime=t-prevTime
    chargeRate=-deltaCharge/deltaTime
    power=-chargeRate
    if((time.time()/3600)-t < maxTime):
        times.append(t)
        values.append([charge,brightness,power,chargeRate])
        prevCharge=charge
        prevTime=t

plt.plot(times,values)
plt.ylabel('%')
plt.xlabel('time')
ax=plt.gca()
ax.set_ylim([0,100])
ax.set_autoscaley_on(False)
plt.show()
