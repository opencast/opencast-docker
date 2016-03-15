# docker-compose files

These docker-compose files can be used to quickly try out the Opencast system in
different configurations. They are not designed to be production instances, but
rather quick and dirty dev/demo instances.

# AllInOne, HSQL

Usage:
```sh
$ docker-compose -f docker-compose.allinone.hsql.yml up
```

This setup starts a simple allinone opencast distribution with a Apache ActiveMQ
Server and the internal HSQL Database.

# AllInOne, MariaDB

Usage:
```sh
$ docker-compose -f docker-compose.allinone.mariadb.yml up
```

This setup starts a simple allinone opencast distribution with a Apache ActiveMQ
server and a external MariaDB server.

# Multiserver, MariaDB

This setup is a little bit more complicated. Because the opencast nodes
need to talk to each other, but also provide a externally known address for the
engage interface, we first have to supply a valid hostname or IP address for the
host on which those containers are running. A simple `localhost` or `127.0.0.1`
will _not_ work.

Usage:
```sh
# set a environment variable with a valid IP address, e.g. 10.25.40.2
$ export HOSTIP=10.25.40.2
# start the system with docker-compose, which will now know this IP address.
$ docker-compose -f docker-compose.multiserver.mariadb.yml
```
