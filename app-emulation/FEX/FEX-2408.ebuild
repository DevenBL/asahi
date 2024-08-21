# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit flag-o-matic cmake toolchain-funcs

DESCRIPTION="A fast usermode x86 and x86-64 emulator for Arm64 Linux"
HOMEPAGE="https://fex-emu.com"

JEMALLOC_HASH="7ae889695b8bebdc67c004c2c9c8d2e57748d2ab"
JEMALLOC_GLIBC_HASH="888181c5f7072ab1bd7aa7aca6d9f85816a95c43"
# TODO: unvendor this when this version will be available in gentoo
FMTLIB_V="10.1.1"
CPP_OPTPARSE_HASH="eab4212ae864ba64306f0fe87f102e66cb5a3617"
# TODO: The following two will be hard-vendored in next release, drop them then.
JSON_MAKER_HASH="8ecb8ecc348bf88c592fac808c03efb342f69e0a"
TINY_JSON_HASH="9d09127f87ea6a128fb17d1ffd0b444517343f1c"
# TODO: This would be possible to unvendor in the next release
VIXL_HASH="a90f5d5020c305d03d3182dcc90a31321cc7a661"
ROBIN_MAP_HASH="f1ab6900466891af11e3c264c63acf1dd9c3532c"
# TODO: Unvendor and replace this with Qt in next release
IMGUI_HASH="4c986ecb8d2807087fd8e34894d1e7a138bc2f1d"
# This need to be vendored since thunk generator does not support the latest version
VULKAN_HEADERS_HASH="31aa7f634b052d87ede4664053e85f3f4d1d50d3"

SRC_URI="
	https://github.com/FEX-Emu/jemalloc/archive/${JEMALLOC_HASH}.tar.gz -> jemalloc-${JEMALLOC_HASH}.tar.gz
	https://github.com/FEX-Emu/jemalloc/archive/${JEMALLOC_GLIBC_HASH}.tar.gz -> jemalloc-glibc-${JEMALLOC_GLIBC_HASH}.tar.gz
	https://github.com/fmtlib/fmt/archive/refs/tags/${FMTLIB_V}.tar.gz -> libfmt-${FMTLIB_V}.tar.gz
	https://github.com/Sonicadvance1/cpp-optparse/archive/${CPP_OPTPARSE_HASH}.tar.gz -> cpp-optparse-${CPP_OPTPARSE_HASH}.tar.gz
	https://github.com/Sonicadvance1/json-maker/archive/${JSON_MAKER_HASH}.tar.gz -> json-maker-${JSON_MAKER_HASH}.tar.gz
	https://github.com/Sonicadvance1/tiny-json/archive/${TINY_JSON_HASH}.tar.gz -> tiny-json-${TINY_JSON_HASH}.tar.gz
	https://github.com/FEX-Emu/vixl/archive/${VIXL_HASH}.tar.gz -> vixl-${VIXL_HASH}.tar.gz
	https://github.com/FEX-Emu/robin-map/archive/${ROBIN_MAP_HASH}.tar.gz -> robin-map-${ROBIN_MAP_HASH}.tar.gz
	https://github.com/Sonicadvance1/imgui/archive/${IMGUI_HASH}.tar.gz -> imgui-${IMGUI_HASH}.tar.gz
	thunks? (
		https://github.com/KhronosGroup/Vulkan-Headers/archive/${VULKAN_HEADERS_HASH}.tar.gz -> Vulkan-Headers-${VULKAN_HEADERS_HASH}.tar.gz
	)
	https://github.com/FEX-Emu/${PN}/archive/refs/tags/${P}.tar.gz
"

S="${WORKDIR}/${PN}-${P}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="-* ~arm64"
BDEPEND="
	sys-devel/clang
	sys-devel/llvm
	thunks? ( !crossdev-toolchain? (
		sys-devel/x86_64-multilib-toolchain
	) )
"
RDEPEND="
	dev-libs/xxhash
	X? (
		media-libs/libsdl2
		media-libs/libglvnd
		media-libs/libepoxy
		x11-libs/libX11
	)
	thunks? (
		x11-libs/libX11
		x11-libs/libdrm
		dev-libs/wayland
		media-libs/alsa-lib
		media-libs/libglvnd
		x11-libs/libxcb
	)
"
DEPEND="
	>=sys-kernel/linux-headers-6.8
	${RDEPEND}
