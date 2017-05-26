SUMMARY = "Alljoyn support for i.MX6 platform"
DESCRIPTION = "Alljoyn is a software framework that provides proximity-based P2P network management for IoT (Internet of Things)."
HOMEPAGE = "https://allseenalliance.org/"
SECTION = "base"
LICENSE = "ISC"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/ISC;md5=f3b90e78ea0cffb20bf5cca7947a896d"

GIT_BRANCH = "RB14.12"

SRC_URI = "git://git.allseenalliance.org/gerrit/core/alljoyn.git;protocol=https;branch=${GIT_BRANCH};name=router;destsuffix=git/core/alljoyn \
           git://git.allseenalliance.org/gerrit/services/base.git;protocol=https;branch=${GIT_BRANCH};name=services;destsuffix=git/services/base \
           file://modify_flags_for_yocto.patch \
           file://alljoyn/router/config.xml \
           file://alljoyn/router/alljoyn.init"

SRCREV_router = "0d71b216bb3a3cadc615c3eda6f8200093c5e117"
SRCREV_services = "403cda579242701d42d2d7c0da308d63a8f46070"

S = "${WORKDIR}/git/core/alljoyn"

inherit scons

EXTRA_OESCONS = " \
    BINDINGS=cpp OS=linux CPU=${TARGET_ARCH} VARIANT=debug BUILD_SERVICES_SAMPLES=off POLICYDB=on \
    SERVICES="about,notification,controlpanel,config,onboarding" \
    WS=off CROSS_COMPILE=${STAGING_BINDIR_NATIVE}/${TUNE_PKGARCH}-poky-${TARGET_OS}/${TARGET_PREFIX} \
    SYSROOT=${STAGING_DIR_TARGET} \
"

do_install() {
    # Alljoyn Router
    install -d ${D}/usr/bin/
    install -m 755 ${S}/build/linux/${TARGET_ARCH}/debug/dist/cpp/bin/alljoyn-daemon ${D}/usr/bin/alljoyn-daemon
    install -d ${D}/usr/lib/
    install -m 644 ${S}/build/linux/${TARGET_ARCH}/debug/dist/cpp/lib/*.so ${D}/usr/lib/
    install -d ${D}/opt/alljoyn/alljoyn-daemon.d/
    install -m 644 ${WORKDIR}/alljoyn/router/config.xml ${D}/opt/alljoyn/alljoyn-daemon.d/config.xml
    install -d ${D}/etc/init.d/
    install -m 755 ${WORKDIR}/alljoyn/router/alljoyn.init ${D}/etc/init.d/alljoyn

    # Alljoyn Services
    install -m 644 ${S}/build/linux/${TARGET_ARCH}/debug/dist/config/lib/liballjoyn_config.so ${D}/usr/lib/
    install -m 644 ${S}/build/linux/${TARGET_ARCH}/debug/dist/controlpanel/lib/liballjoyn_controlpanel.so ${D}/usr/lib/
    install -m 644 ${S}/build/linux/${TARGET_ARCH}/debug/dist/notification/lib/liballjoyn_notification.so ${D}/usr/lib/
    install -m 644 ${S}/build/linux/${TARGET_ARCH}/debug/dist/onboarding/lib/liballjoyn_onboarding.so ${D}/usr/lib/
    install -m 644 ${S}/build/linux/${TARGET_ARCH}/debug/dist/services_common/lib/liballjoyn_services_common.so ${D}/usr/lib/
}

# List the files for Package
FILES_${PN} += "/usr/bin/alljoyn-daemon"
FILES_${PN} += "/usr/lib/*.so"
FILES_${PN} += "/opt/alljoyn/alljoyn-daemon.d/config.xml"
FILES_${PN} += "/etc/init.d/alljoyn"

DEPENDS = "python-scons-native openssl"

COMPATIBLE_MACHINE = "(mx6)"
