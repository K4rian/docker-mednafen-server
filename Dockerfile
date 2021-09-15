# Build the server app
FROM alpine:latest as appbuilder

RUN apk update \
    && apk -U add --no-cache \
        build-base \
        ca-certificates \
        wget \
        xz \
    && mkdir -p /app \
    && cd /app \
    && wget 'https://mednafen.github.io/releases/files/mednafen-server-0.5.2.tar.xz' \
    && xz -d mednafen-server-0.5.2.tar.xz \
    && tar -xf mednafen-server-0.5.2.tar \
    && mv mednafen-server sources \
    && cd sources \
    && ./configure \
    && make \
    && mv /app/sources/src/mednafen-server /app/mednafen-server \
    && mv /app/sources/standard.conf /app/server.conf.default \
    && chmod +x /app/mednafen-server \
    && rm -R /app/sources /app/*.tar


# Setup the server
FROM alpine:latest

LABEL maintainer="contact@k4rian.com"

ENV USERNAME mednafen
ENV USERHOME /home/$USERNAME

RUN apk update \
    && apk -U add --no-cache \
        bash \
        libstdc++ \
    && adduser --disabled-password $USERNAME \
    && rm -rf /tmp/* /var/tmp/*

COPY --from=appbuilder --chown=$USERNAME /app/* $USERHOME/
COPY --chown=$USERNAME ./container_files $USERHOME/

USER $USERNAME
WORKDIR $USERHOME

RUN chmod +x docker-entrypoint.sh

ENTRYPOINT ["./docker-entrypoint.sh"]