"

PATCHES="
	${FILESDIR}/${P}-unvendor-xxhash.patch
	${FILESDIR}/${P}-unvendor-drm-headers.patch
	${FILESDIR}/${P}-tiny-json-as-static.patch
	${FILESDIR}/${P}-fmt-as-static.patch
	${FILESDIR}/${P}-json-maker-as-static.patch
	${FILESDIR}/${P}-imgui-as-static.patch
	${FILESDIR}/${PN}-thunks-toolchain-paths.patch
"

IUSE="X +thunks crossdev-toolchain"

REQUIRED_USE="crossdev-toolchain? ( thunks )"

my-test-flag-PROG() {
	local comp=$1
	local lang=$2
	shift 2

	if [[ -z $1 ]]; then
		return 1
	fi

	if ! type -p ${comp[0]} >/dev/null; then
		return 1
	fi

	local in_src in_ext cmdline_extra=()
	case "${lang}" in
		c)
			in_ext='c'
			in_src='int main(void) { return 0; }'
			cmdline_extra+=(-xc -c)
			;;
		c++)
			in_ext='cc'
			in_src='int main(void) { return 0; }'
			cmdline_extra+=(-xc++ -c)
			;;
	esac
	local test_in=${T}/test-flag.${in_ext}
	local test_out=${T}/test-flag.exe

	printf "%s\n" "${in_src}" > "${test_in}" || die "Failed to create '${test_in}'"
	local cmdline=(
		"${comp[@]}"
		-Werror
		"$@"
		"${cmdline_extra[@]}"
		"${test_in}" -o "${test_out}"
	)

	"${cmdline[@]}" &>/dev/null
}

