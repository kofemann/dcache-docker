#!/bin/sh

if [ $# != 1 ]
then
  echo "Domain name is required"
  exit 1
fi


DOMAIN=$1
if [ -t 0 ]
then
  LOG=/dev/stdout
else
  LOG=${DCACHE_INSTALL_DIR}/var/log/${DOMAIN}.log
fi

DCACHE_HOME=${DCACHE_INSTALL_DIR}
export CLASSPATH=${DCACHE_HOME}/share/classes/*

# we hope that there is only one agent file and it the right one
ASPECT_AGENT=`ls ${DCACHE_HOME}/share/classes/aspectjweaver-*.jar`

/usr/bin/java -server \
	-Xmx512m -XX:MaxDirectMemorySize=512m \
	-Dsun.net.inetaddr.ttl=1800 \
	-Dorg.globus.tcp.port.range=20000,25000 \
	-Dorg.dcache.dcap.port=0 \
	-Dorg.dcache.net.tcp.portrange=33115:33145 \
	-Dorg.globus.jglobus.delegation.cache.lifetime=30000 \
	-Dorg.globus.jglobus.crl.cache.lifetime=60000 \
	-Djava.security.krb5.realm= \
	-Djava.security.krb5.kdc= \
	-Djavax.security.auth.useSubjectCredsOnly=false \
	-Djava.security.auth.login.config=${DCACHE_INSTALL_DIR}/etc/gss.conf \
	-XX:+HeapDumpOnOutOfMemoryError \
	-XX:HeapDumpPath=${DCACHE_INSTALL_DIR}/var/log/${DOMAIN}-oom.hprof \
	-XX:+UseCompressedOops \
	-javaagent:${ASPECT_AGENT} \
	-Djava.awt.headless=true -DwantLog4jSetup=n \
	-Ddcache.home=${DCACHE_HOME} \
	-Ddcache.paths.defaults=${DCACHE_HOME}/share/defaults \
	-Dorg.dcache.net.localaddresses=${LOCALADDRESS} \
	org.dcache.boot.BootLoader start ${DOMAIN} > ${LOG} 2>&1
