# dnsmasqPXE

![Supports amd64 Architecture][amd64-shield]![Supports armhf Architecture][armhf-shield]![Supports armv7 Architecture][armv7-shield]![Supports aarch64 Architecture][aarch64-shield]
![Docker Pulls][docker-pulls]![Docker Size][docker-size][![Docker Version][docker-version]](https://hub.docker.com/r/trailmix/dnsmasqpxe/tags)[![Docker Edge][docker-edge]](https://hub.docker.com/r/trailmix/dnsmasqpxe/tags)

[![goofus_masqs goofus dnsmasq pxe init matchbox](https://trailmix-images.s3.amazonaws.com/gooface/goofus_masqs.png)](http://djkittyplayz.art/)
[![art djkittyplayz][art]](<(http://djkittyplayz.art/)>)

## use - docker-compose

### configure

The simplest configuration is below. This will set up dnsmasq on localhost, and point all localhost DNS queries to itself with `1.1.1.1` and `8.8.8.8` as the DNS servers.

> docker-compose.yml

```yaml
version: "3"
services:
  dns:
    image: trailmix/dnsmasqPXE
    restart: always
    ports:
      - "53:53/udp"
    cap_add:
      - NET_ADMIN
```

The expansive way to configure is below, this will configure the guest IP address, DNS servers, and interface.  
It will also set up reverse lookup and provide DNS on port 8600 for _consul_.
It will set up the guest as a DHCP server with some static address assignments to 4 hosts.
It will provide PXE over this DHCP server as well.
It will also start a tFTP server with the root of `/srv/tftp` on the guest.

You will need to provide and configure a DHCP server template, and a tFTP server template as exampled below.

> docker-compose.yml

```yaml
version: "3"
services:
  dns:
    image: trilom/dnsmasqPXE
    restart: always
    volumes:
      - ./config:/etc/dnsmasq.d
      - ./templates:/tmp/templates
      - ./tftp:/srv/tftp
      - ./config.yml:/tmp/config.yml
    environment:
      HOST_IP: "10.0.15.100"
      DNS1: "1.1.1.1"
      DNS2: "8.8.8.8"
      INTERFACE: eth0
      REV_CIDR: "10.0.0.0/8"
      DHCP: "true"
      TFTP: "true"
    ports:
      - "1000:53/udp"
    cap_add:
      - NET_ADMIN
```

> config.yml

```yaml
tftp:
  range:
    - 10.0.15.20
    - 10.0.15.200
  host: 10.0.15.10
  domain: 7ds.xyz
  root: /srv/tftp
dhcp:
  - name: mgmt
    reverse: 10.0.0.0/8
    range:
      - 10.0.15.20
      - 10.0.15.200
    router: 10.0.15.1
    hosts:
      - name: greed
        address: 10.0.15.10
        mac: ab:cd:ef:12:34:56
      - name: wrath
        address: 10.0.15.11
        mac: ab:cd:ef:12:34:55
      - name: pride
        address: 10.0.15.12
        mac: ab:cd:ef:12:34:54
      - name: lust
        address: 10.0.15.13
        mac: ab:cd:ef:12:34:56
```

> templates/10-consul.conf

```config
expand-hosts
rev-server=REV_CIDR,HOST_IP#8600
server=/consul/HOST_IP#8600
```

> templates/60-tftp.conf

```config
interface=INTERFACE
domain=DOMAIN
dhcp-range=RANGE_LOW,RANGE_HIGH,255.255.255.0,1h
dhcp-boot=pxelinux.0,pxeserver,TFTP_HOST
pxe-service=x86PC, "Install Linux", pxelinux
enable-tftp
tftp-root=TFTP_ROOT
```

## ./templates

Here you can place configuration that is _templated_.

Basic functionality is to take whatever you put in the `environment` of container will be replaced in the _templates_. For example if you provide an environment variable of `HOST_IP=127.0.0.1` then every instance of the word **HOST_IP** in your templates will be replaced with this string.

| VAR       |   default    | info                              |
| :-------- | :----------: | :-------------------------------- |
| INTERFACE |     eth0     | the dnsmasq interface             |
| HOST_IP   |  127.0.0.1   | host ip address                   |
| DNS1      |   1.1.1.1    | DNS server 1                      |
| DNS2      |   8.8.8.8    | DNS server 2                      |
| REV_CIDR  | 127.0.0.0/24 | reverse look up cidr _for consul_ |
| DHCP      |    false     | enable dhcp server                |
| TFTP      |    false     | enable tftp server                |

## ./config

The config directory is used to view current running config and make on the fly alterations if you need and reload dnsmasq from the container. Its just the configuration directory mounted on the host(`-v ${PWD}/config:/etc/dnsmasq.d` or `./config:/etc/dnsmasq.d`).

## ./tftp

You can put files here, and in the **config.yml** set the tftp options. Be sure that you mount the volume `-v ${PWD}/tftp:/srv/tftp` or `./tftp:/srv/tftp` in compose, and that this volume matches the `tftp.root` key in **config.yml**

```yaml
tftp:
  range:
    - 10.0.15.20
    - 10.0.15.200
  host: 10.0.15.138
  domain: 7ds.xyz
  root: /srv/tftp
```

## use - docker commands

[See configure section](#configure) on configuring.  
Then evaluate these commands and the expressions below:

- `make build` - build container
- `make run` - run the container detached
- `make exec` - enter(👀) the container
- `make test.alpine` - run an alpine container as a control to see if it can do what we want it to do (`dig @127.0.0.1 google.com` - provide dns from localhost)
- `make test.dnsmasqpxe` - run our container to see if it can do what we want it to do (`dig @127.0.0.1 google.com` - provide dns from localhost)
- `make test` - do both the tests and clean up after
- `make clean` - stop and remove containers

```bash
# build container
docker build --no-cache -t dnsmasqpxe -f .docker/Dockerfile .
# run container
docker run -d -v ${PWD}/config/:/etc/dnsmasq.d/ -v ${PWD}/templates/:/tmp/templates/ --name dnsmasqpxe dnsmasqpxe
# test if a normal alpine can do what we want to accomplish
# (hint: it should time out)
docker container run alpine /bin/ash -c "apk add bind-tools && dig -p 53 @127.0.0.1 google.com"
# test if we can do it with our container
# (hint: should be a #successbaby.gif)
docker container run -d -v ${PWD}/config/:/etc/dnsmasq.d/ -v ${PWD}/templates/:/tmp/templates/ --name dnsmasqpxe trailmix/dnsmasqpxe && docker exec -it dnsmasqpxe /bin/ash -c "apk add bind-tools && dig -p 53 @127.0.0.1 google.com"
# enter the container (👀)
docker exec -it dnsmasqpxe /bin/bash
```

## port alterations

- you can alter the port, for example `1000:53/udp` will make the host listen on port 1000 and forward it to 53 on the container.

[art]: https://img.shields.io/badge/art-djkittyplayz-yellow
[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armhf-shield]: https://img.shields.io/badge/armhf-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[docker-pulls]: https://img.shields.io/docker/pulls/trailmix/dnsmasqpxe
[docker-size]: https://img.shields.io/docker/image-size/trailmix/dnsmasqpxe?sort=semver
[docker-version]: https://img.shields.io/docker/v/trailmix/dnsmasqpxe?sort=semver&label=latest
[docker-edge]: https://img.shields.io/docker/v/trailmix/dnsmasqpxe/edge?label=edge
