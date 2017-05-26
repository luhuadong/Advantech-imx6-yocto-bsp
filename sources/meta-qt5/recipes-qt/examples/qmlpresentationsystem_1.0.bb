SUMMARY = "Qt5 qml presentation system"
DESCRIPTION = "This is a slide presentation system written in QML"
HOMEPAGE = "https://qt.gitorious.org/qt-labs"
LICENSE = "LGPLv2.1"
LIC_FILES_CHKSUM = "file://README;md5=83461249df89dcd1c7f122147084eadd"

SRCREV = "d00dd05de4ea18f6aba30c4d4e23531769961b8c"
SRC_URI = "git://gitorious.org/qt-labs/qml-presentation-system.git"

S = "${WORKDIR}/git"
DEPENDS = "qtdeclarative qtgraphicaleffects"
RDEPENDS_${PN} = "qtdeclarative-qmlplugins qtgraphicaleffects-qmlplugins"

require recipes-qt/qt5/qt5.inc
