#
# PDI base image
#

#
# Stage 1/2: Build
#
FROM zhicwu/java:8 as builder

ENV PDI_RELEASE=7.1.0.5 PDI_BUILD=70 ANT_VERSION=1.10.1 \
	ECLIPSE_SWT_VERSION=4.6 SYSLOG4J_VERSION=0.9.46
ENV PDI_VERSION=${PDI_RELEASE}-${PDI_BUILD}

RUN apt-get update \
	&& apt-get install -y maven \
	&& wget --progress=dot:giga https://github.com/pentaho/pentaho-kettle/archive/${PDI_RELEASE}-R.tar.gz \
		https://www.apache.org/dist/ant/binaries/apache-ant-${ANT_VERSION}-bin.tar.gz \
	&& for p in *.tar.gz; do tar zxf $p && rm -f $p; done \
	&& cd /pentaho-kettle-* \
	&& for f in $(find . -name "build*.xml" -o -name "subfloor*.xml" -type f); do cat $f | sed -e 's/<!--/\x0<!--/g;s/-->/-->\x0/g' | grep -zv '^<!--' | tr -d '\0' > $f.new; done \
	&& for f in $(find . -name "build*.xml" -o -name "subfloor*.xml" -type f); do cat $f.new | sed -e 's|<junit|<!-- junit|' -e 's|</\(junit\w*\)>|\1 -->|' > $f; done \
	&& for f in $(find . -name "build*.xml" -o -name "subfloor*.xml" -type f); do cat $f | sed -e 's/<!--/\x0<!--/g;s/-->/-->\x0/g' | grep -zv '^<!--' | tr -d '\0' > $f.new; done \
	&& for f in $(find . -name "build*.xml" -o -name "subfloor*.xml" -type f); do cat $f.new | sed -e 's|<jacoco:coverage|<!-- jacoco:coverage|' -e 's|</\(jacoco:coverage\)>|\1 -->|' > $f; done \
	&& wget --timeout=5 --waitretry=2 --tries=50 --retry-connrefused --progress=dot:giga http://ivy-nexus.pentaho.org/content/groups/omni/pentaho/pentaho-karaf-assembly/${PDI_VERSION}/pentaho-karaf-assembly-${PDI_VERSION}-client.zip \
		http://ivy-nexus.pentaho.org/content/groups/omni/pentaho/pentaho-big-data-plugin/${PDI_VERSION}/pentaho-big-data-plugin-${PDI_VERSION}.zip \
		https://github.com/maven-eclipse/maven-eclipse.github.io/raw/master/maven/org/eclipse/swt/org.eclipse.swt.gtk.linux.x86_64/$ECLIPSE_SWT_VERSION/org.eclipse.swt.gtk.linux.x86_64-$ECLIPSE_SWT_VERSION.jar \
		http://clojars.org/repo/org/syslog4j/syslog4j/$SYSLOG4J_VERSION/syslog4j-$SYSLOG4J_VERSION.jar \
	&& mvn install:install-file -Dfile=pentaho-big-data-plugin-${PDI_VERSION}.zip -DgroupId=pentaho -DartifactId=pentaho-big-data-plugin -Dversion=${PDI_VERSION} -Dpackaging=zip \
	&& mvn install:install-file -Dfile=pentaho-karaf-assembly-${PDI_VERSION}-client.zip -DgroupId=pentaho -DartifactId=pentaho-karaf-assembly -Dversion=${PDI_VERSION} -Dpackaging=zip \
	&& mvn install:install-file -Dfile=org.eclipse.swt.gtk.linux.x86_64-$ECLIPSE_SWT_VERSION.jar -DgroupId=org.eclipse.swt -DartifactId=org.eclipse.swt.gtk.linux.x86_64 -Dversion=$ECLIPSE_SWT_VERSION -Dpackaging=jar \
	&& mvn install:install-file -Dfile=syslog4j-$SYSLOG4J_VERSION.jar -DgroupId=org.syslog4j -DartifactId=syslog4j -Dversion=$SYSLOG4J_VERSION -Dpackaging=jar \
	&& find . -name "*.xml" -type f | xargs sed -i -e 's| m:classifier="client"||' \
	&& find . -name "ivysettings.xml" | xargs sed -i -e 's|\(<settings \)|<property name="local-maven2-dir" value="${user.home}/.m2/repository/" />\n\n  \1|' \
	&& find . -name "ivysettings.xml" | xargs sed -i -e 's|\(<dual \)|<filesystem name="local-maven-2" m2compatible="true" force="false" local="true">\n        <artifact pattern="${local-maven2-dir}/[organisation]/[module]/[revision]/[module]-[revision].[ext]"/>\n        <ivy pattern="${local-maven2-dir}/[organisation]/[module]/[revision]/[module]-[revision].pom"/>\n      </filesystem>\n\n      \1|' \
	&& for i in 1 2 3 4 5; do /apache-ant-$ANT_VERSION/bin/ant -Divy.checkmodified=false -Divy.checksums= dist && break || echo "x Retrying... #$i" && sleep 3; done \
	&& rm -rf dist/*.bat dist/*.command dist/Data\ Integration.app dist/samples \
	&& chmod +x dist/*.sh \
	&& sed -i -e 's|\(.*if \[ \$OS = "linux" \]; then\)|if \[ \$OS = "n/a" \]; then|' dist/spoon.sh \
	&& mv dist /. \
	&& rm -rf /pentaho-kettle-*


#
# Stage 2/2: Install
#
FROM zhicwu/java:8

# Set maintainer details
MAINTAINER Zhichun Wu <zhicwu@gmail.com>

# Set environment variables
ENV PDI_VERSION=7.1.0.5-70 KETTLE_HOME=/data-integration

# Set label
LABEL java_server="Pentaho Data Integration $PDI_VERSION Community Edition"

# Update system
RUN apt-get update \
	&& mkdir -p $KETTLE_HOME \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# Copy PDI files
COPY --from=builder /dist $KETTLE_HOME

# Switch directory
WORKDIR $KETTLE_HOME
