pkgname='tuxedo-systeminfos'
pkgver='20251103.1'
pkgrel='1'
pkgdesc='TUXEDO Systeminfos Script'
arch=(any)
url='https://gitlab.com/tuxedocomputers/development/packages/fixes/tuxedo-systeminfos'
license=('GPL-3.0-or-later')
depends=('curl, edid-decode, efibootmgr, jq, lm-sensors, mesa-utils, nvme-cli, zip')

source=('files.tar.gz')
sha512sums=('SKIP')

install='pkg.install'

package() {
  cp -r  ${srcdir}/files/* ${pkgdir}/
}
