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
