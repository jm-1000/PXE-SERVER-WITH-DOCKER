FROM ubuntu:latest

RUN apt update && apt install -y \
    pxelinux \
    tftpd-hpa \
    dnsmasq \
    gettext \
    iproute2 \
    && apt clean

COPY ./tftpboot/ /tftpboot/
RUN cp /usr/lib/syslinux/modules/bios/menu.c32 /tftpboot/
RUN cp /usr/lib/syslinux/modules/bios/ldlinux.c32 /tftpboot/
RUN cp /usr/lib/syslinux/modules/bios/libutil.c32 /tftpboot/
RUN chown tftp:tftp /tftpboot -R

COPY ./pxe_conf /tmp/
RUN cp /tmp/tftpd-hpa /etc/default/tftpd-hpa

EXPOSE 67/udp 69/udp

RUN chmod +x /tmp/entrypoint.sh
ENTRYPOINT ["/tmp/entrypoint.sh"]

