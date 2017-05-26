FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://disable-module-update.patch \
            file://disable-webmin-functions.patch \
            file://disable-left-functions.patch \
            file://disable-left-modules.patch \
            file://disable-modconfig.patch \
            file://net-module.patch \
            file://init-module.patch \
            file://acl-module.patch \
            file://time-module.patch \
            file://logo.patch \
            file://wise-status/wise-status-item.patch \
            file://logo.png \
            file://wise.conf \
            file://wsn.conf \
            file://wise \
            file://wisecloud \
            file://factorydefault \
            file://fwupdate \
            file://netdiag \
            file://default-config \
            file://wise_tools \
            file://init.config \
            file://agent_config.xml \
            file://restapi \
            file://wise-status"

do_install() {
    install -d ${D}${sysconfdir}
    install -d ${D}${sysconfdir}/webmin
    install -d ${D}${sysconfdir}/init.d
    install -d ${D}${bindir}
    install -m 0755 webmin-init ${D}${sysconfdir}/init.d/webmin

    install -d ${D}${localstatedir}
    install -d ${D}${localstatedir}/webmin

    install -d ${D}${libexecdir}/webmin
    cp -pPR ${S}/* ${D}${libexecdir}/webmin
    rm -f ${D}${libexecdir}/webmin/webmin-init
    rm -rf ${D}${libexecdir}/webmin/patches

    # Install WISE Setting module & related files
    cp -pPR ${S}/../wise ${D}${libexecdir}/webmin/
    cp -pPR ${S}/../factorydefault ${D}${libexecdir}/webmin/
    cp -pPR ${S}/../fwupdate ${D}${libexecdir}/webmin/
    cp -pPR ${S}/../wisecloud ${D}${libexecdir}/webmin/
    cp -pPR ${S}/../netdiag ${D}${libexecdir}/webmin/
    cp -pPR ${S}/../wise-status/wise-status.cgi ${D}${libexecdir}/webmin/
    cp -pPR ${S}/../wise-status/images/* ${D}${libexecdir}/webmin/images/
    install -m 0655 ${S}/../wise.conf ${D}${sysconfdir}
    install -m 0655 ${S}/../wsn.conf ${D}${sysconfdir}
    install -m 0655 ${S}/../agent_config.xml ${D}${sysconfdir}
    cp -pPR ${S}/../default-config ${D}${sysconfdir}/webmin/
    install -m 0644 ${S}/../logo.png ${D}${libexecdir}/webmin/images/

    # Install WISE related tools
    #mkdir -p ${D}${bindir}
    install -m 0755 ${WORKDIR}/wise_tools/* ${D}${bindir}
    #install -m 0755 ${WORKDIR}/wise_tools/resetdustwsn ${D}${bindir}
    #install -m 0755 ${WORKDIR}/wise_tools/restoredustwsn ${D}${bindir}
    #install -m 0755 ${WORKDIR}/wise_tools/exchangedustwsn ${D}${bindir}
    #install -m 0755 ${WORKDIR}/wise_tools/listmote ${D}${bindir}
    #install -m 0755 ${WORKDIR}/wise_tools/nrdustwsn ${D}${bindir}

    # Install RestAPI service
    cp -pPR ${S}/../restapi/miniserv.pl ${D}${libexecdir}/webmin/
    cp -pPR ${S}/../restapi/restapi.pl ${D}${libexecdir}/webmin/

	# Revmoe some themes
    rm -rf ${D}${libexecdir}/webmin/mscstyle3
    rm -rf ${D}${libexecdir}/webmin/caldera

    # Run setup script
    export perl=perl
    export perl_runtime=${bindir}/perl
    export prefix=${D}
    export tempdir=${S}/install_tmp
    export wadir=${libexecdir}/webmin
    export config_dir=${sysconfdir}/webmin
    export var_dir=${localstatedir}/webmin
    export os_type=generic-linux
    export os_version=0
    export real_os_type="${DISTRO_NAME}"
    export real_os_version="${DISTRO_VERSION}"
    export port=80
    export login=admin
    export password=admin
    export ssl=0
    export atboot=1
    export no_pam=1
    mkdir -p $tempdir
    ${S}/../setup.sh

    install -m 0600 ${S}/../init.config ${D}${sysconfdir}/webmin/init/config
}
