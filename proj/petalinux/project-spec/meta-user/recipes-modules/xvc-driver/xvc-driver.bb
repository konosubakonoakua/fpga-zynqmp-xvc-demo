SUMMARY = "Recipe for  build an external xvc-driver Linux kernel module"
SECTION = "PETALINUX/modules"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263"


inherit module

INHIBIT_PACKAGE_STRIP = "1"

SRC_URI = "file://Makefile \
           file://COPYING \
           file://xvc_driver_base.c \
           file://xvc_driver.c \
           file://xvc_driver.h \
           file://xvc_ioctl.h \
           file://xvc_user_config.h \
          "

S = "${WORKDIR}"

MODULES_DIR="${TOPDIR}/../images/linux/modules"

do_install_append() {
    mkdir -p ${MODULES_DIR}
    cp ${B}/xilinx_xvc_driver.ko ${MODULES_DIR}
}

# The inherit of module.bbclass will automatically name module packages with
# "kernel-module-" prefix as required by the oe-core build environment.
