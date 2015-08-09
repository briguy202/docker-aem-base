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

Then create the base image by executing the following:
```bash
docker build --tag="bhibma/aem-base" .
```

Next, build the author and publish images off the base image:
```bash
docker build --tag="bhibma/aem-author" ./aem-author/ && docker build --tag="bhibma/aem-publish" ./aem-publish/
```

Then to run the author and publish images, execute:
```bash
docker run -i -d -p 4503:4503 -p 4513:4513 --name publish bhibma/aem-publish && docker run -i -d -p 4502:4502 -p 4512:4512 --name author --link publish:publish bhibma/aem-author
```

At this point you have two containers running - one for author and one for publish - and both are starting up AEM for the first time.
This will be very slow.  To speed things up on subsequent startups, we need to commit the running instance.  We will first tag the base
image so we can start a container from it if we want in the future:
```bash
docker tag bhibma/aem-author bhibma/aem-author:base && docker tag bhibma/aem-publish bhibma/aem-publish:base
```

Then next we will commit the running container as the 'latest' tag on the image so that when we start using only 'bhibma/aem-author' or 
'bhibma/aem-publish' without any tag specified, it will run the running image, not the base non-running image.
```bash
docker commit -m "Running Instance" author bhibma/aem-author && docker commit -m "Running Instance" publish bhibma/aem-publish
```

Once that has been run, it should take <1 minute to start up the AEM instance from this these running containers.
