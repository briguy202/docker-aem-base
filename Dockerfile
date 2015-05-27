FROM ariya/centos6-oracle-jre7
MAINTAINER bhibma

RUN yum -y update; yum clean all
RUN yum install -y httpd
RUN service httpd start

RUN mkdir -p /apps/aem/

WORKDIR /apps/aem/

ADD .sources/cq6.jar /apps/aem/cq6.jar
ADD .sources/license.properties /apps/aem/license.properties

RUN java -jar cq6.jar -unpack -v

ENV CQ_FOREGROUND y
ENV CQ_JVM_OPTS   "-server -Xmx1524M -Xms512M -XX:MaxPermSize=512M"