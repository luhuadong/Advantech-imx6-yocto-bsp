FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
SRC_URI += "file://modify_securetty.patch"
S = "${WORKDIR}"