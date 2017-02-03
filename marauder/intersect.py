#!/usr/bin/python

#files=['baseline','fh','secure_programming_lecture','secure_programming_2']

baseline=open('baseline','r').readlines()[1:]
fh=open('fh','r').readlines()[1:]
for line in baseline:
    if line not in fh:
        print line
