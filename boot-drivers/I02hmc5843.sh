#! /bin/sh
if lsmod | grep "hmc5843" &> /dev/null ; then
  if [ "$1" == "-r" ]; then
    echo 0x1e > /sys/bus/i2c/devices/i2c-1/delete_device
    sed -i "s|HMC5843PATH=.*|HMC5843PATH='unset'|g" /etc/profile
    modprobe -r hmc5843 
    exit 0
  else
    echo "hmc5842 is already loaded!"
    exit 0  
  fi
else
    source /etc/profile
    if modprobe hmc5843 ; then
      echo hmc5883  0x1e > /sys/bus/i2c/devices/i2c-1/new_device
      driverpath=$(find /sys/bus/i2c/devices/1-001e/ -type d -name 'iio:device*')
      sed -i "s|HMC5843PATH=.*|HMC5843PATH='$driverpath'|g" /etc/profile
      exit 1 # not sure if loaded
    fi
fi