my-test-flags-PROG() {
	local comp=$1
	local lang=$2
	local flags=()
	local x

	shift 2

	while (( $# )); do
		case "$1" in
			--param|-B)
				if my-test-flag-PROG ${comp} ${lang} "$1" "$2"; then
					flags+=( "$1" "$2" )
				fi
				shift 2
				;;
			*)
				if my-test-flag-PROG ${comp} ${lang} "$1"; then
					flags+=( "$1" )
				fi
				shift 1
				;;
		esac
	done

	echo "${flags[*]}"
	[[ ${#flags[@]} -gt 0 ]]
}

my-filter-var() {
	local f x var=$1 new=()
	shift

	for f in ${!var} ; do
		for x in "$@" ; do
			[[ ${f} == ${x} ]] && continue 2
		done
		new+=( "${f}" )
	done
	export ${var}="${new[*]}"
}

THUNK_INC_DIR="${WORKDIR}/thunk-include"

find_compiler() {
	(
		pattern="$1"
		shift
		shopt -s nullglob
		IFS=: read -r -a paths <<<"$PATH"
		for dir in "${paths[@]}"; do
			for cand in "$dir"/$pattern; do
				"${cand}" -o /dev/null -x c "$@" - 2>/dev/null >/dev/null <<<'int main(){}' && echo "${cand#/${dir}}" && return 0
			done
		done
		return 1
	)
}

pkg_pretend() {
	[[ ${MERGE_TYPE} == binary ]] && return
	use thunks || return
	use crossdev-toolchain || return
	errmsg="Unable to find a working ARCH compiler on your system. You need to install one using crossdev."
	find_compiler 'x86_64*-linux-gnu-gcc' >/dev/null || die "${errmsg/ARCH/x86_64}"
	find_compiler 'i?86*-linux-gnu-gcc' >/dev/null || find_compiler 'x86_64*-linux-gnu-gcc' -m32 >/dev/null || die "${errmsg/ARCH/i686}"
}

src_unpack() {
	default
	local -A deps=(
		jemalloc "jemalloc-${JEMALLOC_HASH}"
		jemalloc_glibc "jemalloc-${JEMALLOC_GLIBC_HASH}"
		fmt "fmt-${FMTLIB_V}"
		json-maker "json-maker-${JSON_MAKER_HASH}"
		tiny-json "tiny-json-${TINY_JSON_HASH}"
		vixl "vixl-${VIXL_HASH}"
		robin-map "robin-map-${ROBIN_MAP_HASH}"
		imgui "imgui-${IMGUI_HASH}"
	)
	use thunks && deps[Vulkan-Headers]="Vulkan-Headers-${VULKAN_HEADERS_HASH}"
	for dep in "${!deps[@]}"; do
		rmdir "${S}/External/${dep}" || die
		mv "${WORKDIR}/${deps[${dep}]}" "${S}/External/${dep}"
	done
	rmdir "${S}/Source/Common/cpp-optparse" || die
	mv "${WORKDIR}/cpp-optparse-${CPP_OPTPARSE_HASH}" "${S}/Source/Common/cpp-optparse" || die
}

THUNK_HEADERS="
	GL
	EGL
	GLES
	GLES2
	GLES3
	KHR
	glvnd
	wayland-client-core.h
	wayland-client-protocol.h
	wayland-client.h
	wayland-cursor.h
	wayland-egl-backend.h
	wayland-egl-core.h
	wayland-egl.h
	wayland-server-core.h
	wayland-server-protocol.h
	wayland-server.h
	wayland-util.h
	wayland-version.h
	X11
	libdrm
	libsync.h
	xf86drm.h
	xf86drmMode.h
	alsa
	xcb
"

src_prepare() {
	cmake_src_prepare
	sed -i -e "s:__REPLACE_ME_WITH_HEADER_DIR__:${THUNK_INC_DIR}:" ThunkLibs/GuestLibs/CMakeLists.txt || die
	mkdir "${THUNK_INC_DIR}" || die
	for header in $THUNK_HEADERS; do
		cp -a "${BROOT}/usr/include/${header}" "${THUNK_INC_DIR}/${header}" || die
	done
}

src_configure() {
	if ! tc-is-clang ; then
		AR=llvm-ar
		CC=clang
		CXX=clang++
		NM=llvm-nm
		RANLIB=llvm-ranlib
		STRIP=llvm-strip

		strip-unsupported-flags
	fi

	use crossdev-toolchain || PATH="${BROOT}/usr/lib/x86_64-multilib-toolchain/bin:${PATH}"

	local x64_cc="$(find_compiler 'x86_64*-linux-gnu-gcc' || die)"
	local x86_cc
	if x86_cc="$(find_compiler 'x86_64*-linux-gnu-gcc' -m32)"; then
		x86_cc="${x86_cc} -m32"
	else
		x86_cc="$(find_compiler 'i?86*-linux-gnu-gcc' || die)"
	fi

	sed -i -e "s:__REPLACE_ME_WITH_C_COMPILER__:${x64_cc}:" toolchain_x86_64.cmake || die
	sed -i -e "s:__REPLACE_ME_WITH_C_COMPILER__:${x86_cc}:" toolchain_x86_32.cmake || die
	sed -i -e "s:__REPLACE_ME_WITH_CXX_COMPILER__:${x64_cc/linux-gnu-gcc/linux-gnu-g++}:" toolchain_x86_64.cmake || die
	sed -i -e "s:__REPLACE_ME_WITH_CXX_COMPILER__:${x86_cc/linux-gnu-gcc/linux-gnu-g++}:" toolchain_x86_32.cmake || die

	export X86_CFLAGS="$(my-test-flags-PROG ${x64_cc/%gcc/cc} c ${CFLAGS})"
	export X86_CXXFLAGS="$(my-test-flags-PROG ${x64_cc/%gcc/c++} c++ ${CXXFLAGS})"

	my-filter-var X86_CFLAGS '-flto*' -fwhole-program-vtables '-fsanitize=cfi*'
	my-filter-var X86_CXXFLAGS '-flto*' -fwhole-program-vtables '-fsanitize=cfi*'

	tc-export CC CXX LD AR NM OBJDUMP RANLIB PKG_CONFIG

	local mycmakeargs=(
		-DBUILD_TESTS=False
		-DENABLE_CCACHE=False
		-DENABLE_LTO=$(if tc-is-lto; then echo True; else echo False; fi)
		-DBUILD_FEXCONFIG=$(usex X True False)
		-DBUILD_THUNKS=$(usex thunks True False)
		-DX86_CFLAGS="${X86_CFLAGS}"
		-DX86_CXXFLAGS="${X86_CXXFLAGS}"
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install
	tc-is-lto && dostrip -x /usr/lib/libFEXCore.a
	use thunks && dostrip -x /usr/share/fex-emu/GuestThunks{,_32}/
	rm "${ED}/usr/share/man/man1/FEX.1.gz" || die
}
