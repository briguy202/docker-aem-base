# docker-aem-base
AEM Base Docker Image

This is the base Docker image for AEM.

## Depends on
Vagrant, VirtualBox, Docker

## Get Started
Start Vagrant which will get your VM (virtualbox) going:
`vagrant up`

Create a directory called `.sources` and place in it a `cq6.jar` file and `license.properties` file.  Then create the image, executing the following:
`docker build --tag="yourname/author" .`

Then to run the image, execute:
`docker run -i -d -p 4502:4502 aem/author:6.0`

At this point the container is running and starting up AEM for the first time.  This will be very slow.  To speed things up on subsequent startups, run a `docker commit -m "Running Instance" <container_id> <tag_name>`.  Once that has been run, it should take <1 minute to start up the AEM instance from this new container.