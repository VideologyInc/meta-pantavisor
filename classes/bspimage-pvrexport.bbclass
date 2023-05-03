
DEPENDS:append = " pvr-native squashfs-tools-native "

IMAGE_TYPES += " pvbspit "
IMAGE_FSTYPES += " pvbspit "
IMAGE_TYPES_MASKED += " ${@bb.utils.contains('PVBSP_IMAGE', '${PN}', '', ' pvbspit ', d)} "

inherit image

PVR_FORMAT_OPTS ?= "-comp xz"

PVBSPSTATE = "${WORKDIR}/pvbspstate"
PVBSP = "${WORKDIR}/pvbsp"
PVBSP_mods = "${WORKDIR}/pvbsp-mods"
PVBSP_fw = "${WORKDIR}/pvbsp-fw"
PVR_CONFIG_DIR ?= "${WORKDIR}/pvbspconfig"

do_image_pvbspit[dirs] = "${TOPDIR} ${PVBSPSTATE} ${PVBSP} ${PVBSP_mods} ${PVBSP_fw} ${PVR_CONFIG_DIR} "
do_image_pvbspit[cleandirs] = " "

fakeroot IMAGE_CMD:pvbspit(){

    echo Na2: ${D} asa
    cd ${PVBSP}
    mkdir -p ${PVBSP_mods}/lib/modules
    cp -rf ${IMAGE_ROOTFS}/lib/modules/*/* ${PVBSP_mods}
    cp -rf ${IMAGE_ROOTFS}/lib/firmware/* ${PVBSP_fw}
    cd ${PVBSPSTATE}
    pvr init
    [ -d bsp ] || mkdir bsp
    [ -f bsp/modules.squashfs ] || rm -f bsp/modules.squashfs
    [ -f bsp/firmware.squashfs ] || rm -f bsp/modules.squashfs

    mksquashfs ${PVBSP_mods} ${PVBSPSTATE}/bsp/modules.squashfs ${PVR_FORMAT_OPTS}
    mksquashfs ${PVBSP_fw} ${PVBSPSTATE}/bsp/firware.squashfs ${PVR_FORMAT_OPTS}
    gunzip -c ${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE}  > ${PVBSPSTATE}/bsp/kernel.img
    cp -f ${DEPLOY_DIR_IMAGE}/pantavisor-bsp-${MACHINE}.cpio.gz ${PVBSPSTATE}/bsp/pantavisor
    cp -f ${DEPLOY_DIR_IMAGE}/${PV_INITIAL_DTB} ${PVBSPSTATE}/bsp/${PV_INITIAL_DTB}

    _pvline='    "initrd": "pantavisor",
    "linux": "kernel.img",'

    cat > ${PVBSPSTATE}/bsp/run.json << EOF
`echo '{'`
    "addons": [],
    "firmware": "firmware.squashfs",
${_pvline}
    "fdt": "${PV_INITIAL_DTB}",
    "initrd_config": "",
    "modules": "modules.squashfs"
`echo '}'`
EOF
    pvr add; pvr commit
    pvr export ${IMGDEPLOYDIR}/bsp-${PN}.pvrexport.tgz
}


python __anonymous() {
    pn = d.getVar("PN")
    if not pn in d.getVar("PVBSP_IMAGE") and \
       "linux-dummy" not in d.getVar("PREFERRED_PROVIDER_virtual/kernel"):
        msg = '"pvbsp" is no in IMGCLASSES, but ' \
              'PREFERRED_PROVIDER_virtual/kernel is not "linux-dummy". ' \
              'Setting it to linux-dummy accordingly.'

        d.setVar("PREFERRED_PROVIDER_virtual/kernel", "linux-dummy")
}

