FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://linux-imx_2016-04-08.patch"

SCMVERSION = "n"

FSL_KERNEL_DEFCONFIG = "imx_v7_adv_defconfig"
