#!/bin/bash
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $DIR/../DroneConfig.cfg
if [[ $GCS_address =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]];
 then
    ip=$GCS_address
  else
  ip=`dig +short $GCS_address`
fi
FILE="$DIR/./ser2net.conf"
/bin/cat <<EOM >$FILE
udp,$PORT:raw:300:/dev/ttyAMA0:57600 remaddr=ipv4,udp,$ip,$PORT
EOM
sleep 1.5
sudo ser2net -c $DIR/./ser2net.conf > $DIR/../log/ser2net.log 2>&1 &
