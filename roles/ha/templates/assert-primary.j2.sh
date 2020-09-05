#!/bin/sh

for ((i=1;i<=10;i++))
do
   echo "$(date +'%Y-%m-%d %H:%M:%S') Asserting master ..."
   status_code=$(curl --write-out %{http_code} --silent --output /dev/null http://127.0.0.1:8080/SEMP -u admin:admin -H 'content-type: application/json' -d '<rpc semp-version="soltr/8_10VMR"><admin><config-sync><assert-master><router></router></assert-master></config-sync></admin></rpc>')
   res=$?
   echo "curl returns $res, status_code:$status_code"
   if test "$status_code" == "200"; then
      break
   fi
   sleep 1m
done
