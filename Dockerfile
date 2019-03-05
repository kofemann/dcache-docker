#
# BULDING:
#
#  docker build -t local/dcache --build-arg VERSION=5.0.5 .

# Minimalistic Java image
FROM alpine:3.9
MAINTAINER dCache "https://www.dcache.org"

ARG VERSION
# dCache version placeholder
ENV DCACHE_VERSION=${VERSION}
ENV DCACHE_INSTALL_DIR=/opt/dcache

# Add JRE
RUN apk --update add openjdk8-jre

# Add dCache
ADD dcache-${DCACHE_VERSION}.tar.gz /opt
RUN mv /opt/dcache-${DCACHE_VERSION} ${DCACHE_INSTALL_DIR}

# Run dCache as user 'dcache'
RUN addgroup dcache && adduser -S -G dcache dcache

# fix liquibase
RUN rm ${DCACHE_INSTALL_DIR}/share/classes/liquibase-core-*.jar
COPY liquibase-core-3.5.3.jar ${DCACHE_INSTALL_DIR}/share/classes/liquibase-core-3.5.3.jar


# add external files into container at the build time
COPY dcache.conf ${DCACHE_INSTALL_DIR}/etc/dcache.conf
COPY docker-layout.conf ${DCACHE_INSTALL_DIR}/etc/layouts/docker-layout.conf
COPY exports ${DCACHE_INSTALL_DIR}/etc/exports
RUN  ln -s /authorized_keys ${DCACHE_INSTALL_DIR}/etc/admin/authorized_keys2
COPY run.sh /run.sh

# where we store the data
RUN mkdir /pool

# adjust permissions
RUN chown -R dcache:dcache ${DCACHE_INSTALL_DIR}/var
RUN chown -R dcache:dcache /pool


# the data log files must survive container restarts
VOLUME ${DCACHE_INSTALL_DIR}/var
VOLUME /pool

# expose TCP ports for network services
EXPOSE 2288 22125 2049 32049 22224

ENTRYPOINT ["/run.sh"]

# generate ssh keys
RUN apk --update add openssh
RUN ssh-keygen -t rsa -b 2048 -N '' -f ${DCACHE_INSTALL_DIR}/etc/admin/ssh_host_rsa_key
RUN chown dcache:dcache ${DCACHE_INSTALL_DIR}/etc/admin/ssh_host_rsa_key

# run as user dcache
USER dcache

# default domain
CMD ["core"]
