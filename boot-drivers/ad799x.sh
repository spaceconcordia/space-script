#! /bin/sh
if lsmod | grep "ad799x" &> /dev/null ; then
  if [ "$1" == "-r" ]; then
    echo 0x21 > /sys/bus/i2c/devices/i2c-1/delete_device 
    sed -i "s|AD7998x21PATH=.*|AD7998x21PATH='unset'|g" /etc/profile
    echo 0x22 > /sys/bus/i2c/devices/i2c-1/delete_device 
    sed -i "s|AD7998x22PATH=.*|AD7998x22PATH='unset'|g" /etc/profile        
    echo 0x23 > /sys/bus/i2c/devices/i2c-1/delete_device
    sed -i "s|AD7998x23PATH=.*|AD7998x23PATH='unset'|g" /etc/profile
    modprobe -r ad799x 
  else
    echo "ad799x is already loaded"
    exit 0; # driver is loaded
  fi
else
    source /etc/profile
    if modprobe ad799x ; then
      if echo ad7998 0x21 > /sys/bus/i2c/devices/i2c-1/new_device ; then
        driverpath="$(find /sys/bus/i2c/devices/1-0021/ -type d -name 'iio:device*' -print | head -1)"
        sed -i "s|AD7998x21PATH=.*|AD7998x21PATH='$driverpath'|g" /etc/profile
      fi
      if echo ad7998 0x22 > /sys/bus/i2c/devices/i2c-1/new_device ; then
        driverpath="$(find /sys/bus/i2c/devices/1-0022/ -type d -name 'iio:device*' -print | head -1)"
        sed -i "s|AD7998x22PATH=.*|AD7998x22PATH='$driverpath'|g" /etc/profile        
      fi
      if echo ad7998 0x23 > /sys/bus/i2c/devices/i2c-1/new_device ; then
        driverpath="$(find /sys/bus/i2c/devices/1-0023/ -type d -name 'iio:device*' -print | head -1)"
        sed -i "s|AD7998x23PATH=.*|AD7998x23PATH='$driverpath'|g" /etc/profile
      fi
    fi
    exit 1 # not sure if loaded
fi   
