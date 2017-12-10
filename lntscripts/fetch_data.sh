#!/bin/sh

# fetch data from lnt server
sshpass -f 'lntpw' rsync -avz --remove-source-files --exclude=config*.mat --exclude=raw/** mainczyk@lnt94.e-technik.uni-erlangen.de:'/HOMES/mainczyk/thesis/src/src/matlab/mainczjs/evaluation/results/' '/Users/jannismainczyk/thesis/src/matlab/mainczjs/evaluation/results/'

#--exclude=config*.mat --exclude=raw/**
