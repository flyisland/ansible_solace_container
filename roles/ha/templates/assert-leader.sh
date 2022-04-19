#!/bin/sh

URL="http://127.0.0.1:8080/SEMP"
USER="admin:admin"

INVALID_RESPONSE="__INVALID_RESPONSE__"
SHOW_VERSION="<rpc><show><version/></show></rpc>"
DESCRIPTION_PATH="/rpc-reply/rpc/show/version/description"
ASSERT_ROUTER="<rpc><admin><config-sync><assert-leader><router></router></assert-leader></config-sync></admin></rpc>"
ASSERT_VPN="<rpc><admin><config-sync><assert-leader><vpn-name>*</vpn-name></assert-leader></config-sync></admin></rpc>"
SHOW_CONFIG_SYNC="<rpc><show><config-sync/></show></rpc>"
OPER_STATUS_PATH="/rpc-reply/rpc/show/config-sync/status/oper-status"

log() {
   echo "$(date +'%Y-%m-%d %H:%M:%S') $1"
}

wait_for_startup() {
   local is_started=false
   while [ "$is_started" == false ] ; do
      if [ `curl --write-out '%{http_code}' --silent --output /dev/null -u ${USER} ${URL} -d "${SHOW_VERSION}"` == "200" ] ; then
         is_started=ture
      else
         log "The ${URL} is not responding"
         sleep 10
      fi
   done
}

semp_query() {
   local query="$1"
   local value_search="$2"
   query_response=`curl -sS -u ${USER} ${URL} -d "$query"`
   # Validate first char of response is "<", otherwise no hope of being valid xml
   if [[ ${query_response:0:1} != "<" ]] ; then
      echo "${INVALID_RESPONSE}"
      exit 0
   fi
   if [[ ! -z $value_search ]]; then
      value_result=`echo $query_response | xmllint -xpath "string($value_search)" -`
      echo "${value_result}"
   fi
}

wait_for_config_sync_up() {
   local is_started=false
   local status=""
   while [ "$is_started" == false ] ; do
      status=$(semp_query "${SHOW_CONFIG_SYNC}" "${OPER_STATUS_PATH}")
      log "The Operation status of Config-Synce is ${status}"

      if [ "${status}" == "Up" ] ; then
         is_started=ture
      else
         sleep 10
      fi
   done
}

#    ---------- Main ----------    #
log "Try to perform the 'assert-leader' operation"

# 1. wait until the solace container succesfully started
wait_for_startup
description=$(semp_query "${SHOW_VERSION}" "${DESCRIPTION_PATH}")
log "${description} is running .."

# 2. assert-leader router & message-vpn *
log "admin config-sync assert-leader router"
semp_query "${ASSERT_ROUTER}"
log "admin config-sync assert-leader message-vpn *"
semp_query "${ASSERT_VPN}"

# 3. wait until the oper status of config-sync is Up
wait_for_config_sync_up
