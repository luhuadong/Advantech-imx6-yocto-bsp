SUMMARY = "Qt5 patientCare QML demo application"
DESCRIPTION = "It shows a hypthetical mobile device that \
could be used in a medical environment to control the medication of a patient and to \
watch over the patients' heart beat."

HOMEPAGE = "http://www.basyskom.com/news/143-demos-qt5-port.html"
LICENSE = "LGPLv2.1+ & GFDL-1.2"
LIC_FILES_CHKSUM = "file://COPYING.DOC;md5=ad1419ecc56e060eccf8184a87c4285f \
                    file://COPYING.LIB;md5=2d5025d4aa3495befef8f17206a5b0a1"

SRC_URI = "http://share.basyskom.com/demos/patientcare_src.tar.gz"

SRC_URI[md5sum] = "b49d9125f852451fb277b9edcc69d808"
SRC_URI[sha256sum] = "f7b93f5de257c775321ad684bfced1b3b1e1e06697086816f89723ea360c4314"

S = "${WORKDIR}/patientcare_src"

require recipes-qt/qt5/qt5.inc

do_install() {
    install -d ${D}${datadir}/${P}
    install -d ${D}${datadir}/${P}/qml/patientcare/components/
    install -m 0755 ${B}/patientcare ${D}${datadir}/${P}   
    #install -m 0755 ${B}/qml/patientcare/components/libPatientcarePlugin.so ${D}${datadir}/${P}  
    #install -m 0755 ${B}/qml/patientcare/components/libPatientcarePlugin.so ${D}${datadir}/${P}/.debug
    cp -ar ${B}/qml ${D}${datadir}/${P}  
    cp -ar ${S}/qml ${D}${datadir}/${P} 
    cp -a ${S}/components ${D}${datadir}/${P}  
}
FILES_${PN}-dbg += "${datadir}/${P}/.debug"
FILES_${PN}-dbg += "${datadir}/${P}/qml/patientcare/components/.debug/*"
FILES_${PN} += "${datadir}"
