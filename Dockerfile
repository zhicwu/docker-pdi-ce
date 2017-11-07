#
# PDI image with necessary JDBC drivers in addition to 7.1-base
#

#
# Stage 1/2: Build
#
FROM maven:3.5.0-jdk-8 as builder

ENV CLICKHOUSE_DRIVER_VERSION=0.1.33

RUN wget --progress=dot:giga https://github.com/yandex/clickhouse-jdbc/archive/release_$CLICKHOUSE_DRIVER_VERSION.tar.gz \
	&& tar zxf *.tar.gz \
	&& cd clickhouse* \
	&& sed -i -e "s|<version>.*-SNAPSHOT</version>|<version>${CLICKHOUSE_DRIVER_VERSION}</version>|" \
		-e 's|\(</properties>\)|    <shade-plugin.version>2.4.3</shade-plugin.version>\n        <shade.base>ru.yandex.clickhouse.internal</shade.base>\n        \1|' \
		-e 's|\(<plugins>\)|\1\n            <plugin>\n                <groupId>org.apache.maven.plugins</groupId>\n                <artifactId>maven-shade-plugin</artifactId>\n                <version>${shade-plugin.version}</version>\n                <executions>\n                    <execution>\n                        <phase>package</phase>\n                        <goals>\n                            <goal>shade</goal>\n                        </goals>\n                        <configuration>\n                            <createSourcesJar>false</createSourcesJar>\n                            <shadeSourcesContent>false</shadeSourcesContent>\n                            <dependencyReducedPomLocation>${project.build.directory}/pom.xml</dependencyReducedPomLocation>\n                            <shadedArtifactAttached>true</shadedArtifactAttached>\n                            <shadedClassifierName>shaded</shadedClassifierName>\n                            <relocations>\n                                <relocation>\n                                    <pattern>org.apache</pattern>\n                                    <shadedPattern>${shade.base}.apache</shadedPattern>\n                                </relocation>\n                                <relocation>\n                                    <pattern>org.joda</pattern>\n                                    <shadedPattern>${shade.base}.joda</shadedPattern>\n                                </relocation>\n                                <relocation>\n                                    <pattern>com.fasterxml</pattern>\n                                    <shadedPattern>${shade.base}.jackson</shadedPattern>\n                                </relocation>\n                                <relocation>\n                                    <pattern>com.google</pattern>\n                                    <shadedPattern>${shade.base}.google</shadedPattern>\n                                </relocation>\n                                <relocation>\n                                    <pattern>net.jpountz</pattern>\n                                    <shadedPattern>${shade.base}.lz4</shadedPattern>\n                                </relocation>\n                                <relocation>\n                                    <pattern>org.slf4j</pattern>\n                                    <shadedPattern>${shade.base}.slf4j</shadedPattern>\n                                </relocation>\n                            </relocations>\n                            <transformers>\n                                <transformer\n                                        implementation="org.apache.maven.plugins.shade.resource.ComponentsXmlResourceTransformer"/>\n                            </transformers>\n                            <filters>\n                                <filter>\n                                    <artifact>*:*</artifact>\n                                    <excludes>\n                                        <exclude>META-INF/maven/**</exclude>\n                                        <exclude>META-INF/*.xml</exclude>\n                                    </excludes>\n                                </filter>\n                            </filters>\n                        </configuration>\n                    </execution>\n                </executions>\n            </plugin>|' \
		pom.xml \
	&& mvn -DskipTests clean package \
&& mv target/*shaded.jar /.

#
# Stage 2/2: Install
#
FROM zhicwu/pdi-ce:7.1-base

# Set maintainer details
MAINTAINER Zhichun Wu <zhicwu@gmail.com>

# Set environment variables
ENV POSTGRESQL_DRIVER_VERSION=42.1.4 MYSQL_DRIVER_VERSION=5.1.44 \
	JTDS_VERSION=1.3.1 CASSANDRA_DRIVER_VERSION=0.6.4 \
	H2DB_VERSION=1.4.196 HSQLDB_VERSION=2.4.0 CLICKHOUSE_DRIVER_VERSION=0.1.33

# Add JDBC drivers
COPY --from=builder /clickhouse-jdbc-$CLICKHOUSE_DRIVER_VERSION-shaded.jar lib/.
RUN wget --progress=dot:giga https://jdbc.postgresql.org/download/postgresql-${POSTGRESQL_DRIVER_VERSION}.jar \
		http://central.maven.org/maven2/mysql/mysql-connector-java/${MYSQL_DRIVER_VERSION}/mysql-connector-java-${MYSQL_DRIVER_VERSION}.jar \
		http://central.maven.org/maven2/net/sourceforge/jtds/jtds/${JTDS_VERSION}/jtds-${JTDS_VERSION}.jar \
		http://central.maven.org/maven2/com/github/zhicwu/cassandra-jdbc-driver/${CASSANDRA_DRIVER_VERSION}/cassandra-jdbc-driver-${CASSANDRA_DRIVER_VERSION}-shaded.jar \
		http://central.maven.org/maven2/com/h2database/h2/${H2DB_VERSION}/h2-${H2DB_VERSION}.jar \
		http://central.maven.org/maven2/org/hsqldb/hsqldb/${HSQLDB_VERSION}/hsqldb-${HSQLDB_VERSION}.jar \
	&& rm -f lib/postgre*.jar lib/mysql*.jar lib/jtds*.jar lib/h2*.jar lib/hsqldb*.jar \
	&& mv *.jar lib/.
