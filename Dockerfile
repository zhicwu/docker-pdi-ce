#
# PDI base image
#

#
# Stage 1/2: Build
#
FROM maven:3.5.0-jdk-8 as builder

ENV PDI_RELEASE=8.0.0.0 PDI_BUILD=6 ANT_VERSION=1.10.1 \
	ECLIPSE_SWT_VERSION=4.6 SYSLOG4J_VERSION=0.9.46
ENV PDI_VERSION=${PDI_RELEASE}-${PDI_BUILD}

RUN wget --progress=dot:giga https://github.com/pentaho/pentaho-kettle/archive/${PDI_RELEASE}-R.tar.gz \
	&& tar zxf *.tar.gz \
	&& wget --timeout=5 --waitretry=2 --tries=50 --retry-connrefused --progress=dot:giga http://ivy-nexus.pentaho.org/content/groups/omni/pentaho/pentaho-karaf-assembly/${PDI_VERSION}/pentaho-karaf-assembly-${PDI_VERSION}-client.zip \
		http://ivy-nexus.pentaho.org/content/groups/omni/pentaho/pentaho-big-data-plugin/${PDI_VERSION}/pentaho-big-data-plugin-${PDI_VERSION}.zip \
		https://github.com/maven-eclipse/maven-eclipse.github.io/raw/master/maven/org/eclipse/swt/org.eclipse.swt.gtk.linux.x86_64/$ECLIPSE_SWT_VERSION/org.eclipse.swt.gtk.linux.x86_64-$ECLIPSE_SWT_VERSION.jar \
		http://clojars.org/repo/org/syslog4j/syslog4j/$SYSLOG4J_VERSION/syslog4j-$SYSLOG4J_VERSION.jar \
	&& mvn install:install-file -Dfile=pentaho-big-data-plugin-${PDI_VERSION}.zip -DgroupId=pentaho -DartifactId=pentaho-big-data-plugin -Dversion=${PDI_VERSION} -Dpackaging=zip \
	&& mvn install:install-file -Dfile=pentaho-karaf-assembly-${PDI_VERSION}-client.zip -DgroupId=pentaho -DartifactId=pentaho-karaf-assembly -Dversion=${PDI_VERSION} -Dpackaging=zip -Dclassifier=client \
	&& mvn install:install-file -Dfile=org.eclipse.swt.gtk.linux.x86_64-$ECLIPSE_SWT_VERSION.jar -DgroupId=org.eclipse.swt -DartifactId=org.eclipse.swt.gtk.linux.x86_64 -Dversion=$ECLIPSE_SWT_VERSION -Dpackaging=jar \
	&& mvn install:install-file -Dfile=syslog4j-$SYSLOG4J_VERSION.jar -DgroupId=org.syslog4j -DartifactId=syslog4j -Dversion=$SYSLOG4J_VERSION -Dpackaging=jar \
	&& cd /pentaho-kettle-* \
	&& mvn --quiet -DskipTests install \
	&& cd - \
	&& unzip /pentaho-kettle-*/assemblies/pdi-ce/target/pdi-ce*.zip \
	&& rm -rf data-integration/*.bat data-integration/*.command data-integration/Data\ Integration.app data-integration/samples \
	&& chmod +x data-integration/*.sh \
	&& sed -i -e 's|\(.*if \[ \$OS = "linux" \]; then\)|if \[ \$OS = "n/a" \]; then|' data-integration/spoon.sh \
	&& rm -rf /pentaho-kettle-*


#
# Stage 2/2: Install
#
FROM zhicwu/java:8

# Set maintainer details
MAINTAINER Zhichun Wu <zhicwu@gmail.com>

# Set environment variables
ENV PDI_VERSION=8.0.0.0-6 KETTLE_HOME=/data-integration

# Set label
LABEL java_server="Pentaho Data Integration $PDI_VERSION Community Edition"

# Update system
RUN apt-get update \
	&& apt-get install -y xvfb \
	&& mkdir -p $KETTLE_HOME \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# Copy PDI files
COPY --from=builder /data-integration $KETTLE_HOME

# Switch directory
WORKDIR $KETTLE_HOME
