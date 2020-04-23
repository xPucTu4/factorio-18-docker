# Build with --no-cache option
FROM golang AS gbuildar
RUN mkdir -p /work/
COPY dpf /work/
WORKDIR /work/
RUN go build -o out/DockerPermissionFix program.go

FROM debian:10-slim
EXPOSE 34197/udp
RUN apt update
RUN apt install -y nano mc wget
VOLUME /factorio/maps/
VOLUME /factorio/mods/
RUN mkdir -p /factorio/ && \
 mkdir -p /factorio/conf/

# Change only the locale formatting
ENV LC_CTYPE=C.UTF-8
ENV EDITOR=mcedit

COPY --from=gbuildar /work/out/DockerPermissionFix /
RUN chmod 6755 /DockerPermissionFix

RUN useradd -d /factorio/ -g users -M -r -s /bin/bash factorio && \
 passwd -l factorio && \
 chown -RLv factorio:users /factorio/ && \
 chown -v factorio:users /factorio/mods/


COPY autostart.sh /factorio/conf/
COPY xPucTu4.sh /
COPY loop.sh /
USER factorio:users

# The container version (increaced by build.sh script)
ARG IMAGE_VERSION
ENV IMAGE_VERSION=$IMAGE_VERSION
ARG IMAGE_DATE
ENV IMAGE_DATE=$IMAGE_DATE

ENTRYPOINT ["/bin/bash"]
CMD ["/loop.sh"]

