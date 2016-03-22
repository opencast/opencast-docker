# docker-compose files

These docker-compose files can be used to quickly try out the Opencast system in
different configurations. They are not designed to be production instances, but
rather quick and dirty dev/demo instances.

## AllInOne, HSQL

Usage:
```sh
$ docker-compose -f docker-compose.allinone.hsql.yml up
```

This setup starts a simple allinone Opencast distribution with an Apache
ActiveMQ Server and the internal HSQL Database.

## AllInOne, MariaDB

Usage:
```sh
$ docker-compose -f docker-compose.allinone.mariadb.yml up
```

This setup starts a simple allinone Opencast distribution with an Apache
ActiveMQ server and an external MariaDB server.

## Multiserver, MariaDB

This setup is a little bit more complicated. Because the Opencast nodes
need to talk to each other, but also provide an externally known address for the
engage interface, we first have to supply a valid hostname or IP address for the
host on which those containers are running. A simple `localhost` or `127.0.0.1`
will _not_ work.

Usage:
```sh
# set an environment variable with a valid IP address, e.g. 10.25.40.2
$ export HOSTIP=10.25.40.2
# start the system with docker-compose, which will now know this IP address.
$ docker-compose -f docker-compose.multiserver.mariadb.yml
```

### Wait, what? Why do I need to do that? Why will `localhost` not work?!

If you have the time and want to know what exactly happens in this example, let
me explain:

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
