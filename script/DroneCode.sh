#!/bin/bash
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $DIR/../DroneConfig.cfg
function DroneInit {
case $GSM_Connect in
	"other")
	 ip="$(ifconfig | grep -A 1 'eth0' | tail -1 | cut -d ':' -f 2 | cut -d ' ' -f 1)"
	 echo "Ethernet ip is $ip"
	 StartBroadcast
	;;
	"uqmi")
		 if ps ax | grep -v grep | grep $GSM_Connect > /dev/null
			then
				echo "$GSM_Connect service running"
				StartBroadcast
			else
				echo "$GSM_Connect is not running"
				echo "Trying to start UQMI"
				uqmi
				sleep 5
				StartBroadcast
		 fi
	;;
	"wvdial")	
			wvdial
			sleep 5
			StartBroadcast
	;;
esac
}

function StartBroadcast {
ping -q -w 1 -c 1 `ip r | grep default | cut -d ' ' -f 3` > /dev/null && echo Seems like RPI is connected to Internet, all ok. || echo Seems like your RPI does not have internet connection. Trying to continue anyway.
		   	pidof inadyn >/dev/null
				 if [[ $? -ne 0 ]] ; then 
				 inadyn
				 fi
			case $Cntrl in
				"APM")
			       	Telemetry_Type
					gstreamer
			    ;;
			    "Navio")
					 gstreamer
					 ArduPilot
			   	;;
			esac
	
 }

function Telemetry_Type {
if [ $Telemetry_Type == "ttl" ]; then
pidof udp_redirect >/dev/null
    	if [[ $? -ne 0 ]] ; then  
			sudo $DIR/./udp-send.sh > $DIR/../log/Telemetry_Type.log 2>&1 & 
			sleep 0.3
			pidof udp_redirect >/dev/null
			sleep 0.3
				if [[ $? -eq 0 ]] ; then 
					echo 'UDP_redirect script started'
					return 1
					else
					echo 'Another UDP_redirect process already running'
				fi
				return 0
		else
	    echo "Another udp_redirect process already running"
        fi
elif [ $Telemetry_Type == "gpio" ]; then
		pidof ser2net >/dev/null
    	if [[ $? -ne 0 ]] ; then  
			sudo $DIR/./ser2net.sh > $DIR/../log/Telemetry_Type.log 2>&1 & 
			sleep 0.3
			pidof ser2net >/dev/null
			sleep 0.3
				if [[ $? -eq 0 ]] ; then 
					echo 'ser2net script started'
					return 1
					else
					echo 'Another ser2net process already running'
				fi
				return 0
		else
	    echo "Another ser2net process already running"
       fi
fi

}
function gstreamer {
if [ $UseCam == "Yes" ]; then
pidof gst-launch-1.0 >/dev/null
	if [[ $? -ne 0 ]] ; then 
		sudo $DIR/./camera.sh > $DIR/../log/gstreamer.log 2>&1 & 
		sleep 5
		pidof gst-launch-1.0 >/dev/null
			if [[ $? -eq 0 ]] ; then
					echo "gStreamer Started"
			else
			echo 'Could`t start gStreamer'
			fi
	else
	echo "Another gStreamer process already running"
	fi
fi
}

function uqmi {
sudo uqmi -d /dev/cdc-wdm0 --stop-network 4294967295 --autoconnect
sleep 2
    if ! sudo uqmi -s -d /dev/cdc-wdm0 --get-data-status | grep '"connected"' > /dev/null; then
		sudo uqmi -d /dev/cdc-wdm0 --stop-network 4294967295 --autoconnect
		sleep 2
		sudo uqmi -d /dev/cdc-wdm0 --network-register
		echo network register
		sleep 3
		echo Connecting 4G
			sudo uqmi -s -d /dev/cdc-wdm0 --start-network $APN_name --keep-client-id wds --autoconnect &
		sleep 15
		if ! sudo uqmi -s -d /dev/cdc-wdm0 --get-data-status | grep '"connected"' > /dev/null; then
			echo "GSM Not Connected!"
		else
			echo "GSM Connected"
			sudo dhclient -v wwan0
	fi
	else
		echo "UQMI is already connected to internet."
	fi
	}
function wvdial {
FILE="$DIR/./wvdial.conf"
/bin/cat <<EOM >$FILE
[Dialer Defaults]
Init1 = $wv_init1
Init2 = $wv_init2
Init3 = $wv_init3 ,"IP", "$APN_name"
Stupid Mode = 1
Carrier Check = $wv_carrier_check
MessageEndPoint = "0x01"
Modem Type = Analog Modem
ISDN = 0
Phone = $wv_Phone
Modem = $wv_Modem
Username = $wv_Username
Password = $wv_Password
Baud = $wv_Baud
Auto Reconnect = $wv_Auto_Reconnect
EOM
   if ps ax | grep -v grep | grep $GSM_Connect > /dev/null
			then
				echo "$GSM_Connect service running"
			else
				echo "$GSM_Connect not running. We will start it"
				sudo wvdial -C $DIR/./wvdial.conf > $DIR/../log/wvdial.log 2>&1 & 
				sleep 20
				  if ps ax | grep -v grep | grep $GSM_Connect > /dev/null
				      then
				      echo "$GSM_Connect successfully started"
					  rm $FILE
				  else 
				      echo "could not start $GSM_Connect"
			      fi
	 fi
	}
function inadyn {
if [ $UseDns == "Yes" ]; then
   sleep 1
	   if ps ax | grep -v grep | grep inadyn > /dev/null
				then
					echo "inadyn service running"
				else
					echo "Trying to start inadyn"
					sudo  inadyn --username $Username --password $Password --update_period_sec 600 --alias $Alias --dyndns_system $dyndns_system > $DIR/../log/inadyn.log 2>&1 & 
					sleep 1
					  if ps ax | grep -v grep | grep inadyn > /dev/null
						  then
						  echo "inadyn successfully started"
					  else 
						  echo "could not start inadyn"
					  fi
		     fi
	fi
	} 
function ArduPilot {
pidof $APM_type > /dev/null
	if [[ $? -ne 0 ]] ; then
		sudo $DIR/./Ardupilot.sh > $DIR/../log/Ardupilot.log 2>&1 & 
		sleep 5
		pidof $APM_type >/dev/null
			if [[ $? -eq 0 ]] ; then
			echo "APM started"
			else
			echo 'could`t start ArduPilot'
			fi
	else
		echo "APM already running"
	fi
}

