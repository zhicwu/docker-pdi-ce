#
# PDI base image
#

# Pull base image
FROM zhicwu/java:8

# Set maintainer details
MAINTAINER Zhichun Wu <zhicwu@gmail.com>

# Set environment variables
ENV PDI_VERSION=7.1 PDI_BUILD=7.1.0.0-12 KETTLE_HOME=/data-integration

# Update system
RUN apt-get update \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# Download PDI community edition and unpack
RUN wget --progress=dot:giga http://downloads.sourceforge.net/project/pentaho/Data%20Integration/${PDI_VERSION}/pdi-ce-${PDI_BUILD}.zip \
	&& unzip -q *.zip \
	&& rm -f *.zip \
	&& chmod +x $KETTLE_HOME/*.sh \
	&& sed -i -e 's|\(.*if \[ \$OS = "linux" \]; then\)|if \[ \$OS = "n/a" \]; then|' $KETTLE_HOME/spoon.sh

# Switch directory
WORKDIR $KETTLE_HOME
