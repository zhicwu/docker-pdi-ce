#
# This docker image is just for development and testing purpose - please do NOT use on production
#

# Pull Base Image
FROM zhicwu/java:8

# Set Maintainer Details
MAINTAINER Zhichun Wu <zhicwu@gmail.com>

# Set Environment Variables
ENV PDI_VERSION=7.1 PDI_BUILD=7.1.0.0-12 PDI_PATCH=7.1.0.0 PDI_USER=pentaho \
	KETTLE_HOME=/data-integration POSTGRESQL_DRIVER_VERSION=42.1.1 \
	MYSQL_DRIVER_VERSION=5.1.42 JTDS_VERSION=1.3.1 CASSANDRA_DRIVER_VERSION=0.6.3 \
	H2DB_VERSION=1.4.196 HSQLDB_VERSION=2.4.0

# Add Cron Jobs
COPY purge-old-files.sh /usr/local/bin/purge-old-files.sh

# Install Required Packages, Configure Crons and Add User
RUN apt-get update \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* \
	&& useradd -md $KETTLE_HOME -s /bin/bash $PDI_USER

# Download Pentaho Data Integration Community Edition and Unpack
RUN wget --progress=dot:giga http://downloads.sourceforge.net/project/pentaho/Data%20Integration/${PDI_VERSION}/pdi-ce-${PDI_BUILD}.zip \
	&& unzip -q *.zip \
	&& rm -f *.zip

# Add Entry Point and Templates
COPY docker-entrypoint.sh $KETTLE_HOME/docker-entrypoint.sh

# Switch Directory
WORKDIR $KETTLE_HOME

# Download and Apply Patches
RUN wget --progress=dot:giga https://github.com/zhicwu/pdi-cluster/releases/download/${PDI_PATCH}/pentaho-kettle-${PDI_PATCH}.jar \
	&& unzip -q pentaho-kettle*.jar -d classes \
	&& rm -f pentaho-kettle*.jar

# Update JDBC Drivers
RUN wget --progress=dot:giga https://jdbc.postgresql.org/download/postgresql-${POSTGRESQL_DRIVER_VERSION}.jar \
		http://central.maven.org/maven2/mysql/mysql-connector-java/${MYSQL_DRIVER_VERSION}/mysql-connector-java-${MYSQL_DRIVER_VERSION}.jar \
		http://central.maven.org/maven2/net/sourceforge/jtds/jtds/${JTDS_VERSION}/jtds-${JTDS_VERSION}.jar \
		http://central.maven.org/maven2/com/github/zhicwu/cassandra-jdbc-driver/${CASSANDRA_DRIVER_VERSION}/cassandra-jdbc-driver-${CASSANDRA_DRIVER_VERSION}-shaded.jar \
		http://central.maven.org/maven2/com/h2database/h2/${H2DB_VERSION}/h2-${H2DB_VERSION}.jar \
		http://central.maven.org/maven2/org/hsqldb/hsqldb/${HSQLDB_VERSION}/hsqldb-${HSQLDB_VERSION}.jar \
	&& rm -f lib/postgre*.jar lib/mysql*.jar lib/jtds*.jar lib/h2*.jar lib/hsqldb*.jar \
	&& mv *.jar lib/.

# Install Plugins
# TODO:
# 1) https://github.com/graphiq-data/pdi-streamschemamerge-plugin
# 2) https://github.com/graphiq-data/pdi-fastjsoninput-plugin

# Configure PDI
# plugins/kettle5-log4j-plugin/log4j.xml
RUN rm -rf system/osgi/log4j.xml classes/log4j.xml pwd/* simple-jndi/* system/karaf/data/tmp \
	&& ln -s $JMX_EXPORTER_FILE jmx-exporter.jar \
	&& echo "01 * * * * /usr/local/bin/purge-old-files.sh 2>>/var/log/cron.log" > /var/spool/cron/crontabs/root \
	&& chmod 0600 /var/spool/cron/crontabs/root \
	&& chmod +x *.sh /usr/local/bin/*.sh \
	&& sed -i -e 's|\(.*if \[ \$OS = "linux" \]; then\)|if \[ \$OS = "n/a" \]; then|' spoon.sh \
	&& sed -i 's/^\(respectStartLvlDuringFeatureStartup=\).*/\1true/' system/karaf/etc/org.apache.karaf.features.cfg \
	&& sed -i 's/^\(featuresBootAsynchronous=\).*/\1false/' system/karaf/etc/org.apache.karaf.features.cfg

ENTRYPOINT ["/sbin/my_init", "--", "./docker-entrypoint.sh"]

#VOLUME ["$KETTLE_HOME/logs", "$KETTLE_HOME/system/karaf/caches", "$KETTLE_HOME/system/karaf/data", "/tmp"]

#  8080 - Carte Web Service
#  8802 - Karaf SSHD
#  9052 - OSGi Service
#EXPOSE 8080 8802 9052

#CMD ["slave"]
