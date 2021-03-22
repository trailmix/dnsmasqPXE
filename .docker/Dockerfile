FROM alpine:3.12

ENV HOST_IP="127.0.0.1" \
    INTERFACE="eth0" \
    DNS1="1.1.1.1" \
    DNS2="8.8.8.8" \
    DHCP="false" \
    TFTP="false" \
    REV_CIDR="127.0.0.1/24"

RUN apk --no-cache --purge -uU add dnsmasq=2.81-r0 bash=5.0.17-r0 && \
    rm -rf /var/cache/apk/* /tmp/*

# install yq
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
RUN if [ "$(uname -m)" =  "x86_64" ]; then \
        ARCH='linux_amd64'; \
    elif [ "$(uname -m)" =  "aarch64" ]; then \
        ARCH='linux_arm64'; \
    else \
        ARCH='linux_arm'; \
    fi && \
    wget "$(wget -q -O - https://api.github.com/repos/mikefarah/yq/releases/latest | grep browser_download_url | grep $ARCH | cut -d '"' -f 4)" -O /usr/bin/yq && \
    chmod +x /usr/bin/yq && \
    if [ "$(uname -m)" = "x86_64" ];then \
        apk --no-cache --purge add upx=3.96-r0 && \
        rm -rf /var/cache/apk/* /tmp/* && \
        upx /bin/dnsmasq /bin/bash /usr/bin/yq; \
    fi

VOLUME /etc/dnsmasq.d

# expose 53 for dhcp
EXPOSE 53 53/udp
EXPOSE 67 67/udp
# EXPOSE 68 68/udp
EXPOSE 69 69/udp
EXPOSE 1024-1034


# copy over entrypoint
COPY .docker/entrypoint.sh /sbin/entrypoint.sh
COPY templates/ /tmp/templates
# RUN touch /var/log/dnsmasq.log

RUN chmod 755 /sbin/entrypoint.sh
ENTRYPOINT ["/bin/bash", "/sbin/entrypoint.sh"]