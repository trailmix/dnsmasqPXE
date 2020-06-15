#!/bin/bash
# check if dhcp is enabled, if so build dhcp file
echo $DHCP
echo $TFTP
[ "$DHCP" == "true" ] && (
    # for each dhcp server options
    echo 'in dhcp'
    for row in $(yq r -j /tmp/config.yml 'dhcp.*.name'); do
        echo "in $row"
        DHCP_NAME=`echo "$row" | tr -d '"'`
        REVERSE_CIDR=`yq r /tmp/config.yml dhcp.name==$DHCP_NAME.reverse`
        ROUTER=`yq r /tmp/config.yml dhcp.name==$DHCP_NAME.router`
        RANGE_LOW=`yq r /tmp/config.yml dhcp.name==$DHCP_NAME.range[0]`
        RANGE_HIGH=`yq r /tmp/config.yml dhcp.name==$DHCP_NAME.range[1]`
        echo "dhcp-range=$RANGE_LOW,$RANGE_HIGH,12h" > /etc/dnsmasq.d/53-dhcp.conf
        echo "dhcp-option=3,$ROUTER" >> /etc/dnsmasq.d/53-dhcp.conf
        for row in $(yq r -j /tmp/config.yml "dhcp.name==$DHCP_NAME.hosts.*.name"); do
            HOST_NAME=`echo "$row" | tr -d '"'`
            IP=`yq r /tmp/config.yml "dhcp.name==$DHCP_NAME.hosts.name==$HOST_NAME.address"`
            MAC=`yq r /tmp/config.yml "dhcp.name==$DHCP_NAME.hosts.name==$HOST_NAME.mac"`
            echo "# config for host $HOST_NAME..." >> /etc/dnsmasq.d/53-dhcp.conf
            echo "dhcp-host=$MAC,$IP,12h" >> /etc/dnsmasq.d/53-dhcp.conf
        done
    done
)

# for each file in templates
if [[ `ls -A /tmp/templates` ]]; then
    for file in /tmp/templates/*.conf; do
        echo "$file"
        FILE_NAME=`basename $file`
        cat $file > /etc/dnsmasq.d/$FILE_NAME
        echo "" >> /etc/dnsmasq.d/$FILE_NAME
        # find and replace words
        sed -i "s|INTERFACE|$INTERFACE|g" /etc/dnsmasq.d/`basename $file`
        sed -i "s|HOST_IP|$HOST_IP|g" /etc/dnsmasq.d/`basename $file`
        sed -i "s|DNS1|$DNS1|g" /etc/dnsmasq.d/`basename $file`
        sed -i "s|DNS2|$DNS2|g" /etc/dnsmasq.d/`basename $file`
        sed -i "s|REV_CIDR|$REV_CIDR|g" /etc/dnsmasq.d/`basename $file`
        [ "$TFTP" == "true" ] && (
            TFTP_ROOT=`yq r /tmp/config.yml tftp.root`
            DOMAIN=`yq r /tmp/config.yml tftp.domain`
            TFTP_HOST=`yq r /tmp/config.yml tftp.host`
            RANGE_LOW=`yq r /tmp/config.yml tftp.range[0]`
            RANGE_HIGH=`yq r /tmp/config.yml tftp.range[1]`
            sed -i "s|TFTP_ROOT|$TFTP_ROOT|g" /etc/dnsmasq.d/`basename $file`
            sed -i "s|DOMAIN|$DOMAIN|g" /etc/dnsmasq.d/`basename $file`
            sed -i "s|TFTP_HOST|$TFTP_HOST|g" /etc/dnsmasq.d/`basename $file`
            sed -i "s|RANGE_LOW|$RANGE_LOW|g" /etc/dnsmasq.d/`basename $file`
            sed -i "s|RANGE_HIGH|$RANGE_HIGH|g" /etc/dnsmasq.d/`basename $file`
            sed -i "s|TFTP_ROOT|$TFTP_ROOT|g" /etc/dnsmasq.d/`basename $file`
        )
    done
fi

dnsmasq -k $@