# Docker compose files

These Docker compose files can be used to quickly try out the Opencast system in
different configurations. They are not designed to be production instances, but
rather quick and dirty dev/demo instances.

## Usage

Within this directory you simply can run these commands to startup an Opencast
system:

```sh
$ docker-compose -f <docker-compose-file>.yml up
```

There are multiple compose files you can choose from, showcasing the different
ways one can use the Docker images:

-   [**`docker-compose.allinone.h2.yml`**](docker-compose.allinone.h2.yml)<br>
    This setup starts a simple allinone Opencast distribution with an Apache
    ActiveMQ Server and the internal H2 Database.

-   [**`docker-compose.allinone.mariadb.yml`**](docker-compose.allinone.mariadb.yml)<br>
    This setup starts a simple allinone Opencast distribution with an Apache
    ActiveMQ server and an external MariaDB server.

-   [**`docker-compose.multiserver.mariadb.yml`**](docker-compose.multiserver.mariadb.yml)<br>
    This setup starts a multiserver Opencast distribution with one admin, worker
    and presentation server as well as an Apache ActiveMQ server and an external
    MariaDB server.
