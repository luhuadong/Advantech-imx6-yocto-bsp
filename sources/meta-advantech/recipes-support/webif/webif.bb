DESCRIPTION = "Web interface from x-wrt"
LICENSE = "GPLv2"

PV = "0.3+svnr4987"
PR = "r1"
RDEPENDS_${PN} = "appweb"

#SRC_URI = "svn://x-wrt.googlecode.com/svn;module=trunk;protocol=http"
SRC_URI = "file://create_lang_list.sh \
           file://Makefile \
           file://webif.postinst \
           file://files \
           file://src \
           "

LIC_FILES_CHKSUM = "file://Makefile;beginline=1;endline=6;md5=cd3e52661beed207128085c3b2dc8ad6 \
                    file://src/webif-page.c;beginline=1;endline=16;md5=7b7a738297579625ace46f5af5e12e0a \
                    file://src/wepkeygen/md5.c;beginline=1;endline=14;md5=58eee979159d1bdf214e1ae724ed20e5"

RDEPENDS_${PN} = "haserl tzdata"

S = "${WORKDIR}/webif"

do_patch() {
    mkdir -p ${WORKDIR}/webif > /dev/null 2>&1
    for i in create_lang_list.sh webif.postinst Makefile files src; do
        cp -a ${WORKDIR}/$i ${S} >/dev/null 2>&1
    done
}

do_configure() {
    ./create_lang_list.sh . files/etc/
    echo ${PV} > files/www/.version
}

do_compile() {
    ${CC} ${CFLAGS} \
    -D_METAPACK \
    -I${STAGING_INCDIR} -include endian.h \
    ${LDFLAGS} \
    -o ${S}/webifmetabin \
    src/int2human/main.c src/int2human/human_readable.c \
    src/wepkeygen/keygen.c src/wepkeygen/md5.c \
    src/webif-page.c src/bstrip.c src/webifmetabin.c
}

do_install() {
    cp -a ${S}/files/* ${D}/
    chmod a+x ${D}/${sysconfdir}/init.d/*
    chmod a+x ${D}/www/cgi-bin/webif/*.sh
    for i in `ls ${D}/www/themes/`; do
        echo $i >> ${D}/etc/themes.lst
    done
    install -m 0755 -d ${D}/${bindir}
    install -m 0755 ${S}/webifmetabin ${D}/${bindir}/webifmetabin
    WEBIF_INSTROOT=${D} ${S}/webif.postinst
}

inherit update-rc.d
INITSCRIPT_PACKAGES = "${PN} ${PN}-crontab ${PN}-custom-user-startup ${PN}-timezone ${PN}-dmesgbackup ${PN}-webiffirewalllog ${PN}-ipsec"
INITSCRIPT_NAME_${PN} = "webif"
INITSCRIPT_PARAMS_${PN} = "start 90 3 5 ."
INITSCRIPT_NAME_${PN}-crontab = "crontab"
INITSCRIPT_PARAMS_${PN}-crontab = "start 49 3 5 ."
INITSCRIPT_NAME_${PN}-custom-user-startup = "custom-user-startup"
INITSCRIPT_PARAMS_${PN}-custom-user-startup = "start 99 3 5 ."
INITSCRIPT_NAME_${PN}-timezone = "timezone"
INITSCRIPT_PARAMS_${PN}-timezone = "start 41 3 5 ."
INITSCRIPT_NAME_${PN}-dmesgbackup = "dmesgbackup"
INITSCRIPT_PARAMS_${PN}-dmesgbackup = "start 99 3 5 ."
INITSCRIPT_NAME_${PN}-webiffirewalllog = "webiffirewalllog"
INITSCRIPT_PARAMS_${PN}-webiffirewalllog = "start 90 3 5 ."
INITSCRIPT_NAME_${PN}-ipsec = "ipsec"
INITSCRIPT_PARAMS_${PN}-ipsec = "start 60 3 5 ."

PACKAGES =+ "${PN}-crontab ${PN}-custom-user-startup ${PN}-timezone ${PN}-dmesgbackup ${PN}-webiffirewalllog ${PN}-ipsec"

FILES_${PN}-crontab = "${sysconfdir}/init.d/crontab"
FILES_${PN}-custom-user-startup = "${sysconfdir}/init.d/custom-user-startup"
FILES_${PN}-dmesgbackup = "${sysconfdir}/init.d/dmesgbackup"
FILES_${PN}-webiffirewalllog = "${sysconfdir}/init.d/webiffirewalllog"
FILES_${PN}-timezone = "${sysconfdir}/init.d/timezone"
FILES_${PN}-ipsec = "${sysconfdir}/init.d/ipsec"
FILES_${PN} += "/www/.version /www/* ${base_libdir}/* /usr/*"
