# docker-pdi-ce
Docker image for Pentaho Data Integration(PDI, aka Kettle) server community edition. https://hub.docker.com/r/zhicwu/pdi-ce/

## What's inside
```
ubuntu:14.04
 |
 |--- zhicwu/java:8
       |
       |--- zhicwu/pdi-ce:latest
```
* Official Ubuntu Trusty(14.04) docker image
* Oracle JDK 8 latest release
* [Pentaho Data Integration Community Edition](http://community.pentaho.com/) 6.1.0.1-196 with the followings:
 * Up-to-date JDBC drivers: [MySQL Connector/J](http://dev.mysql.com/downloads/connector/j/) 5.1.39, [jTDS](https://sourceforge.net/projects/jtds/) 1.3.1 and [Cassandra JDBC Driver](https://github.com/zhicwu/cassandra-jdbc-driver) 0.6.1
 * Latest [clustering workaround](/zhicwu/pdi-cluster)

## Known issues
* PDI does not log to docker logs properly - similar to [this](https://github.com/fabric8io/ipaas-quickstarts/issues/877), job/transformation logs will be replayed on remote master server
* PDI may hang on the first time startup - not able to reproduce now, try restart if it still exists

## How to use
**Note: The instructions below assumes you have [docker](https://docs.docker.com/engine/installation/) and [docker-compose](https://docs.docker.com/compose/install/) installed.**
- Download scripts
```
# git clone https://github.com/zhicwu/docker-pdi-ce.git
# cd docker-pdi-ce
```
- Edit .env and/or docker-compose.yml based on your needs
- Start PDI server
```
# docker-compose up
```
You should now be able to access the PDI server via http://localhost:8080/kettle/status.

## How to build
```
# git clone https://github.com/zhicwu/docker-pdi-ce.git
# cd docker-pdi-ce
# docker-compose build
```
