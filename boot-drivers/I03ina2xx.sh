#! /bin/sh
if lsmod | grep ina2xx &> /dev/null ; then
  if [ "$1" == "-r" ]; then
    echo 0x40 > /sys/bus/i2c/devices/i2c-1/delete_device 
    sed -i "s|INA2XXPATH=.*|INA2XXPATH='unset'|g" /etc/profile        
    modprobe -r ina2xx
  else
    echo "ina2xx is loaded!"
    exit 0
  fi
else
    modprobe ina2xx && echo ina219 0x40 > /sys/bus/i2c/devices/i2c-1/new_device
    # paths:
    # /sys/bus/i2c/devices/1-0040/in0_input
    # /sys/bus/i2c/devices/1-0040/in1_input
    # /sys/bus/i2c/devices/1-0040/power1_input
    #driverpath=$(find /sys/bus/i2c/devices/1-0040/ -type d -name 'iio:device*')
    #sed -i "s|INA2XXPATH=.*|INA2XXPATH='$driverpath'|g" /etc/profile        
fi
