#!/bin/sh

# Copy evaluation matlab script to server
sshpass -f 'lntpw' scp /Users/jannismainczyk/thesis/src/matlab/mainczjs/evaluation/evalrun_lnt.m mainczyk@lnt94.e-technik.uni-erlangen.de:/HOMES/mainczyk/source_tracking_thesis/matlab/mainczjs/evaluation/

# Connect to server and execute matlab script
sshpass -f 'lntpw' ssh mainczyk@lnt94.e-technik.uni-erlangen.de << ENDHERE
    # execute script
    matlab -nodisplay -nosplash -nodesktop -r "cd('/HOMES/mainczyk/source_tracking_thesis/matlab/mainczjs/evaluation/');run('evalrun_lnt');exit;"
ENDHERE

# fetch data from lnt server
sshpass -f 'lntpw' rsync -avz --remove-source-files mainczyk@lnt94.e-technik.uni-erlangen.de:'/HOMES/mainczyk/Dropbox/01.\ STUDIUM/10.\ Masterarbeit/src/matlab/mainczjs/evaluation/results/' '/Users/jannismainczyk/thesis/src/matlab/mainczjs/evaluation/results/'
