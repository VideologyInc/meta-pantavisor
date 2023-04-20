
DEPENDS:append = " pvr-native squashfs-tools-native "

inherit image

IMAGE_TYPES += " pvrexportit "
IMAGE_FSTYPES += " pvrexportit "

PVR_FORMAT_OPTS ?= "-comp xz"
PVR_SOMETHING = "yes"

PVSTATE = "${WORKDIR}/pvstate"

do_image_pvrexportit[dirs] = " ${TOPDIR} ${PVSTATE} "
do_image_pvrexportit[cleandirs] = " "

fakeroot IMAGE_CMD:pvrexportit(){

    echo Ja2: ${D} asa
    cd ${PVSTATE}
    pvr init
    pvr app add \
	--force \
    	--type rootfs \
	--from "${IMAGE_ROOTFS}" \
	--format-options="${PVR_FORMAT_OPTS} -e lib/modules -e lib/firmware " \
	${PN}
    pvr add
    pvr commit
    pvr export ${IMGDEPLOYDIR}/${PN}.pvrexport.tgz
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

