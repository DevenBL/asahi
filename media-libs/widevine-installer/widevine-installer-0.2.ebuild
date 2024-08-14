# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_HASH="eab8c668ad3f9db27a444ee1f94b82d8f3ab5336"

DESCRIPTION="Widevine installer for AArch64 systems"
HOMEPAGE="https://asahilinux.org/"

SRC_URI="https://github.com/AsahiLinux/widevine-installer/archive/${MY_HASH}.tar.gz -> ${PN}-${PV}.tar.gz"

LICENSE="MIT"
SLOT=0

KEYWORDS="arm64"

# Widevine only works with glibc 2.36 or above
RDEPEND="
	>=sys-libs/glibc-2.36
	sys-fs/squashfs-tools[zstd]
"

PATCHES="${FILESDIR}/disable-configs.patch"

src_unpack() {
	default
	mv "${PN}-${MY_HASH}" "${PN}-${PV}"
}

src_install() {
	dodir /opt/widevine-installer/

	keepdir /opt/widevine/WidevineCdm/
	insinto /usr/"$(get_libdir)"/chromium-browser/
	dosym -r /opt/widevine/WidevineCdm/ /usr/lib64/chromium-browser/WidevineCdm

	insinto /etc/profile.d/
	doins "${S}"/conf/gmpwidevine.sh

	insinto /usr/"$(get_libdir)"/firefox/defaults/pref/
	doins "${S}"/conf/gmpwidevine.js

	insinto /usr/libexec/widevine-installer/
	doins "${S}"/widevine_fixup.py

	exeinto /opt/widevine-installer/
	doexe "${S}"/widevine-installer

	dosym -r /opt/widevine-installer/widevine-installer /opt/bin/widevine-installer
}

pkg_postinst() {
	ewarn "Widevine has NOT been installed. You need to run /opt/bin/widevine-installer."
}
