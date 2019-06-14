# Copyright 2016 The WWU eLectures Team All rights reserved.
#
# Licensed under the Educational Community License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License. You may obtain a copy of the License at
#
#     http://opensource.org/licenses/ECL-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM maven:3.6-jdk-8-slim AS build

ARG repo="https://github.com/opencast/opencast.git"
ARG branch="7.0"

ENV OPENCAST_DISTRIBUTION="adminpresentation" \
    OPENCAST_SRC="/usr/src/opencast" \
    OPENCAST_HOME="/opencast" \
    OPENCAST_UID="800" \
    OPENCAST_GID="800" \
    OPENCAST_USER="opencast" \
    OPENCAST_GROUP="opencast" \
    OPENCAST_REPO="${repo}" \
    OPENCAST_BRANCH="${branch}"

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      tar gzip bzip2 git \
      ca-certificates openssl \
      make gcc g++ libc-dev \
  \
 && git clone https://github.com/ncopa/su-exec.git /tmp/su-exec \
 && cd /tmp/su-exec \
 && make \
 && cp su-exec /usr/local/sbin \
 && rm -rf /tmp/* /var/lib/apt/lists/* \
  \
 && groupadd --system -g "${OPENCAST_GID}" "${OPENCAST_GROUP}" \
 && useradd --system -M -N -g "${OPENCAST_GROUP}" -d "${OPENCAST_HOME}" -u "${OPENCAST_UID}" "${OPENCAST_USER}" \
 && mkdir -p "${OPENCAST_SRC}" "${OPENCAST_HOME}" \
 && chown -R "${OPENCAST_USER}:${OPENCAST_GROUP}" "${OPENCAST_SRC}" "${OPENCAST_HOME}"

USER "${OPENCAST_USER}"

RUN git clone --recursive "${OPENCAST_REPO}" "${OPENCAST_SRC}" \
 && cd "${OPENCAST_SRC}" \
 && git checkout "${OPENCAST_BRANCH}" \
 && mvn --quiet --batch-mode install -DskipTests=true -Dcheckstyle.skip=true -DskipJasmineTests=true \
 && tar -xzf build/opencast-dist-${OPENCAST_DISTRIBUTION}-*.tar.gz --strip 1 -C "${OPENCAST_HOME}" \
 && rm -rf "${OPENCAST_SRC}"/* ~/.m2 ~/.npm ~/.node-gyp

FROM openjdk:8-jdk-slim-stretch
LABEL maintainer="WWU eLectures team <electures.dev@uni-muenster.de>" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.version="7.0" \
      org.label-schema.name="opencast-adminpresentation" \
      org.label-schema.description="Docker image for the Opencast adminpresentation distribution" \
      org.label-schema.usage="https://github.com/opencast/opencast-docker/blob/7.0/README.md" \
      org.label-schema.url="http://www.opencast.org/" \
      org.label-schema.vcs-url="https://github.com/opencast/opencast-docker" \
      org.label-schema.vendor="University of Münster" \
      org.label-schema.docker.debug="docker exec -it $CONTAINER sh" \
      org.label-schema.docker.cmd.help="docker run --rm quay.io/opencast/adminpresentation:7.0 app:help"

ENV OPENCAST_VERSION="7.0" \
    OPENCAST_DISTRIBUTION="adminpresentation" \
    OPENCAST_HOME="/opencast" \
    OPENCAST_DATA="/data" \
    OPENCAST_CUSTOM_CONFIG="/etc/opencast" \
    OPENCAST_USER="opencast" \
    OPENCAST_GROUP="opencast" \
    OPENCAST_UID="800" \
    OPENCAST_GID="800" \
    OPENCAST_REPO="${repo}" \
    OPENCAST_BRANCH="${branch}"
ENV OPENCAST_SCRIPTS="${OPENCAST_HOME}/docker/scripts" \
    OPENCAST_SUPPORT="${OPENCAST_HOME}/docker/support" \
    OPENCAST_CONFIG="${OPENCAST_HOME}/etc"

RUN groupadd --system -g "${OPENCAST_GID}" "${OPENCAST_GROUP}" \
 && useradd --system -M -N -g "${OPENCAST_GROUP}" -d "${OPENCAST_HOME}" -u "${OPENCAST_UID}" "${OPENCAST_USER}" \
 && mkdir -p "${OPENCAST_DATA}" \
 && chown -R "${OPENCAST_USER}:${OPENCAST_GROUP}" "${OPENCAST_DATA}"

COPY --from=build /usr/local/sbin/su-exec /usr/local/sbin/su-exec
COPY --chown=opencast:opencast --from=build "${OPENCAST_HOME}" "${OPENCAST_HOME}"
COPY --chown=opencast:opencast assets/scripts "${OPENCAST_SCRIPTS}"
COPY --chown=opencast:opencast assets/support "${OPENCAST_SUPPORT}"
COPY --chown=opencast:opencast assets/etc/* "${OPENCAST_CONFIG}/"
COPY assets/docker-entrypoint.sh assets/docker-healthcheck.sh /

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates openssl tzdata curl jq \
      fontconfig fonts-dejavu fonts-freefont-ttf fonts-liberation fonts-linuxlibertine \
      hunspell hunspell-en-au hunspell-en-ca hunspell-en-gb hunspell-en-us hunspell-en-za \
      tesseract-ocr tesseract-ocr-eng \
      ffmpeg libavcodec-extra sox synfig \
      nfs-common netcat-openbsd \
 && javac "${OPENCAST_SCRIPTS}/TryToConnectToDb.java" \
 && rm -rf /tmp/* /var/lib/apt/lists/* "${OPENCAST_SCRIPTS}/TryToConnectToDb.java"

WORKDIR "${OPENCAST_HOME}"

EXPOSE 8080
VOLUME [ "${OPENCAST_DATA}" ]

HEALTHCHECK --timeout=10s CMD /docker-healthcheck.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["app:start"]
