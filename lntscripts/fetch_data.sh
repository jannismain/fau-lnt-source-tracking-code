#!/bin/sh

# CHECK FOR NUMERIC INPUT
die () {
    echo >&2 "$@"
    exit 1
}

[ "$#" -eq 1 ] || die "1 argument required, $# provided"
echo $1 | grep -E -q '^[0-9]+$' || die "Numeric argument required, $1 provided"

# fetch data from lnt server
sshpass -f 'lntpw' rsync -avz --remove-source-files mainczyk@lnt$1.e-technik.uni-erlangen.de:'/HOMES/mainczyk/Dropbox/01.\ STUDIUM/10.\ Masterarbeit/src/matlab/mainczjs/evaluation/results/' '/Users/jannismainczyk/thesis/src/matlab/mainczjs/evaluation/results/'
