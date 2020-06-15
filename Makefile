ifndef CONTAINER
CONTAINER=dnsmasqpxe
endif

build:
	docker build --no-cache -t $(CONTAINER) -f .docker/Dockerfile .
run:
	docker container run \
		-d \
		-v ${PWD}/config/:/etc/dnsmasq.d/ \
		-v ${PWD}/templates/:/tmp/templates/ \
		--name dnsmasqpxe \
		$(CONTAINER)
exec:
	docker exec -it dnsmasqpxe /bin/bash
test: test.alpine test.dnsmasqpxe clean
test.alpine:
	docker container run alpine /bin/ash \
		-c "apk add bind-tools && dig -p 53 @127.0.0.1 google.com"
test.dnsmasqpxe:
	docker container run \
		-d \
		-v ${PWD}/config/:/etc/dnsmasq.d/ \
		-v ${PWD}/templates/:/tmp/templates/ \
		--name dnsmasqpxe \
		$(CONTAINER) && \
	docker exec \
		$(CONTAINER) \
		/bin/ash \
		-c "apk add bind-tools && dig -p 53 @127.0.0.1 google.com"
clean:
	docker stop dnsmasqpxe && docker rm dnsmasqpxe && docker image rm dnsmasqpxe