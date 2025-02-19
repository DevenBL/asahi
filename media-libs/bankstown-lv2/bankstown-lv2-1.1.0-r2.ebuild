# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Auto-Generated by cargo-ebuild 0.5.4

EAPI=8

CRATES="
	biquad@0.4.2
	libm@0.1.4
	lv2@0.6.0
	lv2-atom@2.0.0
	lv2-core@3.0.0
	lv2-core-derive@2.1.1
	lv2-midi@1.2.0
	lv2-sys@2.0.0
	lv2-units@0.1.3
	lv2-urid@2.1.0
	proc-macro2@1.0.69
	quote@1.0.33
	syn@1.0.109
	unicode-ident@1.0.12
	urid@0.1.0
	urid-derive@0.1.1
	wmidi@3.1.0
"

RUST_MIN_VER="1.72.0"

inherit cargo

DESCRIPTION="A barebones, fast LV2 bass enhancement plugin"
# Double check the homepage as the cargo_metadata crate
# does not provide this value so instead repository is used
HOMEPAGE="https://github.com/chadmed/bankstown"
SRC_URI="https://github.com/chadmed/bankstown/archive/refs/tags/${PV}.tar.gz -> ${PN}-${PV}.tar.gz ${CARGO_CRATE_URIS}"
S="${WORKDIR}/bankstown-${PV}"

# License set may be more restrictive as OR is not respected
# use cargo-license for a more accurate license picture
LICENSE="MIT"
SLOT="0"
KEYWORDS="arm64"

DEPEND="
media-libs/lv2
"
RDEPEND="${DEPEND}"

# rust does not use *FLAGS from make.conf, silence portage warning
# update with proper path to binaries this crate installs, omit leading /
QA_FLAGS_IGNORED="usr/bin/${PN}"

# cargo.eclass now builds arch-specific targets
src_prepare() {
	sed -i \
		-e "s|target/release|$(cargo_target_dir)|" Makefile || die
	default
}

src_configure() {
	cargo_src_configure
}

src_install() {
	emake DESTDIR="${D}" LIBDIR="/usr/$(get_libdir)" install || die
}
