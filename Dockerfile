# Build with --no-cache option
FROM debian:10-slim
RUN apt update
RUN apt install -y nano mc wget
RUN apt install -y curl
RUN mkdir /factorio/ && \
 mkdir /factorio/maps/ && \
 mkdir /factorio/mods/ && \
 mkdir /factorio/conf/

#COPY linux64-0.18.18.tar.gz /

COPY xPucTu4.sh /
COPY loop.sh /

# Change only the locale formatting
ENV LC_CTYPE=C.UTF-8
ENV EDITOR=mcedit
# The container version (increaced by build.sh script)
ENV CONTAINER_VERSION=1

ENTRYPOINT ["/bin/bash"]
CMD ["/loop.sh"]

EXPOSE 34197/udp
