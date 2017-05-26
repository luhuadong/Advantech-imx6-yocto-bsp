SUMMARY = "A web interface to your SmartMeshIP network."
DESCRIPTION = "DustLink is a web-based SmartMesh IP management application"
HOMEPAGE = "https://dustcloud.atlassian.net/wiki/display/DL/DustLink+Home"
SECTION = "console/network"
LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://DN_LICENSE.txt;md5=6ae34c20e1d2d63b93d593db1e36d0a3"

PV = "1.0.2.63+git${SRCPV}"

SRCREV = "87be4f67a583a5403a38b642f35a37b93e88284d"
SRC_URI = "git://github.com/dustcloud/dustlink.git;protocol=git"
SRC_URI += "file://dustlink_exec_path.patch \
           file://logo.jpg \
           file://database.backup \
           file://dustlink.init"

S = "${WORKDIR}/git"

inherit distutils

FILES_${PN} += "/usr/share /etc/init.d /etc/modules-load.d"

RDEPENDS_${PN} = "python-modules python-gdata python-pyserial python-pydispatcher"

do_install_append() {
    install -m 0644 ${WORKDIR}/logo.jpg ${D}/usr/share/views/web/dustWeb/static/templates/dust/images/logo.jpg
    install -m 0644 ${WORKDIR}/database.backup ${D}/usr/share/views/web/dustWeb/logs/database.backup
    mkdir -p ${D}/etc/init.d
    install -m 0755 ${WORKDIR}/dustlink.init ${D}/etc/init.d/dustlink
    mkdir -p ${D}/etc/modules-load.d
    echo "adv-dustwsn" > ${D}/etc/modules-load.d/dustwsn.conf
}
