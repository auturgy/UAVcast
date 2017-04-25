# UAVcast

Complete Drone casting software for Raspberry PI in conjuction with 3G / 4G or WiFi. Can be used with Ardupilot or Navio boards (Emlid.com)

Discussion forum thread
[UAVcast. Casting software for Raspberry PI. Supports 3G / 4G / WiFi](http://uavmatrix.com/viewpost/5/110/741/0/Raspberry-Pi/UAVcast.-Casting-software-for-Raspberry-PI.-Supports-3G-/-4G-/-WiFi.)


[![UAVcast get started](https://img.youtube.com/vi/bz7Jlo1rRl0/0.jpg)](https://www.youtube.com/watch?v=bz7Jlo1rRl0)


### Installation

```
sudo apt-get install git
sudo git clone https://github.com/UAVmatrix/UAVcast.git
cd UAVcast/install
sudo ./install.sh
```

##How it works
UAVcast uses regular software such as wvdial, inadyn. gstreamer, uqmi, and will fire up each program in the correct order users has defined in the DroneConfig.cfg file. 
 
After you have successfully installed UAVcast and edited DroneConfig, you could simply start UAVcast by running ``` ./DroneStart.sh ``` or ``` sudo systemctl start UAVcast ```
If there is any problems during startup, then please check the logfile located in the ```UAVcast/log ``` category.
 
 
##Configuration
 
``` 
UAVcast/DroneConfig.cfg

This file conatins the configuration parameters for UAVcast scripts. Simply set your desired options and save the file.
 
###################################################################################################################
#                                                 UAVcast for Drones                                              #
#  This script package will start various programs defined in this config file to simplify the startup proccess.  #
#  Create by Bernt Christian Egeland. Further information can be found at                                         #             
#  http://uavmatrix.com/d/5110-UAVcast-Casting-software-for-Raspberry-PI-Supports-3G-4G-WiFi                      #
###################################################################################################################
 
 
#All parameters are Case Sensistive. Please type carefully.
#Do not comment out any paramters, as they are essential for the UAVcast proccess. Just change the parameter with the option value.
 
#FlightController type. Arguments; Navio, APM(Any Ardupilot boards such as APM2,x  Pixhawk)
Cntrl="Navio"
 
#Set your telemetry connection. Options:: (gpio, ttl)  // gpio = pin 8_tx & 10_rx. ttl = ttl_Ethernet converter.
Telemetry_Type="gpio"

#GCS_adress; Set your DynDns or IP of Ground Control Station.
GCS_address="10.0.0.212"
 
#Ground Control Station Telemetry Port APM or Navio should start streaming to.
#NOTE! You need to open this port on your GCS network.
PORT="14550"
 
#Options; uqmi, wvdial, Ethernet
GSM_Connect="Ethernet"
 
#wvdial configuration. These are standard values, and should not be changed.
#However, some operators uses diffrent Phone number and credentials. 
wv_Phone="*99#"
wv_Modem="/dev/ttyUSB0"
wv_Username="{test}"
wv_Password="{test}"
wv_Baud="460800"
 
#Access Point Name given by your operator. Make sure you use a APN with public ip.
#Set your Cell operators APN name. Example, Telenor Norway use "internet.public"
APN_name="internet.public"
 
#Use WebCamera?. Options; Yes, No
UseCam="Yes"
 
#Options; picam, C920, C615
CameraType="picam"
 
#gStreamer Settings.
WIDTH="1280"
HEIGHT="720"
UDP_PORT="5000"
BITRATE="1500000"
FPS="20"
 
#Use Inadyn DynDNS Client?
UseDns="No"
Username=""
Password=""
Alias=""
dyndns_system="default@no-ip.com"
 
#Run continuously DroneCheck. If Online connection fails, it will try to reconnect. Options; "Yes", "No"
DroneCheck="No"
 
##############################################
#Navio Boards ONLY. Used if Cntrl="Navio"    #
##############################################
 
#Args; APMrover2, ArduPlane, ArduCopter-quad,ArduCopter-tri, ArduCopter-hexa, ArduCopter-y6, ArduCopter-octa, ArduCopter-octa-quad, ArduCopter-heli, ArduCopter-single
APM_type="ArduPlane"
 
#Use secondary telemetry?  Options; Yes, No 
secondary_tele="Yes"
sec_ip_address="10.0.0.211"
sec_port="14550"
```

##UAVcast Usage

```
Start
sudo systemctl start UAVcast

Stop
sudo systemctl stop UAVcast

Restart
sudo systemctl restart UAVcast

Start on boot 
sudo systemctl enable UAVcast

Not run on boot (for troubleshooting or other tasks)
sudo systemctl disable UAVcast

```
 
###Video
If you are using UAVcast with camera, its highly recommended to use gstreamer on the receiver end to achieve minimal latency.
Download [gstreamer](https://gstreamer.freedesktop.org/download/)

Use this client pipeline to receive video feed from UAVcast.
``` 
gst-launch-1.0.exe -e -v udpsrc port=5000 ! application/x-rtp, payload=96 ! rtpjitterbuffer ! rtph264depay ! avdec_h264 ! fpsdisplaysink sync=false text-overlay=false 
```

##Troubleshooting

Start ```UAVcast/DroneStart.sh ``` if you want a more verbose output of what exactly going on when UAVcast is started.
Also check the logfiles located in the /UAVcast/log folder.


If you are using PiCam, remember to enable the camera in ```Raspi-Config```


## Authors

* **Bernt Christian Egeland** - *creator and founder of UAVmatrix.com* - (http://uavmatrix.com)
