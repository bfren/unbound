# Unbound

[Unbound](https://nlnetlabs.nl/projects/unbound/about/) compiled for Alpine, so my
[Unbound Docker image](https://github.com/bfren/docker-unbound) can run the latest release - Alpine's stable
branches keep the version they shipped with, and only backport some security fixes.

- **Config:** Alpine's `configure` options, without the features my image does not use (Python, the Redis
  cache and dnstap) - see [build.sh](build.sh).
- **Linking:** dynamically linked against Alpine's libraries, so their security fixes still come from Alpine.
  The build log lists the shared libraries Unbound needs - install them in the image that uses these files.
- **Verification:** every build checks the source tarball against the SHA-256 checksum published by NLnet Labs,
  and checks the built `unbound` reports the expected version.

## Matrix

| Unbound    | Alpine 3.24 |
| ---------- | :---------: |
| **1.26.2** | &check;     |

## Adding a release

1. Download `unbound-X.Y.Z.tar.gz` and `unbound-X.Y.Z.tar.gz.sha256` from
   [NLnet Labs](https://nlnetlabs.nl/projects/unbound/download/) into [src](src).
2. Update the `UNBOUND` default in [Dockerfile](Dockerfile) and [test.sh](test.sh), the workflow
   and the matrix above.
3. Set [VERSION](VERSION) to today's date (`yymmdd`), then run `./test.sh` and the `build-alpine` workflow.

## Usage

You can find a live example in my [Unbound Docker image](https://github.com/bfren/docker-unbound).

```Dockerfile
# use tags to load the Unbound files - they are built for (and dynamically linked against) Alpine 3.24
FROM quay.io/bfren-bin/unbound:1.26.2-261021 AS unbound

# load the same version of Alpine
FROM alpine:3.24

# copy Unbound files to /
COPY --from=unbound / /

# install the libraries Unbound needs, and the DNSSEC root trust anchor
RUN apk add dnssec-root libcrypto3 libevent libexpat libssl3 nghttp2-libs

# rest of Dockerfile - e.g. add the unbound user
```

## Licence

The build scripts in this repository are released under the [MIT licence](https://mit.bfren.dev/2026).

Unbound is licensed under the [BSD 3-Clause licence](https://github.com/NLnetLabs/unbound/blob/master/LICENSE).
The Unbound source in [src](src) and the files in the published images are covered by that licence.
