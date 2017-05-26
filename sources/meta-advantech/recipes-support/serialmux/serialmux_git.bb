SUMMARY = "Dust Serial API Multiplexer."
DESCRIPTION = "The Serial API Multiplexer is a program that allows multiple processes to communicate with the SmartMesh IP Manager's Serial API over a TCP connection."
HOMEPAGE = "https://github.com/dustcloud/serialmux/wiki"
SECTION = "console/network"
LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE;md5=9b72bd3dd9ca1d869d208330ed51eef3"

PV = "1.1.2.15+git${SRCPV}"

SRCREV = "25c3e2fd4e4b9e194094063854906cfb1953d142"
SRC_URI = "git://github.com/dustcloud/serialmux.git;protocol=git"
SRC_URI += "file://build_with_autotool.patch \
           file://serial_mux0.cfg \
           file://serial_mux1.cfg \
           file://serialmux.init"

S = "${WORKDIR}/git"

inherit autotools
#update-rc.d

#INITSCRIPT_NAME = "serialmux"

#INITSCRIPT_PARAMS = "start 90 3 5 . stop 90 0 1 6 ."

FILES_${PN} += "/bin /etc /etc/init.d"

RDEPENDS_${PN} = "boost"
DEPENDS = "boost"

do_install_append() {
    mkdir -p ${D}/etc
    install -m 0644 ${WORKDIR}/serial_mux0.cfg ${D}/etc/
    install -m 0644 ${WORKDIR}/serial_mux1.cfg ${D}/etc/
    mkdir -p ${D}/etc/init.d
    install -m 0755 ${WORKDIR}/serialmux.init ${D}/etc/init.d/serialmux
}
