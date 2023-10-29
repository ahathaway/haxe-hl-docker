# ===============================================================
# Stolen from this genius: https://gitlab.com/haath/haxe-hl-docker
# ===============================================================
FROM haxe:4.3.2-bullseye AS build-env

ARG HASHLINK_VERSION
ENV HASHLINK_VERSION=$HASHLINK_VERSION

# install dependencies
RUN apt-get update
RUN apt-get install -y build-essential
RUN apt-get install -y libpng-dev libturbojpeg-dev libvorbis-dev libopenal-dev libsdl2-dev libmbedtls-dev libuv1-dev libsqlite3-dev

# clone hashlink into /src
RUN mkdir /src
RUN git clone --depth 1 --branch $HASHLINK_VERSION https://github.com/HaxeFoundation/hashlink /src
WORKDIR /src

# compile hashlink
RUN make
RUN make install

# print out the hashlink version
RUN hl --version && echo ""


# ===============================================================
FROM haxe:4.3.2-bullseye

LABEL maintainer="alex@hathaway.xyz"

# install dependencies
RUN apt-get update
RUN apt-get install -y libpng-dev libturbojpeg-dev libvorbis-dev libopenal-dev libsdl2-dev libmbedtls-dev libuv1-dev libsqlite3-dev

# copy hashlink from the build environment
COPY --from=build-env /usr/local/bin/hl /usr/local/bin/
COPY --from=build-env /usr/local/lib/*.hdll /usr/local/lib/
COPY --from=build-env /usr/local/lib/libhl.so /usr/local/lib/
COPY --from=build-env /usr/local/include/hl.h /usr/local/include/
COPY --from=build-env /usr/local/include/hlc.h /usr/local/include/
COPY --from=build-env /usr/local/include/hlc_main.c /usr/local/include/

# print out the hashlink version
RUN hl --version && echo ""

# CMD [ "hl" ]
