#
# This docker image is just for development and testing purpose - please do NOT use on production
#

# Pull base image
FROM zhicwu/pdi-ce:7.1-full

# Set maintainer details
MAINTAINER Zhichun Wu <zhicwu@gmail.com>

# Set environment variables
ENV PDI_PATCH=7.1.0.5 PDI_USER=pentaho \
	JMX_EXPORTER_VERSION=0.10

# Add cron job and entrypoint
COPY purge-old-files.sh /usr/local/bin/purge-old-files.sh
COPY docker-entrypoint.sh docker-entrypoint.sh

# Add user, apply patches and configure PDI
RUN useradd -md $KETTLE_HOME -s /bin/bash $PDI_USER \
	&& wget --progress=dot:giga https://github.com/zhicwu/pdi-cluster/releases/download/${PDI_PATCH}/pentaho-kettle-${PDI_PATCH}.jar \
	&& unzip -q pentaho-kettle*.jar -d classes \
	&& rm -f pentaho-kettle*.jar \
	&& rm -rf system/osgi/log4j.xml classes/log4j.xml pwd/* simple-jndi/* system/karaf/data/tmp \
	&& wget -O jmx-exporter.jar http://central.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/${JMX_EXPORTER_VERSION}/jmx_prometheus_javaagent-${JMX_EXPORTER_VERSION}.jar \
	&& echo "01 * * * * /usr/local/bin/purge-old-files.sh 2>>/var/log/cron.log" > /var/spool/cron/crontabs/root \
	&& chmod 0600 /var/spool/cron/crontabs/root \
	&& chmod +x docker-entrypoint.sh /usr/local/bin/*.sh \
	&& sed -i 's/^\(respectStartLvlDuringFeatureStartup=\).*/\1true/' system/karaf/etc/org.apache.karaf.features.cfg \
	&& sed -i 's/^\(featuresBootAsynchronous=\).*/\1false/' system/karaf/etc/org.apache.karaf.features.cfg

ENTRYPOINT ["/sbin/my_init", "--", "./docker-entrypoint.sh"]

#VOLUME ["$KETTLE_HOME/logs", "$KETTLE_HOME/system/karaf/caches", "$KETTLE_HOME/system/karaf/data", "/tmp"]

#  8080 - Carte Web Service
#  8802 - Karaf SSHD
#  9052 - OSGi Service
#EXPOSE 8080 8802 9052

CMD ["slave"]
