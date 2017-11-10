#!/bin/sh
rm -f available.txt
for (( i=1; i<=200; i++ ))
do
    ping -oc 1 -W 2 lnt$i.e-technik.uni-erlangen.de >/dev/null && echo "lnt$i" >> available.txt
done
