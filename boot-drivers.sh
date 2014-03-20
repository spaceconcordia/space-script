#!/bin/sh
 #lsmod | grep -q dvb-bt8xx || /sbin/modprobe dvb-bt8xx >/dev/null 2>&1load subsystem drivers on boot
# perhaps maintain up status in inittab


#You have to create a /etc/sysconfig/modules/xxxxx.modules file with 755 permission and root.root ownership. Then populate it with something like:
#http://forums.fedoraforum.org/showpost.php?s=2c8ed4e4c7cc17f0087070093f7ca85d&p=1497803&postcount=12
#If you want to load driver B when driver A is loaded, then look to /etc/modprobe.d
#If you want to load driver A with specific options - then look to /etc/modprobe.d
#If you want to prevent driver A from loading - then look to /etc/modprobe.d
#If you want to alias driver names- then look to /etc/modprobe.d
#If you want some program or action to occur whenever driver A is modprobed , then look to /etc/modprobe.d
#If you want to initiate modprobe at boot or otherwise - then /etc/modprobe.d cannot work. You need udev or rc.sysinit or systemd or ...

#!/bin/sh
exec /sbin/modprobe xxxxx >/dev/null 2>&1

if lsmod | grep "$MODULE" &> /dev/null ; then
    echo "$MODULE is loaded!"
    exit 0
else
    echo "$MODULE is not loaded!"
    exit 1
fi

function check-mod () {
if [ lsmod | grep "$1" &> /dev/null ] ; then
    return 0; # driver is loaded
else
    return 1; # driver is not loaded
fi   
}

function load-ad799x () {
    modprobe ad799x
    echo ad7998 0x21 > /sys/bus/i2c/devices/i2c-1/new_device
    echo ad7998 0x22 > /sys/bus/i2c/devices/i2c-1/new_device
    echo ad7998 0x23 > /sys/bus/i2c/devices/i2c-1/new_device
}
check-mod "ad799x" || start-ad799x

function load-hmc5843 () {
    modprobe hmc5843
    echo hmc5883  0x1e > /sys/bus/i2c/devices/i2c-1/new_device
}
check-mod "hmc5843" || start-hmc5843

function load-ina2xx () {
    modprobe ina2xx
    echo ina219 0x40 > /sys/bus/i2c/devices/i2c-1/new_device
}
check-mod "ina2xx" || load-ina2xx

function load-rtc-ds3232e () {
    # Realtime clock
    modprobe rtc-ds3232e
    echo ds3232 0x68 > /sys/bus/i2c/devices/i2c-1/new_device
}
check-mod "rtc-ds3232e" || start-rtc-ds3232e
