# Compose Files

These compose files can be used to quickly try out the Opencast system in different configurations. They are not
designed to be production instances, but rather quick and dirty dev/demo instances.

## Usage

Within this directory you simply can run these commands to startup an Opencast system:

```sh
$ docker compose -f <compose-file>.yaml up
```

There are multiple compose files you can choose from, showcasing the different ways one can use the container images:

-   [**`compose.allinone.h2.yaml`**](compose.allinone.h2.yaml)<br>
    This setup starts a simple allinone Opencast distribution including OpenSearch and the internal H2 database.

-   [**`compose.allinone.h2+pyca.yaml`**](compose.allinone.h2+pyca.yaml)<br>
    This setup starts a simple allinone Opencast distribution including OpenSearch, the internal H2 database, and pyCA
    as capture agent.

-   [**`compose.allinone.mariadb.yaml`**](compose.allinone.mariadb.yaml)<br>
    This setup starts a simple allinone Opencast distribution including OpenSearch and MariaDB.

-   [**`compose.allinone.postgres.yaml`**](compose.allinone.postgres.yaml)<br>
    This setup starts a simple allinone Opencast distribution including OpenSearch and PostgreSQL.

-   [**`compose.build.yaml`**](compose.build.yaml)<br>
    This setup starts a simple allinone Opencast distribution including OpenSearch and the internal H2 database using
    the `build` container image. This is useful for development and testing.

-   [**`compose.multiserver.build.yaml`**](compose.multiserver.build.yaml)<br>
    This setup starts a multiserver Opencast distribution with one admin, worker and presentation including OpenSearch
    and MariaDB using the `build` container image. This is useful for development and testing.

-   [**`compose.multiserver.mariadb.yaml`**](compose.multiserver.mariadb.yaml)<br>
    This setup starts a multiserver Opencast distribution with one admin, worker and presentation including OpenSearch
    and MariaDB.

-   [**`compose.multiserver.postgres.yaml`**](compose.multiserver.postgres.yaml)<br>
    This setup starts a multiserver Opencast distribution with one admin, worker and presentation including OpenSearch
    and PostgreSQL.
