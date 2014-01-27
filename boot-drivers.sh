#!/bin/sh
 #!/bin/bash
 #lsmod | grep -q dvb-bt8xx || /sbin/modprobe dvb-bt8xx >/dev/null 2>&1load subsystem drivers on boot
# perhaps maintain up status in inittab
modprobe ad799x
echo ad7998 0x22 > /sys/bus/i2c/devices/i2c-1/new_device
modprobe hmc5843
# put drivers on SD card #echo hmc5883 0x1e > /sys/bus/i2c/devices/i2c-1/new_device
echo ad7998 0x21 > /sys/bus/i2c/devices/i2c-1/new_device
echo ad7998 0x23 > /sys/bus/i2c/devices/i2c-1/new_device
modprobe ina2xx
echo ina219 0x40 > /sys/bus/i2c/devices/i2c-1/new_device
