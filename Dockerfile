ARG ALPINE_VERSION=3.19

FROM alpine:$ALPINE_VERSION as build
WORKDIR /root

ARG CUTELEE_VERSION=6.1.0
ARG CUTELYST_VERSION=4.0.0
ARG VIRTYLST_VERSION=086d3be5b3c59b9afcf8ce9297ae55082454323f

RUN apk upgrade -a -U && apk add g++ patch cmake samurai libvirt-dev qt6-qtbase-dev qt6-qtdeclarative-dev qt6-qttools-dev

RUN mkdir src && cd src && \
    wget -O cutelee.tar.gz https://github.com/cutelyst/cutelee/archive/refs/tags/v$CUTELEE_VERSION.tar.gz && \
    tar xf cutelee.tar.gz --strip-components 1 && \
    cmake -GNinja -B build -DCMAKE_INSTALL_PREFIX=/usr/local . && \
    cmake --build build && cmake --install build && \
    rm -rf /root/src /root/build

RUN mkdir src && cd src && \
    wget -O cutelyst.tar.gz https://github.com/cutelyst/cutelyst/archive/refs/tags/v$CUTELYST_VERSION.tar.gz && \
    tar xf cutelyst.tar.gz --strip-components 1 && \
    cmake -GNinja -B build -DCMAKE_INSTALL_PREFIX=/usr/local -DPLUGIN_VIEW_CUTELEE=ON . && \
    cmake --build build && cmake --install build && \
    rm -rf /root/src /root/build

RUN mkdir src && cd src && \
    wget -O virtylst.tar.gz https://github.com/cutelyst/Virtlyst/archive/$VIRTYLST_VERSION.tar.gz && \
    tar xf virtylst.tar.gz --strip-components 1 && \
    cmake -GNinja -B build -DCMAKE_INSTALL_PREFIX=/usr/local . && \
    cmake --build build

FROM alpine:$ALPINE_VERSION

RUN set -ex && \
	apk upgrade -a -U && \
	apk add openssh libvirt qt6-qtbase qt6-qtdeclarative qt6-qtbase-sqlite && \
	rm -rf /var/cache/apk

COPY --from=build /usr/local /usr/local
COPY --from=build /root/src/root /var/www/root
COPY --from=build /root/src/build/src/libVirtlyst.so /usr/local/lib

CMD ["cutelystd4-qt6", "--application", "/usr/local/lib/libVirtlyst.so", "--chdir2", "/var/www", "--static-map", "/static=root/static", "--http-socket", "80", "--master", "--using-frontend-proxy"]

