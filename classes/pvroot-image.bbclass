# pvroot image class
#
# allow to assemble pvroot images by making special rootfs
# allow bundling multiple pvrexports to initial state

# Set some defaults, but these should be overriden by each recipe if required
IMGDEPLOYDIR ?= "${WORKDIR}/deploy-${PN}-image-complete"

do_rootfs[dirs] = "${IMGDEPLOYDIR} ${DEPLOY_DIR_IMAGE}"

PVROOT_IMAGES ?= ""
PVROOT_IMAGES_CORE ?= "core-image-minimal"

DEPENDS += " pvr-native squashfs-tools-native"

IMAGE_BUILDINFO_FILE = "pvroot.build"

IMAGE_TYPES_MASKED += " pvrexportit "

FAKEROOT_CMD = "pseudo"

python __anonymous () {
    pn = d.getVar("PN")

    for img in d.getVar("PVROOT_IMAGES").split():
        d.appendVarFlag('do_rootfs', 'depends', ' '+img+':do_image_complete')
}

PSEUDO_IGNORE_PATHS .= ",${WORKDIR}/pvrrepo,${WORKDIR}/pvrconfig"

def _pvr_pvroot_images_deploy(d, factory, images):

    import tempfile
    import subprocess
    from pathlib import Path
    import shutil

    if True:
        tmpdir=d.getVar("WORKDIR") + "/pvrrepo"
        configdir=d.getVar("WORKDIR") + "/pvrconfig"
        deployrootfs=d.getVar("IMAGE_ROOTFS") + "/trails/0"
        deployimg=d.getVar("DEPLOY_DIR_IMAGE")
        Path(tmpdir).mkdir(parents=True, exist_ok=True)

        my_env = os.environ.copy()
        my_env["HOME"] = d.getVar("WORKDIR") + "/home" 
        my_env["PVR_DISABLE_SELFUPGRADE"] = "true"
        Path(d.getVar("WORKDIR") + "/tmp").mkdir(exist_ok=True)
        my_env["TMPDIR"] = d.getVar("WORKDIR") + "/tmp"

        images.append("bsp-" + d.getVar("PVBSP_IMAGE"))
        versionsuffix = d.getVar("IMAGE_VERSION_SUFFIX")

        for img in images:
            if factory is True:
                shutil.copy2(deployimg + "/" + img + ".pvrexport.tgz", d.getVar("IMAGE_ROOTFS") + "/factory-pkgs.d/")
            else:
                part=img
                if part == "bsp-" + d.getVar("PVBSP_IMAGE"):
                    part="bsp"

                imgpath = tmpdir + "/" + img + versionsuffix + ".pvrexport"
                Path(imgpath).mkdir(exist_ok=True)
                process = subprocess.run(
                    ['tar', '-C', imgpath, '-xf', deployimg + '/' + img + '.pvrexport.tgz' ],
                    cwd=Path(tmpdir),
                    env=my_env
                )
                process = subprocess.run(
                    ['pvr', 'deploy', deployrootfs,
                     imgpath + '#'+part ],
                    cwd=Path(tmpdir),
                    env=my_env
                )


def do_rootfs_mixing(d):
    images = d.getVar("PVROOT_IMAGES_CORE").split()
    _pvr_pvroot_images_deploy(d, False, images)
    images = d.getVar("PVROOT_IMAGES").split()
    _pvr_pvroot_images_deploy(d, True, images)

do_rootfs[dirs] += " ${WORKDIR}/tmp "
do_rootfs[cleandirs] += " ${WORKDIR}/tmp "

fakeroot python do_rootfs(){
    from pathlib import Path
    from oe.utils import execute_pre_post_process
    import shutil

    testfile = d.getVar("IMAGE_ROOTFS") + "/test"
    Path(d.getVar("IMAGE_ROOTFS") + "/boot").mkdir(parents=True, exist_ok=True)
    Path(d.getVar("IMAGE_ROOTFS") + "/config").mkdir(parents=True, exist_ok=True)
    Path(d.getVar("IMAGE_ROOTFS") + "/factory-pkgs.d").mkdir(parents=True, exist_ok=True)
    Path(d.getVar("IMAGE_ROOTFS") + "/trails").mkdir(parents=True, exist_ok=True)
    Path(d.getVar("IMAGE_ROOTFS") + "/objects").mkdir(parents=True, exist_ok=True)
    Path(d.getVar("IMAGE_ROOTFS") + "/trails/0").mkdir(parents=True, exist_ok=True)
    Path(d.getVar("IMAGE_ROOTFS") + "/trails/0/.pvr").mkdir(parents=True, exist_ok=True)
    Path(d.getVar("IMAGE_ROOTFS") + "/trails/0/.pv").mkdir(parents=True, exist_ok=True)
    Path(d.getVar("IMAGE_ROOTFS") + "/trails/0/.pv/README").write_text('hardlinks to artifacts loaded by bootloader')
    Path(d.getVar("IMAGE_ROOTFS") + "/logs").mkdir(parents=True, exist_ok=True)
    shutil.copy2(Path(d.getVar("THISDIR") + "/files/empty.json"), d.getVar("IMAGE_ROOTFS") + "/trails/0/.pvr/json")
    shutil.copy2(Path(d.getVar("THISDIR") + "/files/pvrconfig"), d.getVar("IMAGE_ROOTFS") + "/trails/0/.pvr/config")
    shutil.copy2(Path(d.getVar("THISDIR") + "/files/uboot.txt"), d.getVar("IMAGE_ROOTFS") + "/boot/uboot.txt")
    do_rootfs_mixing(d)

    execute_pre_post_process(d, d.getVar('PVROOTFS_POSTPROCESS_COMMAND'))
}
