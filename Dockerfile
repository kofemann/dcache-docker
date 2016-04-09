# Based on CentOS 7
FROM centos:7

MAINTAINER dCache "https://www.dcache.org"

# install required packages
RUN yum -y -q install java-1.8.0-openjdk-headless

# accept RPM to be used from the command line
ARG rpm_location=https://www.dcache.org/downloads/1.9/repo/2.15/dcache-2.15.3-1.noarch.rpm

# copy rpm into and install
ADD ${rpm_location} /dcache.rpm
RUN yum -y -q install /dcache.rpm && rm /dcache.rpm

# fix liquibase
RUN rm /usr/share/dcache/classes/liquibase-core-*.jar
COPY liquibase-core-3.4.2.jar /usr/share/dcache/classes/liquibase-core-3.4.2.jar

# add external files into container at the build time
COPY dcache.conf /etc/dcache/dcache.conf
COPY run.sh /etc/dcache/run.sh

# the data log files must survive container restarts
VOLUME /var/log/dcache

# prepare space for pool
RUN mkdir /var/lib/dcache/pool && chown dcache:dcache /var/lib/dcache/pool
VOLUME /var/lib/dcache/pool

# expose TCP ports for network services
EXPOSE 2288 22125 2049

ENTRYPOINT ["/etc/dcache/run.sh"]

# run as user dcache, which is created by rpm
USER dcache

# default domain
CMD ["dCacheDomain"]
