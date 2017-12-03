#!/bin/sh

# CHECK FOR NUMERIC INPUT
die () {
    echo >&2 "$@"
    exit 1
}

[ "$#" -eq 1 ] || die "1 argument required, $# provided"
echo $1 | grep -E -q '^[0-9]+$' || die "Numeric argument required, $1 provided"

# CHECK AVAILABILITY
if grep -q $1 "available.txt"; then
    echo "Server is available!"
else
    echo "This server is not available!"
    exit
fi

# Copy evaluation matlab script to server
sshpass -f 'lntpw' scp /Users/jannismainczyk/thesis/src/matlab/mainczjs/evaluation/evalrun_lnt.m mainczyk@lnt$1.e-technik.uni-erlangen.de:/HOMES/mainczyk/source_tracking_thesis/matlab/mainczjs/evaluation/

# Connect to server and execute matlab script
sshpass -f 'lntpw' ssh mainczyk@lnt$1.e-technik.uni-erlangen.de << ENDHERE
    # execute script
    matlab -nodisplay -nosplash -nodesktop -r "cd('/HOMES/mainczyk/source_tracking_thesis/matlab/mainczjs/evaluation/');run('evalrun_lnt');exit;"
ENDHERE

# fetch data from lnt server
sshpass -f 'lntpw' rsync -avz --remove-source-files mainczyk@lnt$1.e-technik.uni-erlangen.de:'/HOMES/mainczyk/Dropbox/01.\ STUDIUM/10.\ Masterarbeit/src/matlab/mainczjs/evaluation/results/' '/Users/jannismainczyk/thesis/src/matlab/mainczjs/evaluation/results/'
