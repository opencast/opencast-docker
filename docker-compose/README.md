# Docker compose files

These Docker compose files can be used to quickly try out the Opencast system in
different configurations. They are not designed to be production instances, but
rather quick and dirty dev/demo instances.

## Usage

Within this directory you simply can run these commands to startup an Opencast
system:

```sh
# set an environment variable with a valid IP address to the Docker host
$ export HOSTIP=10.25.40.2
$ docker-compose -f <docker-compose-file>.yml up
```

There are multiple compose files you can choose from, showcasing the different
ways one can use the Docker images:

* [**`docker-compose.allinone.hsql.yml`**](docker-compose.allinone.hsql.yml)  
  This setup starts a simple allinone Opencast distribution with an Apache
  ActiveMQ Server and the internal HSQL Database.

* [**`docker-compose.allinone.mariadb.yml`**](docker-compose.allinone.mariadb.yml)  
  This setup starts a simple allinone Opencast distribution with an Apache
  ActiveMQ server and an external MariaDB server.

* [**`docker-compose.multiserver.mariadb.yml`**](docker-compose.multiserver.mariadb.yml)  
  This setup starts a multiserver Opencast distribution with one admin, worker
  and presentation server as well as an Apache ActiveMQ server and an external
  MariaDB server.

### Wait, what? Why do I need to set `HOSTIP`? Why will `localhost` not work?!

If you have the time and want to know what exactly happens, let me explain:

The different Opencast nodes need a way to talk to each other, so that the
relaying of the different workflow operations works correctly.

The first (and usual) approach to that would be to use the hostnames of the
containers for those URLs (e.g. `PROP_ORG_OPENCASTPROJECT_ADMIN_UI_URL`). If you
do so, the links to the engage UI that will be generated from the admin UI will
use those URLs, too. The engage UI as well will try to link the media with one
of those provided URLs. If you now try to open those in a browser on your host,
it will fail to resolve the hostname. This is because the hostnames are only
known to the containers themselves, internally, but not to your host, which is
external to this environment.

The implemented solution is to agree on a hostname or IP address which is
reachable and resolvable both internally and externally. The complete
communication between the nodes will then be routed via this point (hence the
`EXPORT` on ports `8081` and `8082`). `docker-compose` does not provide a
(known) way of doing this automatically, so the user needs to find such a
suitable hostname or IP address themselves and export it to an environment
variable. This environment variable is then used in the docker-compose file to
build valid URLs that fulfill the special requirements.

In the multiserver case it is thus a requirement to set `HOSTIP` properly. The
allinone setups will work with `localhost` assuming the Docker host is reachable
locally. However on an operating system other than Linux this is not always the
case. To generalize the setup for all platforms, the `HOSTIP` was also
introduced to the other compose files.
