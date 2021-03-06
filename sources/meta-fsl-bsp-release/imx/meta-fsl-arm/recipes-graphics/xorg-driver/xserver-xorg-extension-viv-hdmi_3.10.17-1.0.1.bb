# Copyright (C) 2014 Freescale Semiconductor
# Released under the MIT license (see COPYING.MIT for the terms)
DESCRIPTION = "Freescale Extension for HDMI performance"
LICENSE = "MIT-X"

DEPENDS += "virtual/kernel xf86-video-imxfb-vivante"

LIC_FILES_CHKSUM = "file://EXA/src/vivante_fbdev/vivante.h;endline=19;md5=641ac6e6d013833e36290797f4d7089c"

SRC_URI = "${FSL_MIRROR}/xserver-xorg-video-imx-viv-${PV}.tar.gz \
            file://rc.local.etc \
            file://rc.local.init"

S="${WORKDIR}/xserver-xorg-video-imx-viv-${PV}/"

SRC_URI[md5sum] = "974f33945dc96e876907541906297798"
SRC_URI[sha256sum] = "5602266ac493c580386562068522b2fde43f24aa91c61ab6aaa62bb37a6cb672"

inherit update-rc.d autotools pkgconfig

INITSCRIPT_NAME = "rc.hdmi"
INITSCRIPT_PARAMS = "start 99 2 3 4 5 ."

EXTRA_OEMAKE += "-C ${S}/util/autohdmi -f makefile.linux prefix=${D}/usr \
                 sysroot=${STAGING_DIR_TARGET} \
                 BUSID_HAS_NUMBER=1 \
                 BUILD_IN_YOCTO=1 \
                 XSERVER_GREATER_THAN_13=1"

# FIXME: The Freescale provided Makefile has hardcodec include paths
#        and this does not work in case prefix is different than /usr,
#        sed it.
do_configure_prepend () {
    sed -i 's,$(sysroot)/usr/include,${STAGING_INCDIR},g' \
            ${S}FslExt/src/makefile.linux
}

# FIXME: This is need as Freescale didn't use standard Makefile filename
#        thus oe_runmame thinks nothing is need to be done, use ln to
#        workaround it.
base_do_compile () {
    oe_runmake || die "make failed"
}

do_compile_append () {

oe_runmake -C ${S}/FslExt/src
 
}

do_install () {
    install -d ${D}${libdir}
    cp -axr ${S}/FslExt/src/libfsl_x11_ext.so ${D}${libdir}

    install -d ${D}${exec_prefix}/sbin
    cp -axr ${S}/util/autohdmi/autohdmi ${D}${exec_prefix}/sbin

    install -d ${D}/${sysconfdir}/init.d
    install -m 755 ${WORKDIR}/rc.local.init ${D}/${sysconfdir}/init.d/rc.hdmi
    install -m 755 ${WORKDIR}/rc.local.etc ${D}/${sysconfdir}/rc.hdmi
}

RDEPENDS_${PN} = "xf86-video-imxfb-vivante"

REALSOLIBS := "${SOLIBS}"
SOLIBS = "${SOLIBSDEV}"

FILES_${PN} = " ${libdir}/libfsl_x11_ext${SOLIBS} ${exec_prefix}/sbin/autohdmi ${sysconfdir}/init.d ${sysconfdir}/rc.hdmi"

PACKAGE_ARCH = "${MACHINE_SOCARCH}"
COMPATIBLE_MACHINE = "(mx6)"
