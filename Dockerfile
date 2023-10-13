# Build the server binary
FROM alpine:latest as builder

RUN apk update \
    && apk -U add --no-cache \
        build-base \
        ca-certificates \
        git \
        libstdc++ \
        wget \
    && mkdir -p /server/lib /tmp/mednafen \
    && cd /tmp/mednafen \
    && git clone "https://github.com/K4rian/mednafen-server-git.git" /tmp/mednafen \
    && ( [ "$(uname -m)" == "x86_64" ] && ./configure || ./configure --build=aarch64-unknown-linux-gnu ) \
    && make \
    && mv /tmp/mednafen/src/mednafen-server /server/mednafen-server \
    && mv /tmp/mednafen/standard.conf /server/server.conf.default \
    && cp /usr/lib/libgcc_s.so.1 /server/lib/libgcc_s.so.1 \
    && cp /usr/lib/libstdc++.so.6 /server/lib/libstdc++.so.6 \
    && chmod +x /server/mednafen-server \
    && rm -R /tmp/mednafen

# Set-up the server
FROM alpine:latest

ENV USERNAME mednafen
ENV USERHOME /home/$USERNAME

ENV MDFNSV_MAXCLIENTS 50
ENV MDFNSV_CONNECTTIMEOUT 5
ENV MDFNSV_PORT 4046
ENV MDFNSV_IDLETIMEOUT 30
ENV MDFNSV_MAXCMDPAYLOAD 5242880
ENV MDFNSV_MINSENDQSIZE 262144
ENV MDFNSV_MAXSENDQSIZE 8388608
ENV MDFNSV_PASSWORD ""
ENV MDFNSV_ISPUBLIC 0

RUN apk update \
    && adduser --disabled-password $USERNAME \
    && rm -rf /tmp/* /var/tmp/*

COPY --from=builder --chown=$USERNAME /server/ $USERHOME/
COPY --chown=$USERNAME ./container_files $USERHOME/

USER $USERNAME
WORKDIR $USERHOME

RUN chmod +x docker-entrypoint.sh

ENTRYPOINT ["./docker-entrypoint.sh"]