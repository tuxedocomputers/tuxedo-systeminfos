options=(!debug !lto) # No debug or LTO packages

pkgname='tuxedo-systeminfos'
pkgver='20260216.1.0'
pkgrel='1'
pkgdesc='TUXEDO Systeminfos Script'
arch=(any)
url='https://gitlab.com/tuxedocomputers/development/systeminfos-script'
license=('GPL-2.0-only')
depends=('curl, edid-decode, efibootmgr, jq, lm-sensors, mesa-utils, nvme-cli, zip')
optdepends=()
conflicts=()
replaces=()

source=('files.tar.gz')
sha512sums=('SKIP')

install='.INSTALL'

package() {
  cp -r  ${srcdir}/files/* ${pkgdir}/
}
