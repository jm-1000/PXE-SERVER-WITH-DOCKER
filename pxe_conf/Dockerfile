FROM ubuntu:latest

RUN apt update && apt install -y \
    tftpd-hpa \
    dnsmasq \
    python3 \
    && apt clean

COPY ./entrypoint.sh /etc/entrypoint.sh
RUN chmod +x /etc/entrypoint.sh
ENTRYPOINT ["/etc/entrypoint.sh"]
