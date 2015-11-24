#!/bin/bash

contains() {
	RES=$(echo "$1" | grep "$2")
	if [ -z "$RES" ]; then return 1; else return 0; fi
}

request() {
	resp=$(curl -w "\n%{time_total}\n" $1  "$2")
	echo "$resp" | tail -1 > rt.txt
	echo "$resp" | head -1
}

post() {
	request -XPOST $1
}

get() {
	request -XGET $1
}

enqueue_lib() {
	JSON=$(post "http://www.methodscount.com/api/request/$1")
	return $(contains "$JSON" '"enqueued":true')
}

lib_status() {
	JSON=$(get "http://www.methodscount.com/api/stats/$1")
	contains "$JSON" '"status":"done"' && echo "done"
	contains "$JSON" '"status":"processing"' && echo "processing"
	contains "$JSON" '"status":"error"' && echo "error"
	contains "$JSON" '"status":"undefined"' && echo "undefined"
}

background_lib_check() {
	status=$(lib_status $1)
	end=$((SECONDS+300)) # stop after 5 minutes
	while [ "processing" == "$status" -a $SECONDS -lt $end ];
	do
		sleep 5
		status=$(lib_status $1)
	done

	echo $1 $status >> statuses.txt
}



while read lib; do
	echo $lib
	enqueue_lib "$lib" && background_lib_check "$lib" & 
	sleep 10
done < $1 

