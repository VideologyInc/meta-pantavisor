
REMOVE_LIBTOOL_LA = "0"

DEPENDS:append = " pvr-native "

PVR_COMPRESSION ?= "-comp xz"

PANTAHUB_API ?= "api.pantahub.com"

S = "${WORKDIR}/pvrexport"

B = "${WORKDIR}/pvrbuild"

do_compile(){
	cd ${B}
	pvr clone ${S} ${BPN}-${PV}
}

do_deploy(){
	mkdir -p ${DEPLOY_DIR_IMAGE}/${DISTRO}/
	cd ${B}/${BPN}-${PV}
	pvr export ${DEPLOY_DIR_IMAGE}/${DISTRO}/${BPN}-${PV}.pvrexport.tgz
	ln -fsr ${DEPLOY_DIR_IMAGE}/${DISTRO}/${BPN}-${PV}.pvrexport.tgz ${DEPLOY_DIR_IMAGE}/${DISTRO}/${BPN}.pvrexport.tgz
}

addtask deploy after do_compile

do_patch[noexec] = "1"
do_configure[noexec] = "1"
do_install[noexec] = "1"
do_package[noexec] = "1"
do_deploy_source_date_epoch[noexec] = "1"
do_populate_lic[noexect] = "1"
do_populate_sysroot[noexec] = "1"
do_package_qa[noexec] = "1"
do_packagedata[noexec] = "1"
do_package_write_ipk[noexec] = "1"
do_package_write_deb[noexec] = "1"
do_package_write_rpm[noexec] = "1"

