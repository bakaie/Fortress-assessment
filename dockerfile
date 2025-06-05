FROM ubuntu:22.04 AS build

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /build
RUN mkdir -p /app

RUN apt-get update && \
    apt-get install -y build-essential wget tar && \
    wget https://sourceforge.net/projects/bftpd/files/bftpd/bftpd-6.3/bftpd-6.3.tar.gz && \
    tar xzf bftpd-6.3.tar.gz && \
    cd bftpd && \
    make && \
    cp bftpd /app/bftpd

#build runtime image
FROM ubuntu:22.04 AS runtime

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /app

RUN apt-get update && \
    apt-get install -y libpam0g bash net-tools netcat && \
    useradd -m -d /srv/ftp admin && echo "admin:admin" | chpasswd && \
    mkdir -p /srv/ftp && chown admin:admin /srv/ftp && \
    mkdir -p /etc/bftpd && \
    rm -rf /var/lib/apt/lists/*

# Copy bftpd binary from builder
RUN mkdir -p /var/log/bftpd
RUN mkdir -p /app
COPY --from=build /app/bftpd /app/bftpd

COPY bftpd.conf /etc/bftpd/bftpd.conf

COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

EXPOSE 2121 30000-30010

CMD ["/app/entrypoint.sh"]