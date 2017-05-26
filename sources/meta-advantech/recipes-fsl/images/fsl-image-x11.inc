#Advantech package
IMAGE_FEATURES += " ssh-server-openssh "

IMAGE_INSTALL += " modules-load "
IMAGE_INSTALL += " libungif fbv stress lirc tools"
IMAGE_INSTALL += " ppp ntp e2fsprogs cronie e2fsprogs-e2fsck inetutils inetutils-telnet inetutils-telnetd"
IMAGE_INSTALL += " linux-firmware-ralink "
IMAGE_INSTALL += " linux-firmware-rtl8188ee "
IMAGE_INSTALL += " linux-firmware-ar3k "
IMAGE_INSTALL += " packagegroup-core-eclipse-debug "
# JDK
#IMAGE_INSTALL += " openjdk-7-jre "
# CAgent required packages
IMAGE_INSTALL += " curl curl-dev libxml2 libxml2-dev openssl openssl-dev lsb "
# MQTT OMA-DM
IMAGE_INSTALL += " mosquitto mosquitto-dev libdmclient libdmclient-dev "
# DustLink
IMAGE_INSTALL += " minicom dustlink boost boost-dev serialmux "
# WebServer & WebAdmin
#IMAGE_INSTALL += " appweb lua uci webif "
#IMAGE_INSTALL += " ajenti ajenti-plugin-hddstat ajenti-plugin-network ajenti-plugin-services ajenti-plugin-supervisor "
IMAGE_INSTALL += " tzdata tzdata-asia tzdata-americas tzdata-europe ntpdate "
IMAGE_INSTALL += " perl-module-utf8 libxml-parser-perl libxml-simple-perl perl-module-io-handle perl-module-unicore libjson-perl "
IMAGE_INSTALL += " webmin webmin-module-system-status webmin-module-net webmin-module-time webmin-module-webmincron webmin-module-proc webmin-module-acl webmin-module-webmin webmin-module-mount webmin-module-init webmin-module-wise webmin-module-factorydefault webmin-module-fwupdate webmin-module-wisecloud webmin-module-netdiag "
# Alljoyn
IMAGE_INSTALL += "alljoyn alljoyn-dev nodejs"
# Native Compiler
IMAGE_INSTALL += " packagegroup-sdk-target "
# connman
IMAGE_INSTALL += "connman"
#Iotivity
IMAGE_INSTALL += " iotivity "
