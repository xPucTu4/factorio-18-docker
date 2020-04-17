# Build with --no-cache option
FROM frolvlad/alpine-glibc
RUN apk add bash nano mc wget
RUN apk add curl
RUN ln -s /usr/bin/nano /usr/bin/pico && \
 mkdir /factorio/ && \
 mkdir /factorio/maps/ && \
 mkdir /factorio/mods/ && \
 mkdir /factorio/conf/

# Because of a bug in docker, edit/save key is changed to F9
COPY mc.default.keymap /etc/mc/
#COPY linux64-0.18.18.tar.gz /
COPY loop.sh /

ENTRYPOINT ["/bin/bash"]
CMD ["/loop.sh"]

EXPOSE 34197/udp
