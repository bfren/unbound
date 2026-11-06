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

Every image is built for `linux/amd64`, `linux/arm64` and `linux/arm/v7`.

## Tags

Images are published to `quay.io/bfren-bin/unbound`:

| Tag               | Example           |
| ----------------- | ----------------- |
| `UNBOUND-VERSION` | `1.26.2-261106.2` |

`VERSION` is the build date (`yymmdd`) in [VERSION](VERSION) - pin it to get exactly the same files every
time. Builds from any branch other than `main` add `-dev` to every tag.

## Adding a release

1. Download `unbound-X.Y.Z.tar.gz` and `unbound-X.Y.Z.tar.gz.sha256` from
   [NLnet Labs](https://nlnetlabs.nl/projects/unbound/download/) into [src](src).
2. Update the `UNBOUND` default in [Dockerfile](Dockerfile) and [test.sh](test.sh), the `unbound` matrix in the
   [build workflow](.github/workflows/build-alpine.yml), and the matrix above.
3. Set [VERSION](VERSION) to today's date (`yymmdd`, or `yymmdd.2`, `.3` and so on for another release that day),
   then run `./test.sh`.
4. Push the branch, which builds `-dev` tags to test with, then merge into `main`, which builds the release (it
   refuses to overwrite a tag that already exists).

## Usage

You can find a live example in my [Unbound Docker image](https://github.com/bfren/docker-unbound).

```Dockerfile
# load the Unbound files - they are built for (and dynamically linked against) Alpine 3.24
FROM quay.io/bfren-bin/unbound:1.26.2-261106.2 AS unbound

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

## Copyright

> Copyright (c) 2026 bfren (unless otherwise stated)
