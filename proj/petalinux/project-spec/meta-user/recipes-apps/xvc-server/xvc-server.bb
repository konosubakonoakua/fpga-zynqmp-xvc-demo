#
# This file is the xvc-server recipe.
#

SUMMARY = "Simple xvc-server application"
SECTION = "PETALINUX/apps"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://xvcServer.c \
           file://xvc_ioctl.h \
           file://Makefile \
          "

DEPENDS = "\
    xvc-driver \
    "

S = "${WORKDIR}"

do_compile() {
	     oe_runmake
}

do_install() {
	     install -d ${D}${bindir}
	     install -m 0755 xvc-server ${D}${bindir}
}

do_install_append() {
    install -d ${TOPDIR}/../images/linux/apps/
    install -m 0755 ${D}${bindir}/xvc-server ${TOPDIR}/../images/linux/apps/
}
