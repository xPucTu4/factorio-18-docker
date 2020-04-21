# Build with --no-cache option
FROM frolvlad/alpine-glibc
RUN apk add bash nano mc wget
RUN apk add curl
RUN ln -s /usr/bin/nano /usr/bin/pico && \
 mkdir /factorio/ && \
 mkdir /factorio/maps/ && \
 mkdir /factorio/mods/ && \
 mkdir /factorio/conf/

# Because of a bug with putty+docker+alpine the F2/F4 keys are replaced with F9
COPY mc.default.keymap /etc/mc/

#COPY linux64-0.18.18.tar.gz /


COPY loop.sh /

# The container version (increaced by build.sh script)
ENV CONTAINER_VERSION=1

ENTRYPOINT ["/bin/bash"]
CMD ["/loop.sh"]

EXPOSE 34197/udp
