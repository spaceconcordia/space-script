#!/bin/sh
# load subsystem drivers on boot
# perhaps maintain up status in inittab
modprobe ad799x
echo ad7998 0x21 > /sys/bus/i2c/devices/i2c-1/new_device
