DESCRIPTION = "AppWeb is an embedded HTTP Web server that has been designed with security in mind."
SECTION = "console/network"
LICENSE = "GPL"
LIC_FILES_CHKSUM = "file://LICENSE.md;md5=df7cfb0d4723489d25aecb8f2a879818"
SRC_URI = "http://appwebserver.org/software/appweb-5.2.0-src.tgz"
SRC_URI += "file://fix_path.patch \
	file://appweb.conf \
	file://install.conf \
	" 

SRC_URI[md5sum] = "e959abec9244eb535179cd1cff0c038b"
SRC_URI[sha256sum] = "dea8fd9d967c149d0ca4e22d034fc995827ae7a1eda881f5a9d72d4d7b2287f0"

inherit update-rc.d
#
# implications - used by update-rc.d scripts
#
INITSCRIPT_NAME = "appweb"
INITSCRIPT_PARAMS = "defaults 70"

FILES_${PN}-dbg =+ "${libdir}/appweb/5.2.0/bin/.debug \
               ${libdir}/.debug"


do_configure () {
    ./configure
}

do_compile () {
	oe_runmake compile
}

do_install () {
    oe_runmake 'ME_ROOT_PREFIX=${D}' installBinary
	install -m 0644 ${WORKDIR}/appweb.conf  ${D}/etc/appweb/appweb.conf
	install -m 0644 ${WORKDIR}/install.conf  ${D}/etc/appweb/install.conf
}

