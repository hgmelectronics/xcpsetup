#!/bin/bash
ARGS="-d elm327:/dev/ttyUSB0?debuglog=stdout -T ebus-ibem -i 0 -s data/ibem1114.pkl -D -r 1 testibemf.json"
ITER=0
FAIL=0
while [ 1 ] ; do
	if ! ./write_struct.py $ARGS >> write_struct-cycle.log 2>&1; then
		tail -n 20 write_struct-cycle.log
		FAIL=$(($FAIL+1))
	fi
	ITER=$(($ITER+1))
	echo $FAIL/$ITER
done
