#Advantech package
require fsl-image-x11.inc

inherit populate_sdk_base

CONFLICT_DISTRO_FEATURES = "x11 wayland directfb"
DISTRO_FEATURES = ""

IMAGE_FEATURES += "package-management"

PACKAGE_EXCLUDE = "" 

SOC_IMAGE_INSTALL = ""
SOC_IMAGE_INSTALL_mx6 = ""

fbi_rootfs_postprocess() {
    crond_conf=${IMAGE_ROOTFS}/var/spool/cron/root
	echo '0 0-23/12 * * * /sbin/hwclock --hctosys' >> $crond_conf
    
    network_interfaces=${IMAGE_ROOTFS}/etc/network/interfaces
    touch $network_interfaces
    echo '# /etc/network/interfaces -- configuration file for ifup(8), ifdown(8)' > $network_interfaces
    echo 'auto lo eth0 eth0:0' >> $network_interfaces
    echo 'iface lo inet loopback' >> $network_interfaces
    echo 'iface eth0 inet dhcp' >> $network_interfaces
    echo 'iface eth0:0 inet static' >> $network_interfaces
    echo '        address 192.168.0.1' >> $network_interfaces
    echo '        netmask 255.255.255.0' >> $network_interfaces

	mkdir -p ${IMAGE_ROOTFS}/etc/webmin/default-config/etc/network
	cp -f $network_interfaces ${IMAGE_ROOTFS}/etc/webmin/default-config/etc/network/interfaces

    udev_blacklist=${IMAGE_ROOTFS}/etc/udev/mount.blacklist
    echo '/dev/mmcblk0*' >> $udev_blacklist

    factory_def=${IMAGE_ROOTFS}/home/root/factorydef.sh
	echo '#!/bin/sh' > $factory_def
	echo 'null_file=/dev/null' >> $factory_def
	echo 'fuser -k /dev/ttyUSB0' >> $factory_def
	echo 'fuser -k /dev/ttyUSB1' >> $factory_def
	echo "nr=\`cat /tmp/nrdustwsn\`" >> $factory_def
	echo 'if [ -z $nr ]; then nr=0; fi' >> $factory_def
	echo 'rm -rf /etc/rc5.d/* >$null_file 2>&1' >> $factory_def
	echo 'rm -rf /etc/webmin/webmincron/crons/* >$null_file 2>&1' >> $factory_def
	echo 'cp -rf /etc/webmin/default-config/* /  >$null_file 2>&1' >> $factory_def
	echo '/usr/lib/webmin/webmin/changepass.pl /etc/webmin admin admin >$null_file 2>&1' >> $factory_def
	echo 'if [ $nr -gt 0 ]; then' >> $factory_def
	echo '/usr/bin/restoredustwsn /etc/wsn.conf 1 /dev/ttyUSB0 >$null_file 2>&1' >> $factory_def
	echo 'sleep 1' >> $factory_def
	echo 'fi' >> $factory_def
	echo 'if [ $nr -gt 1 ]; then' >> $factory_def
	echo '/usr/bin/restoredustwsn /etc/wsn.conf 2 /dev/ttyUSB1 >$null_file 2>&1' >> $factory_def
	echo 'sleep 1' >> $factory_def
	echo 'fi' >> $factory_def
	echo 'hostname -F /etc/hostname >$null_file 2>&1' >> $factory_def
	echo '/sbin/reboot >$null_file 2>&1' >> $factory_def
	chmod +x $factory_def

    rc5init=${IMAGE_ROOTFS}/etc/rc5.d
	mkdir -p ${IMAGE_ROOTFS}/etc/webmin/default-config/etc
	cp -af $rc5init ${IMAGE_ROOTFS}/etc/webmin/default-config/etc/
}

ROOTFS_POSTPROCESS_COMMAND += "fbi_rootfs_postprocess"
