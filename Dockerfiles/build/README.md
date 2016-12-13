# opencast/build

In order to help you develop Opencast while sill using Docker containers the `opencast/build` image was created.

## Quick Start

```sh
$ export HOSTIP=<IP address of the Docker host>
$ export OPENCAST_SRC=</path/to/my/opencast/code>

$ docker-compose -p opencast-build -f docker-compose/docker-compose.build.yml up -d
$ docker-compose -p opencast-build -f docker-compose/docker-compose.build.yml exec opencast bash
```

## Getting the Code

Starting with `2.2.2` there will be a `build` image for every release of Opencast. It will know how to build this specific version within the container. While you can use `git` to check out different versions of Opencast, we recommend that with it you then also change the version of the `build` container. To get
