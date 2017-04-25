#!/bin/bash
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $DIR/../DroneConfig.cfg
if [[ $GCS_address =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]];
 then
    ip=$GCS_address
  else
  ip=`dig +short $GCS_address`
fi
echo $GCS_address
echo APM starting:: stream adress: $ip
if [ $secondary_tele == "Yes" ]; then
echo Using Secondary telemetry $sec_ip_address : $sec_port
sudo $APM_type -A udp:$ip:$PORT -C udp:$sec_ip_address:$sec_port
else
sudo $APM_type -A udp:$ip:$PORT
fi
