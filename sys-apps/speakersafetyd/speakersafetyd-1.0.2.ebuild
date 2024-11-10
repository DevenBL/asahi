# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Autogenerated by pycargoebuild 0.13.3

EAPI=8

CRATES="
	alsa-sys@0.3.1
	alsa@0.9.1
	android-tzdata@0.1.1
	android_system_properties@0.1.5
	anstream@0.6.15
	anstyle-parse@0.2.5
	anstyle-query@1.1.1
	anstyle-wincon@3.0.4
	anstyle@1.0.8
	autocfg@1.3.0
	bitflags@2.6.0
	bumpalo@3.16.0
	cc@1.1.14
	cfg-if@1.0.0
	chrono@0.4.38
	clap-verbosity-flag@2.2.1
	clap@4.5.16
	clap_builder@4.5.15
	clap_derive@4.5.13
	clap_lex@0.7.2
	colorchoice@1.0.2
	colored@2.1.0
	configparser@3.1.0
	core-foundation-sys@0.8.7
	deranged@0.3.11
	equivalent@1.0.1
	hashbrown@0.14.5
	heck@0.5.0
	iana-time-zone-haiku@0.1.2
	iana-time-zone@0.1.60
	indexmap@2.4.0
	is_terminal_polyfill@1.70.1
	itoa@1.0.11
	js-sys@0.3.70
	json@0.12.4
	lazy_static@1.5.0
	libc@0.2.158
	log@0.4.22
	num-conv@0.1.0
	num-traits@0.2.19
	num_threads@0.1.7
	once_cell@1.19.0
	pkg-config@0.3.30
	powerfmt@0.2.0
	proc-macro2@1.0.86
	quote@1.0.37
	serde@1.0.209
	serde_derive@1.0.209
	shlex@1.3.0
	signal-hook-registry@1.4.2
	signal-hook@0.3.17
	simple_logger@4.3.3
	strsim@0.11.1
	syn@2.0.76
	time-core@0.1.2
	time-macros@0.2.18
	time@0.3.36
	unicode-ident@1.0.12
	utf8parse@0.2.2
	wasm-bindgen-backend@0.2.93
	wasm-bindgen-macro-support@0.2.93
	wasm-bindgen-macro@0.2.93
	wasm-bindgen-shared@0.2.93
	wasm-bindgen@0.2.93
	windows-core@0.52.0
	windows-sys@0.48.0
	windows-sys@0.52.0
	windows-targets@0.48.5
	windows-targets@0.52.6
	windows_aarch64_gnullvm@0.48.5
	windows_aarch64_gnullvm@0.52.6
	windows_aarch64_msvc@0.48.5
	windows_aarch64_msvc@0.52.6
	windows_i686_gnu@0.48.5
	windows_i686_gnu@0.52.6
	windows_i686_gnullvm@0.52.6
	windows_i686_msvc@0.48.5
	windows_i686_msvc@0.52.6
	windows_x86_64_gnu@0.48.5
	windows_x86_64_gnu@0.52.6
	windows_x86_64_gnullvm@0.48.5
	windows_x86_64_gnullvm@0.52.6
	windows_x86_64_msvc@0.48.5
	windows_x86_64_msvc@0.52.6
"

inherit cargo udev

DESCRIPTION="Speaker protection daemon for embedded Linux systems"
HOMEPAGE="https://github.com/AsahiLinux/speakersafetyd/"
SRC_URI="https://github.com/AsahiLinux/speakersafetyd/archive/refs/tags/${PV}.tar.gz -> ${PN}-${PV}.tar.gz
${CARGO_CRATE_URIS}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="arm64"

DEPEND="
	media-libs/alsa-ucm-conf-asahi
"
RDEPEND="${DEPEND}"

QA_FLAGS_IGNORED="usr/bin/${PN}"

src_install() {
	cargo_src_install
	emake DESTDIR="${D}" install-data
	doinitd "${FILESDIR}/speakersafetyd"
}

pkg_postinst() {
	udev_reload
}

pkg_postrm() {
	udev_reload
}
