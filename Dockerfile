FROM alpine:3.20 AS builder

WORKDIR /tmp/mednafen

RUN apk update \
    && apk -U add --no-cache \
        build-base=0.5-r3 \
        ca-certificates=20240705-r0 \
        git=2.45.2-r0 \
        libstdc++=13.2.1_git20240309-r0 \
        wget=1.24.5-r0 \
    && mkdir -p /server/lib \
    && git clone "https://github.com/K4rian/mednafen-server-git.git" /tmp/mednafen \
    && ( [ "$(uname -m)" = "x86_64" ] && ./configure || ./configure --build=aarch64-unknown-linux-gnu ) \
    && make \
    && mv /tmp/mednafen/src/mednafen-server /server/mednafen-server \
    && mv /tmp/mednafen/standard.conf /server/server.conf.default \
    && cp /usr/lib/libgcc_s.so.1 /server/lib/libgcc_s.so.1 \
    && cp /usr/lib/libstdc++.so.6 /server/lib/libstdc++.so.6 \
    && chmod +x /server/mednafen-server \
    && rm -R /tmp/mednafen

FROM alpine:3.20

ENV USERNAME=mednafen
ENV USERHOME=/home/$USERNAME

ENV MDFNSV_MAXCLIENTS=50
ENV MDFNSV_CONNECTTIMEOUT=5
ENV MDFNSV_PORT=4046
ENV MDFNSV_IDLETIMEOUT=30
ENV MDFNSV_MAXCMDPAYLOAD=5242880
ENV MDFNSV_MINSENDQSIZE=262144
ENV MDFNSV_MAXSENDQSIZE=8388608
ENV MDFNSV_PASSWORD=""
ENV MDFNSV_ISPUBLIC=0

RUN apk update \
    && adduser --disabled-password $USERNAME \
    && rm -rf /tmp/* /var/tmp/*

COPY --from=builder --chown=$USERNAME /server/ $USERHOME/
COPY --chown=$USERNAME ./container_files $USERHOME/

USER $USERNAME
WORKDIR $USERHOME

RUN chmod +x docker-entrypoint.sh

ENTRYPOINT ["./docker-entrypoint.sh"]