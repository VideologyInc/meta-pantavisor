
DEPENDS:append = " pvr-native squashfs-tools-native "

PVR_COMPRESSION ?= "-comp xz"

PVSTATE = "${WORKDIR}/pvstate"
PVMODS = "${WORKDIR}/mods"

DEPENDS:append = " pvr-native "

INITRAMFS_IMAGE = "pantavisor-bsp"

