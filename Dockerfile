#
# PDI image with necessary JDBC drivers in addition to 7.1-base
#

# Pull base image
FROM zhicwu/pdi-ce:7.1-base

# Set maintainer details
MAINTAINER Zhichun Wu <zhicwu@gmail.com>

# Set environment variables
ENV POSTGRESQL_DRIVER_VERSION=42.1.3 MYSQL_DRIVER_VERSION=5.1.42 \
	JTDS_VERSION=1.3.1 CASSANDRA_DRIVER_VERSION=0.6.4 \
	H2DB_VERSION=1.4.196 HSQLDB_VERSION=2.4.0

# Add JDBC drivers
RUN wget --progress=dot:giga https://jdbc.postgresql.org/download/postgresql-${POSTGRESQL_DRIVER_VERSION}.jar \
		http://central.maven.org/maven2/mysql/mysql-connector-java/${MYSQL_DRIVER_VERSION}/mysql-connector-java-${MYSQL_DRIVER_VERSION}.jar \
		http://central.maven.org/maven2/net/sourceforge/jtds/jtds/${JTDS_VERSION}/jtds-${JTDS_VERSION}.jar \
		http://central.maven.org/maven2/com/github/zhicwu/cassandra-jdbc-driver/${CASSANDRA_DRIVER_VERSION}/cassandra-jdbc-driver-${CASSANDRA_DRIVER_VERSION}-shaded.jar \
		http://central.maven.org/maven2/com/h2database/h2/${H2DB_VERSION}/h2-${H2DB_VERSION}.jar \
		http://central.maven.org/maven2/org/hsqldb/hsqldb/${HSQLDB_VERSION}/hsqldb-${HSQLDB_VERSION}.jar \
	&& rm -f lib/postgre*.jar lib/mysql*.jar lib/jtds*.jar lib/h2*.jar lib/hsqldb*.jar \
	&& mv *.jar lib/.
