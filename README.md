# docker-aem-base
AEM Base Docker Image

This is the base Docker image for AEM.

## Depends on
Vagrant, VirtualBox, Docker

## Get Started
Start Vagrant which will get your VM (virtualbox) going:
`vagrant up`

To create the image, execute the following:
`docker build --tag="yourname/author" .`

Then to run the image, execute:
`docker run -i -d -p 4502:4502 aem/author:6.0`