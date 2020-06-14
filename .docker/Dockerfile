FROM alpine:latest

ENV HOST_IP="127.0.0.1" \
    INTERFACE="eth0" \
    DNS1="1.1.1.1" \
    DNS2="8.8.8.8" \
    DHCP="false" \
    TFTP="false" \
    REV_CIDR="127.0.0.1/24"

RUN apk --no-cache add dnsmasq bash
# install yq
RUN wget $(wget -q -O - https://api.github.com/repos/mikefarah/yq/releases/latest | grep browser_download_url | grep linux_amd64 | cut -d '"' -f 4) -O /usr/bin/yq && \
    chmod +x /usr/bin/yq

VOLUME /etc/dnsmasq.d

# expose 53 for dhcp
EXPOSE 53 53/udp

# copy over entrypoint
COPY .docker/entrypoint.sh /sbin/entrypoint.sh
COPY templates/ /tmp/templates

RUN chmod 755 /sbin/entrypoint.sh
ENTRYPOINT ["/bin/bash", "/sbin/entrypoint.sh"]