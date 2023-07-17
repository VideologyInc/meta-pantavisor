DESCRIPTION = "This is a simple example recipe that cross-compiles a Go program."
SECTION = "pantavisor"
HOMEPAGE = "https://golang.org/"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "git://${GO_IMPORT};branch=bugfix/no-fakeroot-if-root;protocol=https"
SRCREV = "3643b9882e273d824419aac663ab2f9132fe3c79"
UPSTREAM_CHECK_COMMITS = "1"

# DEPENDS:append = "fakeroot-native"

GO_IMPORT = "gitlab.com/pantacor/pvr"
export GO111MODULE="on"

CGO_ENABLED = "0"

inherit go-mod native

do_compile[network] = "1"

BBCLASSEXTEND = "native nativesdk"
