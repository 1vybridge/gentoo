# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools libtool xdg-utils

DESCRIPTION="A sophisticated ftp/sftp/http/https/torrent client and file transfer program"
HOMEPAGE="http://lftp.yar.ru/"
SRC_URI="https://github.com/lavv17/${PN}/releases/download/v${PV}/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~alpha amd64 arm ~arm64 ~hppa ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos"
IUSE="convert-mozilla-cookies +gnutls idn nls socks5 +ssl verify-file"
RESTRICT="test"

RDEPEND="
	>=sys-libs/ncurses-5.1:=
	>=sys-libs/readline-5.1:=
	dev-libs/expat
	sys-libs/zlib
	convert-mozilla-cookies? ( dev-perl/DBI )
	idn? ( net-dns/libidn2:= )
	socks5? (
		>=net-proxy/dante-1.1.12
		sys-libs/pam
	)
	ssl? (
		gnutls? ( >=net-libs/gnutls-1.2.3:0= )
		!gnutls? ( dev-libs/openssl:0= )
	)
	verify-file? (
		dev-perl/String-CRC32
		virtual/perl-Digest-MD5
	)
"

DEPEND="
	${RDEPEND}
	=dev-build/libtool-2*
	app-arch/xz-utils
	nls? ( >=sys-devel/gettext-0.21 )
	virtual/pkgconfig
"

DOCS=(
	BUGS ChangeLog FAQ FEATURES MIRRORS NEWS README README.debug-levels
	README.dnssec README.modules THANKS TODO
)

PATCHES=(
	"${FILESDIR}"/${PN}-4.0.2.91-lafile.patch
	"${FILESDIR}"/${PN}-4.7.5-libdir-additional.patch
	"${FILESDIR}"/${PN}-4.7.5-libdir-expat.patch
	"${FILESDIR}"/${PN}-4.8.2-libdir-configure.patch
	"${FILESDIR}"/${PN}-4.8.2-libdir-libidn2.patch
	"${FILESDIR}"/${PN}-4.8.2-libdir-openssl.patch
	"${FILESDIR}"/${PN}-4.8.2-libdir-zlib.patch
	"${FILESDIR}"/${PN}-4.9.1-libdir-readline.patch
	"${FILESDIR}"/${PN}-4.9.2-socks.patch
	"${FILESDIR}"/${PN}-4.9.3-gnulib.patch
	"${FILESDIR}"/${PN}-4.9.3-gnulib-stdlib.h.patch
)

# Gnulib false positive #900064
QA_CONFIG_IMPL_DECL_SKIP="( MIN )"

src_prepare() {
	default

	# bug #875692
	sed -e '/#include/s/cmath/math.h/' -i trio/*.c || die

	eautoreconf

	elibtoolize # for Darwin bundles

	# bug #536036
	printf 'set fish:auto-confirm no\nset sftp:auto-confirm no\n' >> ${PN}.conf || die
}

src_configure() {
	econf \
		$(use_enable nls) \
		$(use_with idn libidn2) \
		$(use_with socks5 socksdante "${EPREFIX}"/usr) \
		$(usex ssl "$(use_with !gnutls openssl "${EPREFIX}"/usr)" '--without-openssl') \
		$(usex ssl "$(use_with gnutls)" '--without-gnutls') \
		--enable-ipv6 \
		--enable-packager-mode \
		--sysconfdir="${EPREFIX}"/etc/${PN} \
		--with-modules \
		--with-readline="${EPREFIX}"/usr \
		--without-included-regex
}

src_install() {
	default

	local script
	for script in {convert-mozilla-cookies,verify-file}; do
		use ${script} || { rm "${ED}"/usr/share/${PN}/${script} || die ;}
	done
}

pkg_postinst() {
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_icon_cache_update
}
