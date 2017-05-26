SUMMARY = "Qt5 launch demo"
DESCRIPTION = "Quick tour of Qt 5.0, primarily focusing on its graphical capabilities."
HOMEPAGE = "https://qt.gitorious.org/qt-labs"
LICENSE = "LGPLv2.1"
LIC_FILES_CHKSUM = "file://README;md5=f40259ce418fdb2c03328a85ec116bb4"

SRCREV = "c43ddf9d354761c51266ecbdc6cb90a3aac1903d"
SRC_URI = "git://gitorious.org/qt-labs/qt5-launch-demo.git"

S = "${WORKDIR}/git"
DEPENDS = "qtdeclarative qtgraphicaleffects qtwebkit qtmultimedia"
RDEPENDS_${PN} = "qtdeclarative-qmlplugins qtgraphicaleffects-qmlplugins qtwebkit-qmlplugins qtmultimedia-qmlplugins"

#require recipes-qt/qt5/qt5.inc
do_install() {
    install -d ${D}${datadir}/${P}
    cp -a ${S}/* ${D}${datadir}/${P}  
}

FILES_${PN}-dbg += "${datadir}/${P}/.debug"
FILES_${PN} += "${datadir}"
