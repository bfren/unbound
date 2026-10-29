ARG ALPINE=3.24.3

# use target Alpine version as host
FROM alpine:${ALPINE} AS build

# define ARGS
ARG UNBOUND=1.26.2

# install prerequisites
RUN apk add build-base expat-dev libevent-dev linux-headers nghttp2-dev "openssl-dev>3" pax-utils

# copy script files and source
WORKDIR /tmp
COPY ./verify.sh ./build.sh ./
COPY ./src/unbound-${UNBOUND}.tar.gz ./src/unbound-${UNBOUND}.tar.gz.sha256 ./
RUN chmod +x ./*.sh

# verify source, build and install to /out
RUN ./build.sh ${UNBOUND}

# create blank image with only the installed Unbound files
FROM scratch AS final
COPY --from=build /out /
