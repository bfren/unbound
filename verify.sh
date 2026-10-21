#!/bin/sh

set -eu

# script receives one argument: the Unbound version
UNBOUND=${1}
FILE=unbound-${UNBOUND}.tar.gz

# verify the source tarball matches the SHA-256 checksum published by NLnet Labs
EXPECTED=$(cut -d ' ' -f 1 < ${FILE}.sha256 | tr -d '[:space:]')
ACTUAL=$(sha256sum ${FILE} | cut -d ' ' -f 1)
[ "${EXPECTED}" = "${ACTUAL}" ] || {
    echo "Checksum mismatch for ${FILE}: expected ${EXPECTED}, got ${ACTUAL}" >&2
    exit 1
}

echo "Verified ${FILE}"
