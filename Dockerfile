FROM alpine:latest

# Environment Variables
ENV GLIBC_VERSION "2.34-r0"
ENV GODOT_VERSION "3.4.2"

# Port to expose
EXPOSE 8081/udp

# Updates and installs
RUN apk update
RUN apk add --no-cache bash

# Allow this to run Godot
RUN wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk
RUN apk add --allow-untrusted glibc-${GLIBC_VERSION}.apk

# Download Godot, version is set from environment variables
RUN wget https://downloads.tuxfamily.org/godotengine/${GODOT_VERSION}/Godot_v${GODOT_VERSION}-stable_linux_server.64.zip \
    && mkdir ~/.cache \
    && mkdir -p ~/.config/godot \
    && unzip Godot_v${GODOT_VERSION}-stable_linux_server.64.zip \
    && mv Godot_v${GODOT_VERSION}-stable_linux_server.64 /usr/local/bin/godot \
    && rm -f Godot_v${GODOT_VERSION}-stable_linux_server.64.zip

WORKDIR /app
COPY lobby-exports/linux/server.pck server.pck
CMD godot --main-pack server.pck