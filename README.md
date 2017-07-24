# docker-pdi-ce
Docker image for Pentaho Data Integration(PDI, aka Kettle) server community edition. https://hub.docker.com/r/zhicwu/pdi-ce/

## What's inside
```
ubuntu:16.04
 |- phusion/baseimage:0.9.22
    |- zhicwu/java:8
       |- zhicwu/pdi-ce:7.1-base
          |- zhicwu/pdi-ce:7.1-full
             |- zhicwu/pdi-ce:7.1
```
* Official Ubuntu 16.04 LTS docker image
* [Phusion Base Image](https://github.com/phusion/baseimage-docker) 0.9.22
* Oracle JDK 8 latest release
* [Pentaho Data Integration Community Edition](http://community.pentaho.com/) 7.1.0.0-12 with the followings:
    * Up-to-date JDBC drivers:
        * [PostgreSQL JDBC Driver](https://jdbc.postgresql.org/) 42.1.3
        * [MySQL Connector/J](http://dev.mysql.com/downloads/connector/j/) 5.1.42
        * [jTDS](https://sourceforge.net/projects/jtds/) 1.3.1
        * [H2DB](http://www.h2database.com) 1.4.196
        * [HSQLDB](http://hsqldb.org/) 2.4.0
        * [Cassandra JDBC Driver](https://github.com/zhicwu/cassandra-jdbc-driver) 0.6.4
    * Latest [clustering workaround](/zhicwu/pdi-cluster)

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
# docker-compose up -d
```
You should now be able to use admin/password to access the PDI server via [http://localhost:8080/kettle/status](http://localhost:8080/kettle/status).

## How to build
```
# git clone https://github.com/zhicwu/docker-pdi-ce.git
# cd docker-pdi-ce
# docker-compose build
```
