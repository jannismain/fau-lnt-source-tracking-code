#!/bin/sh

# fetch data from lnt server
sshpass -f 'lntpw' rsync -avz --exclude=config*.mat --exclude=raw/** --remove-source-files mainczyk@lnt94.e-technik.uni-erlangen.de:'/HOMES/mainczyk/Dropbox/01.\ STUDIUM/10.\ Masterarbeit/src/matlab/mainczjs/evaluation/results/' '/Users/jannismainczyk/thesis/src/matlab/mainczjs/evaluation/results/'
