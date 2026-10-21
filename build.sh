#!/bin/sh

set -eu

# script receives one argument: the Unbound version
UNBOUND=${1}

# verify and extract source
./verify.sh ${UNBOUND}
tar -xf unbound-${UNBOUND}.tar.gz
cd unbound-${UNBOUND}

# configure using Alpine's options, without the features this image does not use (Python, Redis cache, dnstap)
./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --enable-pie \
    --enable-relro-now \
    --enable-subnet \
    --with-username=unbound \
    --with-run-dir="" \
    --with-pidfile="" \
    --with-rootkey-file=/usr/share/dnssec-root/trusted-key.key \
    --with-libevent \
    --with-pthreads \
    --with-ssl \
    --with-libnghttp2 \
    --disable-static \
    --disable-rpath \
    --disable-dsa \
    --disable-gost \
    --without-pythonmodule \
    --without-pyunbound

# build Unbound and install to /out
make
make DESTDIR=/out install

# remove development files and documentation, and strip executables
cd /out
rm -rf usr/include usr/lib/pkgconfig usr/lib/*.la usr/share/man
strip --strip-unneeded \
    usr/sbin/unbound \
    usr/sbin/unbound-anchor \
    usr/sbin/unbound-checkconf \
    usr/sbin/unbound-control \
    usr/sbin/unbound-host \
    usr/lib/libunbound.so.*

# list the shared libraries Unbound needs - images using these files must install them
echo "Shared libraries needed:"
scanelf --nobanner --format '%n' usr/sbin/* usr/lib/libunbound.so.* | tr ',' '\n' | sort -u

# check Unbound runs and reports the expected version
LD_LIBRARY_PATH=/out/usr/lib /out/usr/sbin/unbound -V | grep -q "Version ${UNBOUND}" || {
    echo "Unbound does not report version ${UNBOUND}" >&2
    exit 1
}

echo "Built Unbound ${UNBOUND}"
