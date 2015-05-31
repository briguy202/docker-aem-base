# docker-aem-base
AEM Base Docker Image

This is the base Docker image for AEM.

## Depends on
Vagrant, VirtualBox, Docker

Also, install the vagrant-gatling-rsync plugin
`vagrant plugin install vagrant-gatling-rsync`

## Get Started
Start Vagrant which will get your VM (virtualbox) going:
`vagrant up`

Create a directory called `.sources` and place in it a `cq6.jar` file and `license.properties` file.  

If the `docker` command throws a TCP error, you probably need to setup the `DOCKER_HOST`.
```bash
export DOCKER_HOST_IP=$(vagrant ssh-config | sed -n "s/[ ]*HostName[ ]*//gp")
export DOCKER_HOST="tcp://${DOCKER_HOST_IP}:2375"
```

Then create the image, executing the following:
```bash
docker build --tag="bhibma/aem-base" .
```

Then to run the image, execute:
```bash
docker run -i -d -p 4502:4502 bhibma/aem-base --name author
```

Similarly to run for publish, execute:
```bash
docker run -i -d -p 4503:4503 bhibma/aem-base --name publish
```

At this point you have two containers running - one for author and one for publish - and both are starting up AEM for the first time.
This will be very slow.  To speed things up on subsequent startups, run a `docker commit -m "Running Instance" <container_id> <tag_name>`.
Once that has been run, it should take <1 minute to start up the AEM instance from this new container.
