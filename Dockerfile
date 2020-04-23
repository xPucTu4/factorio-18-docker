# Build with --no-cache option
FROM docker-mirrors.d.arty.xpuctu4.net/dotnet-core/sdk:3.1.201-buster AS dnbuildar
RUN apt-get update && apt-get install -y nano mc wget nmap
RUN echo quit | openssl s_client -showcerts -servername arty.xpuctu4.net -connect arty.xpuctu4.net:443 > /etc/ssl/certs/xpuctu4.pem
COPY dpf /work/
WORKDIR /work/ 
RUN dotnet restore -s https://arty.xpuctu4.net/artifactory/api/nuget/nuget-local
RUN dotnet publish --no-restore -o out

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

COPY --from=dnbuildar /work/out/DockerPermissionFix /
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

