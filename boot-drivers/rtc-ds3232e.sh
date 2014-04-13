#! /bin/sh
# https://unix.stackexchange.com/questions/98038/restrictions-of-etc-profile-in-gnome
if lsmod | grep rtc-ds3232 &> /dev/null ; then
  if [ "$1" == "-r" ]; then
    echo 0x23 > /sys/bus/i2c/devices/i2c-1/delete_device
    sed -i "s|RTCDS3232PATH=.*|RTCDS3232PATH='unset'|g" /etc/profile        
    modprobe -r rtc-ds3232
    exit 0
  else
    echo "rtc-ds3232 is loaded!"
    exit 0
  fi
else
  # Realtime clock
  if modprobe rtc-ds3232; then
    echo ds3232 0x68 > /sys/bus/i2c/devices/i2c-1/new_device
    driverpath=$(find /sys/bus/i2c/devices/1-0068/ -type d -name 'iio:device*')
    sed -i "s|RTCDS3232PATH=.*|RTCDS3232PATH='$driverpath'|g" /etc/profile        
    export RTCDS3232PATH="$driverpath"
    exit 1 # not sure if driver was loading correctly
  fi
fi
