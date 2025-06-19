# [Opencast Container Images](https://quay.io/organization/opencast)

-   [Introduction](#introduction)
-   [Installation](#installation)
-   [Build](#build)
    -   [NVIDIA CUDA Support](#nvidia-cuda-support)
-   [Quick Start](#quick-start)
-   [Images](#images)
    -   [`allinone`](#allinone)
    -   [`admin`, `worker`, `adminpresentation`, `ingest` and `presentation`](#admin-worker-adminpresentation-ingest-and-presentation)
    -   [`build`](#build)
-   [Usage](#usage)
-   [Configuration](#configuration)
    -   [Opencast](#opencast)
    -   [Elasticsearch](#elasticsearch)
    -   [Database](#database)
        -   [H2](#h2)
        -   [MariaDB and PostgreSQL](#mariadb-and-postgresql)
    -   [whisper.cpp](#whisper.cpp)
    -   [Miscellaneous](#miscellaneous)
-   [Data](#data)
-   [Languages](#languages)
-   [References](#references)

## Introduction

This repository holds `Dockerfiles` for creating [Opencast](http://www.opencast.org/) container images.

## Installation

All images are available on [Quay](https://quay.io/organization/opencast). To install the image simply pull the distribution you want:

```sh
$ docker pull "quay.io/opencast/<distribution>"
```

To install a specific version, use the following command:

```sh
$ docker pull "quay.io/opencast/<distribution>:<version>"
```

## Build

If you want to build the images yourself, there is a `Makefile` with the necessary `docker build` commands for all distributions. Running `make` in the root directory will create all images. To customize the build, you can override these variables:

-   `OPENCAST_REPO`<br>
     The git repository to clone Opencast from. The default is the upstream repository, but you can use your own fork.
-   `OPENCAST_VERSION`<br>
     The name of the Git branch, tag or commit hash to check out. Defaults to the content of the `VERSION_OPENCAST` file.
-   `FFMPEG_VERSION`<br>
     The version of the Opencast FFmpeg build. Defaults to the content of the `VERSION_FFMPEG` file.
-   `WHISPER_CPP_VERSION`<br>
     The version of whisper.cpp. Defaults to the content of the `VERSION_WHISPER_CPP` file.
-   `IMAGE_BASE`<br>
     The base used for the images (either `default` or `nvidia-cuda`). Defaults to `default`.
-   `IMAGE_REGISTRY`<br>
     The first part of the image name. It defaults to `quay.io/opencast` and will be extended by the name of the Opencast distribution.
-   `IMAGE_TAG`<br>
     The tag of the image. Defaults to the content of the `VERSION` file.
-   `DOCKER_BUILD_ARGS`<br>
     Custom arguments that should be passed to `docker build`, e.g. you can set this to `--no-cache` to force an image build. By default empty.
-   `GIT_COMMIT`<br>
     Overwrites the Git commit hash that is set as image label.
-   `BUILD_DATE`<br>
     Overwrites the build date that is set as image label.

### NVIDIA CUDA Support

Currently, there are not pre-built images for NVIDIA CUDA, but you can easily build them yourself:

```sh
$ make IMAGE_BASE=nvidia-cuda build-worker
```

Note that only whisper.cpp is compiled for NVIDIA CUDA; the included FFmpeg binary does not support NVIDIA CUDA at the moment.

## Quick Start

A quick local test system can be started using [`docker compose`](https://docs.docker.com/compose/). After cloning this repository you can run this command from the root directory:

```sh
$ docker compose -p opencast-allinone -f compose/compose.allinone.h2.yaml up
```

This will run Opencast using the `allinone` distribution configured to use the bundled [H2 Database Engine](http://www.h2database.com/html/main.html).

In the `./compose` directory there are also compose files for more production-like setups. `compose.allinone.mariadb.yaml` and `compose.allinone.postgresql.yaml` uses the MariaDB and PostgreSQL databases, respectively, while `compose.multiserver.mariadb.yaml` and `compose.multiserver.postgresql.yaml` demonstrate how to connect the different distributions. Replace the compose file in the command above if you want to use them instead. You can find more information about the compose files [here](docker-compose/README.md).

## Images

Opencast comes in different distributions. For each of the official distributions, there is a specific container image. Each version is tagged. For example, the full image name containing the `admin` distribution at version `19-dev` is `quay.io/opencast/admin:19-dev`. Leaving the version out will install the latest one.

### `allinone`

This image contains all Opencast modules necessary to run a full Opencast installation. It's useful for small and local test setups. If you, however, want to run Opencast in a distributed fashion, you probably should use a combination of `admin`, `worker` and `presentation` containers.

### `admin`, `adminpresentation`, `ingest`, `presentation` and `worker`,

These images contain the Opencast modules of the corresponding Opencast distributions.

### `build`

This image helps you set up a development environment for Opencast:

```sh
$ export OPENCAST_SRC=</path/to/my/opencast/code>
$ export OPENCAST_BUILD_USER_UID=$(id -u)
$ export OPENCAST_BUILD_USER_GID=$(id -g)

$ docker compose -p opencast-build -f compose/compose.build.yaml up -d
$ docker compose -p opencast-build -f compose/compose.build.yaml exec --user opencast-builder opencast bash
```

After attaching you can press enter to force the shell to output a prompt.

Starting with `2.2.2` there will be a `build` image for every release of Opencast. It will know how to build this specific version within the container. While you can use `git` to check out different versions of Opencast, we recommend that with it you then also change the version of the `build` container.

## Usage

The images come with multiple commands. You can see a full list with description by running:

```sh
$ docker run --rm quay.io/opencast/<distribution> app:help
Usage:
  app:help         Prints the usage information
  app:init         Checks and configures Opencast but does not run it
  app:start        Starts Opencast
  [cmd] [args...]  Runs [cmd] with given arguments
```

## Configuration

It's recommended to configure Opencast by using [Docker Volumes](https://docs.docker.com/engine/containers/run/#filesystem-mounts):

```sh
$ docker run -v "/path/to/opencast-etc:/etc/opencast" quay.io/opencast/<distribution>
```

Note that `/path/to/opencast-etc` only needs to contain configuration files you changed. During startup, those will be complement with the additional default configuration files.

The most important settings can also be configured with [environment variables](https://docs.docker.com/engine/containers/run/#environment-variables). You can use this functionally to generate new configuration files. For this, start a new container with specific variables and execute the `app:init` command. This will ensure you haven't missed anything, write the configuration files and exit. Then you can copy the files to a target directory:

```sh
$ docker run --name opencast_generate_config \
  -e "ORG_OPENCASTPROJECT_SERVER_URL=http://localhost:8080" \
  -e "ORG_OPENCASTPROJECT_SECURITY_ADMIN_USER=admin" \
  -e "ORG_OPENCASTPROJECT_SECURITY_ADMIN_PASS=opencast" \
  -e "ORG_OPENCASTPROJECT_SECURITY_DIGEST_USER=opencast_system_account" \
  -e "ORG_OPENCASTPROJECT_SECURITY_DIGEST_PASS=CHANGE_ME" \
  quay.io/opencast/<distribution> "app:init"
$ docker cp opencast_generate_config:/opencast/etc opencast-config
$ docker rm opencast_generate_config
```

Make sure to use the correct Opencast distribution as there are small differences.

### Opencast

-   `ORG_OPENCASTPROJECT_SERVER_URL` Optional<br>
    The HTTP-URL where Opencast is accessible. The default is `http://<Fully Qualified Host Name>:8080`.
-   `ORG_OPENCASTPROJECT_SECURITY_ADMIN_USER` **Required**<br>
    Username of the admin user.
-   `ORG_OPENCASTPROJECT_SECURITY_ADMIN_PASS` **Required**<br>
    Password of the admin user. You may alternatively set `ORG_OPENCASTPROJECT_SECURITY_ADMIN_PASS_FILE` to the location of a file within the container that contains the password.
-   `ORG_OPENCASTPROJECT_SECURITY_DIGEST_USER` **Required**<br>
    Username for the communication between Opencast nodes and capture agents.
-   `ORG_OPENCASTPROJECT_SECURITY_DIGEST_PASS` **Required**<br>
    Password for the communication between Opencast nodes and capture agents. You may alternatively set `ORG_OPENCASTPROJECT_SECURITY_DIGEST_PASS_FILE` to the location of a file within the container that contains the password.
-   `ORG_OPENCASTPROJECT_DOWNLOAD_URL` Optional<br>
    The HTTP-URL to use for downloading media files, e.g. for the player. Defaults to `${org.opencastproject.server.url}/static`.
-   `ORG_OPENCASTPROJECT_ADMIN_EMAIL` Optional<br>
    Email address of the server's admin. Defaults to `example@opencast.org`.

For an installation with multiple nodes you can also set:

-   `PROP_ORG_OPENCASTPROJECT_FILE_REPO_URL` Optional<br>
    HTTP-URL of the file repository. Defaults to `${org.opencastproject.server.url}` in the `allinone` distribution and `${org.opencastproject.admin.ui.url}` for every other one.
-   `PROP_ORG_OPENCASTPROJECT_ADMIN_UI_URL` **Required for all but `allinone`**<br>
    HTTP-URL of the admin node.
-   `PROP_ORG_OPENCASTPROJECT_ENGAGE_UI_URL` **Required for all but `allinone`**<br>
    HTTP-URL of the engage node.

### Elasticsearch

-   `ELASTICSEARCH_SERVER_HOST` **Required for `allinone`, `develop` and `admin`**<br>
    Hostname to Elasticsearch.
-   `ELASTICSEARCH_SERVER_SCHEME` Optional<br>
    Protocol to use when accessing Elasticsearch. Either `http` or `https`. The default is `http`.
-   `ELASTICSEARCH_SERVER_PORT` Optional<br>
    Port number of Elasticsearch. The default is `9200`.
-   `ELASTICSEARCH_USERNAME` Optional<br>
    Username to use when accessing Elasticsearch. The default is none.
-   `ELASTICSEARCH_PASSWORD` Optional<br>
    Password to use when accessing Elasticsearch. The default is none.
-   `NUMBER_OF_TIMES_TRYING_TO_CONNECT_TO_ELASTICSEARCH` Optional<br>
    Specifies how often Opencast is going to try to establish a TCP connection to the specified Elasticsearch cluster before giving up. The waiting time between tries is 5 seconds. The default number of tries is 25.  Setting this to 0 skips the check.

### Database

-   `ORG_OPENCASTPROJECT_DB_VENDOR` Optional<br>
    The type of database to use. Currently, you can set this to either `H2`, `MariaDB`, or `PostgreSQL`. The default is `H2`.
-   `NUMBER_OF_TIMES_TRYING_TO_CONNECT_TO_DB` Optional<br>
    Specifies how often Opencast is going to try to connect to the specified database before giving up. The waiting time between tries is 5 seconds. The default number of tries is 25. This configuration only applies if the database is not H2. Setting this to 0 skips the check.

#### H2

There are no additional environment variables you can set if you are using the H2 database.

#### MariaDB and PostgreSQL

-   `ORG_OPENCASTPROJECT_DB_JDBC_URL` **Required**<br>
    [JDBC](http://www.oracle.com/technetwork/java/javase/jdbc/index.html) connection string.
-   `ORG_OPENCASTPROJECT_DB_JDBC_USER` **Required**<br>
    Database username.
-   `ORG_OPENCASTPROJECT_DB_JDBC_PASS` **Required**<br>
    Password of the database user. You may alternatively set `ORG_OPENCASTPROJECT_DB_JDBC_PASS_FILE` to the location of a file within the container that contains the password.

### whisper.cpp

-   `WHISPER_CPP_DOWNLOAD_GGML_MODEL` Optional<br>
    Download the specified ggml whisper.cpp model. Note that models are downloaded in parallel to the startup of Opencast. Not waiting for model downloads greatly improves the Opencast startup time. However, transcription operations may fail if models are not available yet. The default is an empty string, i.e. no model is downloaded.

-   `WHISPER_CPP_DOWNLOAD_VAD_MODEL` Optional<br>
    Download the specified Voice Activity Detection (VAD) whisper.cpp model. Note that models are downloaded in parallel to the startup of Opencast. Not waiting for model downloads greatly improves the Opencast startup time. However, transcription operations may fail if models are not available yet. The default is an empty string, i.e. no model is downloaded.

### Miscellaneous

-   `TIMEZONE` Optional<br>
    Set the timezone within the container. Valid timezones are represented by files in `/usr/share/zoneinfo/`, for example, `Europe/Berlin`. The default is `UTC`.

## Data

The data directory is located at `/data`. Use [Docker Volumes](https://docs.docker.com/engine/reference/run/#volume-shared-filesystems) to mount this directory on your host.

## Languages

Opencast makes use of [Tesseract](https://github.com/tesseract-ocr/tesseract) to recognize text in videos (ORC). For this, [training data files](https://github.com/tesseract-ocr/tessdata) are needed. These images come with files for the English language. If you need other or more languages you can extend these images or use Docker Volumes to mount them in the appropriate directories `/usr/share/tessdata`.

## References

-   [Project site](https://github.com/opencast/opencast-docker)
-   [Opencast documentation](https://docs.opencast.org/develop/admin/)
-   [Images on Quay](https://quay.io/organization/opencast)
