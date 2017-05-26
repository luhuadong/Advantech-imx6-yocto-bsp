DESCRIPTION = "libjson-perl is a collection of smaller Perl modules."
SUMMARY = "Collection of Perl modules for working with JSON."
SECTION = "libs"
LICENSE = "Artistic-1.0 | GPL-1.0+"
PR = "r1"

LIC_FILES_CHKSUM = "file://README;md5=fd80e3ff8d1a3443c416d4853990af81"

SRC_URI = "http://www.cpan.org/authors/id/M/MA/MAKAMAKA/JSON-${PV}.tar.gz"

SRC_URI[md5sum] = "e1512169a623e790a3f69b599cc1d3b9"
SRC_URI[sha256sum] = "4ddbb3cb985a79f69a34e7c26cde1c81120d03487e87366f9a119f90f7bdfe88"

S = "${WORKDIR}/JSON-${PV}"

EXTRA_CPANFLAGS = "EXPATLIBPATH=${STAGING_LIBDIR} EXPATINCPATH=${STAGING_INCDIR}"

inherit cpan

do_compile() {
	export LIBC="$(find ${STAGING_DIR_TARGET}/${base_libdir}/ -name 'libc-*.so')"
	cpan_do_compile
}

BBCLASSEXTEND = "native"
