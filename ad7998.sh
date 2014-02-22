#!/bin/sh
lsmod | grep -q ad7998 0x21 || /sbin/modprobe ad7998 >/dev/null 2>&1
load subsystem drivers on boot
echo ad7998 0x21 > /sys/bus/i2c/devices/i2c-1/new_device
# perhaps maintain up status in inittab
