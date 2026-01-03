# Maintainer: Your Name <your.email@example.com>
pkgname=dracut-cryptsetup-duress
pkgver=0.1.0
pkgrel=1
pkgdesc="Dracut module for duress password protection with cryptsetup"
arch=('any')
url="https://github.com/melody0123/dracut-cryptsetup-duress"
license=('GPL3')
depends=('dracut' 'cryptsetup')
makedepends=('git')
source=("${pkgname}-${pkgver}.tar.gz::https://github.com/melody0123/${pkgname}/archive/refs/tags/v${pkgver}.tar.gz")
sha256sums=('SKIP')

package() {
  cd "${pkgname}-${pkgver}"

  mkdir -p "${pkgdir}/usr/lib/dracut/modules.d/99duress"
  mkdir -p "${pkgdir}/usr/bin"

  install -Dm755 src/duressctl "${pkgdir}/usr/bin/duressctl"

  cp src/99duress/*.sh "${pkgdir}/usr/lib/dracut/modules.d/99duress/"
  chmod 755 "${pkgdir}/usr/lib/dracut/modules.d/99duress/"*.sh

  cp src/99duress/*.service "${pkgdir}/usr/lib/dracut/modules.d/99duress/"
  chmod 644 "${pkgdir}/usr/lib/dracut/modules.d/99duress/"*.service

  install -Dm644 README.md "${pkgdir}/usr/share/doc/${pkgname}/README.md"
  install -Dm644 LICENSE "${pkgdir}/usr/share/licenses/${pkgname}/LICENSE"
}
