# examples

## simple

The `simple.yml` file is a simple example that will provide from the host and guest dns on port 53 from localhost.

- From the example directory `cd example/simple` you can run `docker-compose --build --force-recreate -d` to create the container.
- Validate success by running `dig @127.0.0.1 google.com` you should be able DNS from your localhost that is running in the container.
- Clean up the container by running `docker-compose down` in the same directory.

## complex

The **complex** example is an example that will provide DNS on port 53 on the guest, and DNS on port 1000 on the host. It will also set up DHCP and tFTP on the guest, that is forwarded to the host.

- From the example directory `cd example/complex` you can run `docker-compose --build --force-recreate -d` to create the container.
- Validate success by running `dig -p 1000 @127.0.0.1 google.com` you should be able DNS from your localhost that is running in the container.
- Clean up the container by running `docker-compose down` in the same directory.
