ARG OUTPUT=/output
FROM alpine:edge AS builder
RUN apk add --no-cache \
    autoconf \
    automake \
    binutils \
    cmake \
    curl \
    dpkg \
    file \
    g++ \
    gcc \
    git \
    libc6-compat \
    libdrm-dev \
    libtool \
    libxshmfence \
    linux-headers \
    make \
    mesa-va-gallium \
    musl-dev \
    nghttp2-dev \
    pkgconfig \
    xxd

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FROM builder AS amd

ARG CFLAGS
ARG LDFLAGS
ARG MAKEFLAGS
ARG OUTPUT
ARG DESTDIR

WORKDIR /tmp/amd

RUN ls -la /usr/lib/

RUN apk add  xf86-video-amdgpu linux-firmware-amdgpu --no-cache --update-cache \
 && apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing libva-utils \
 && mkdir -p "$OUTPUT/usr/bin" \
 && cp -a /usr/bin/vainfo "$OUTPUT/usr/bin" \
 && mkdir -p "$OUTPUT/usr/lib" \
 && cp -a /usr/lib/libX*.so* "$OUTPUT/usr/lib" \
 && cp -a /usr/lib/libwayland*.so* "$OUTPUT/usr/lib" \
 && cp -a /usr/lib/libva*.so* "$OUTPUT/usr/lib" \
 && cp -a /usr/lib/libdrm*.so* "$OUTPUT/usr/lib" \
 && cp -a /usr/lib/libbsd*.so* "$OUTPUT/usr/lib" \
 && cp -a /usr/lib/libxshmfence*.so* "$OUTPUT/usr/lib" \
 # && cp -a /usr/lib/libkms*.so* "$OUTPUT/usr/lib" \
 && cp -a /usr/lib/libxcb*.so* "$OUTPUT/usr/lib" \
 && cp -a /usr/lib/libffi*.so* "$OUTPUT/usr/lib" \
 && cp -a /usr/lib/libLLVM*.so* "$OUTPUT/usr/lib" \
 && cp -a /usr/lib/libzstd*.so* "$OUTPUT/usr/lib" \
 && cp -a /usr/lib/libexpat*.so* "$OUTPUT/usr/lib" \
 && cp -a /usr/lib/libelf*.so* "$OUTPUT/usr/lib" \
 && cp -a /usr/lib/libstdc++*.so* "$OUTPUT/usr/lib" \
 && cp -a /usr/lib/libgcc_s*.so* "$OUTPUT/usr/lib" \
 && cp -a /usr/lib/libmd*.so* "$OUTPUT/usr/lib" \
 && cp -a /usr/lib/libxml2*.so* "$OUTPUT/usr/lib" \
 && mkdir -p "$OUTPUT/usr/lib/dri" \
 && cp -a /usr/lib/dri/*.so* "$OUTPUT/usr/lib/dri" \
 && mkdir -p "$OUTPUT/usr/share/libdrm" \
 && cp -a /usr/share/libdrm/* "$OUTPUT/usr/share/libdrm" \
 && cp -a /lib/ld-musl-x86_64.so.1 "$OUTPUT/usr/lib" \
 && cp -a /lib/libz*.so* "$OUTPUT/usr/lib"

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FROM ghcr.io/linuxserver/baseimage-alpine:3.15 as buildstage
ARG OUTPUT

LABEL maintainer="username"

## copy local files
COPY root/ /root-layer/

# Copy lib files
COPY --from=amd $OUTPUT/usr/lib/dri/*.so* /root-layer/usr/lib/plexmediaserver/lib/dri/
COPY --from=amd $OUTPUT/usr/lib/ld-musl-x86_64.so* /root-layer/usr/lib/plexmediaserver/lib/
COPY --from=amd $OUTPUT/usr/lib/libdrm*.so* /root-layer/usr/lib/plexmediaserver/lib/
COPY --from=amd $OUTPUT/usr/lib/libelf*.so* /root-layer/usr/lib/plexmediaserver/lib/
COPY --from=amd $OUTPUT/usr/lib/libffi*.so* /root-layer/usr/lib/plexmediaserver/lib/
COPY --from=amd $OUTPUT/usr/lib/libgcc_s*.so* /root-layer/usr/lib/plexmediaserver/lib/
# COPY --from=amd $OUTPUT/usr/lib/libkms*.so* /root-layer/usr/lib/plexmediaserver/lib/
COPY --from=amd $OUTPUT/usr/lib/libLLVM*.so* /root-layer/usr/lib/plexmediaserver/lib/
COPY --from=amd $OUTPUT/usr/lib/libstdc++*.so* /root-layer/usr/lib/plexmediaserver/lib/
COPY --from=amd $OUTPUT/usr/lib/libva*.so* /root-layer/usr/lib/plexmediaserver/lib/
COPY --from=amd $OUTPUT/usr/lib/libxml2*.so* /root-layer/usr/lib/plexmediaserver/lib/
COPY --from=amd $OUTPUT/usr/lib/libz*.so.* /root-layer/usr/lib/plexmediaserver/lib/
COPY --from=amd $OUTPUT/usr/lib/libzstd*.so* /root-layer/usr/lib/plexmediaserver/lib/

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Single layer deployed image
FROM scratch

LABEL maintainer="skjnldsv"

# Add files from buildstage
COPY --from=buildstage /root-layer/ /
