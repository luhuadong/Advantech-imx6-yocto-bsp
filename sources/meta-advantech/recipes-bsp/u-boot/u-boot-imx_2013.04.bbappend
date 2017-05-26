FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://u-boot-imx_2016-04-08.patch"

UBOOT_MAKE_TARGET += "all"
SPL_BINARY = "SPL"

do_deploy_append() {
    install -d ${DEPLOYDIR}
    install ${S}/u-boot_crc.bin.crc ${DEPLOYDIR}/u-boot_crc.bin.crc
    install ${S}/u-boot_crc.bin ${DEPLOYDIR}/u-boot_crc.bin
}

