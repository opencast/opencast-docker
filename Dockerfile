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

FROM docker.io/maven:3-jdk-11-slim AS build

ARG OPENCAST_REPO="https://github.com/opencast/opencast.git"
ARG OPENCAST_VERSION="develop"
ARG FFMPEG_VERSION="latest"

ENV OPENCAST_SRC="/usr/src/opencast" \
    OPENCAST_HOME="/opencast" \
    OPENCAST_UHOME="/home/opencast" \
    OPENCAST_UID="800" \
    OPENCAST_GID="800" \
    OPENCAST_USER="opencast" \
    OPENCAST_GROUP="opencast" \
    FFMPEG_VERSION="${FFMPEG_VERSION}"

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      bzip2 \
      ca-certificates \
      g++ \
      gcc \
      git \
      gzip \
      libc-dev \
      make \
      openssl \
      tar \
      xz-utils

RUN git clone https://github.com/ncopa/su-exec.git /tmp/su-exec \
 && cd /tmp/su-exec \
 && make \
 && cp su-exec /usr/local/sbin

RUN mkdir -p /tmp/ffmpeg \
 && cd /tmp/ffmpeg \
 && curl -sSL "https://s3.opencast.org/opencast-ffmpeg-static/ffmpeg-${FFMPEG_VERSION}.tar.xz" \
     | tar xJf - --strip-components 1 --wildcards '*/ffmpeg' '*/ffprobe' \
 && chown root:root ff* \
 && mv ff* /usr/local/bin

RUN groupadd --system -g "${OPENCAST_GID}" "${OPENCAST_GROUP}" \
 && useradd --system -M -N -g "${OPENCAST_GROUP}" -d "${OPENCAST_UHOME}" -u "${OPENCAST_UID}" "${OPENCAST_USER}" \
 && mkdir -p "${OPENCAST_SRC}" "${OPENCAST_HOME}" "${OPENCAST_UHOME}" \
 && chown -R "${OPENCAST_USER}:${OPENCAST_GROUP}" "${OPENCAST_SRC}" "${OPENCAST_HOME}" "${OPENCAST_UHOME}"

USER "${OPENCAST_USER}"
WORKDIR "${OPENCAST_SRC}"

RUN git clone --recursive "${OPENCAST_REPO}" . \
 && git checkout "${OPENCAST_VERSION}" \
 && sed -i "s#https://mvn.opencast.org/#https://radosgw.public.os.wwu.de/mvn.opencast.org/#" pom.xml
RUN mvn --batch-mode install \
      -Dmaven.wagon.httpconnectionManager.ttlSeconds=120 \
      -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=warn \
      -DskipTests=true \
      -Dcheckstyle.skip=true \
      -DskipJasmineTests=true
ARG OPENCAST_DISTRIBUTION
RUN tar -xzf build/opencast-dist-${OPENCAST_DISTRIBUTION}-*.tar.gz --strip 1 -C "${OPENCAST_HOME}"


FROM docker.io/eclipse-temurin:11-jdk
LABEL org.opencontainers.image.base.name="docker.io/eclipse-temurin:11-jdk"

ENV OPENCAST_HOME="/opencast" \
    OPENCAST_DATA="/data" \
    OPENCAST_CUSTOM_CONFIG="/etc/opencast" \
    OPENCAST_USER="opencast" \
    OPENCAST_GROUP="opencast" \
    OPENCAST_UHOME="/home/opencast" \
    OPENCAST_UID="800" \
    OPENCAST_GID="800"
ENV OPENCAST_CONFIG="${OPENCAST_HOME}/etc" \
    OPENCAST_SCRIPTS="${OPENCAST_HOME}/docker/scripts" \
    OPENCAST_STAGE_BASE_HOME="${OPENCAST_HOME}/docker/stage/base" \
    OPENCAST_STAGE_OUT_HOME="${OPENCAST_HOME}/docker/stage/out"

RUN groupadd --system -g "${OPENCAST_GID}" "${OPENCAST_GROUP}" \
 && useradd --system -M -N -g "${OPENCAST_GROUP}" -d "${OPENCAST_UHOME}" -u "${OPENCAST_UID}" "${OPENCAST_USER}" \
 && mkdir -p "${OPENCAST_DATA}" "${OPENCAST_UHOME}" \
 && chown -R "${OPENCAST_USER}:${OPENCAST_GROUP}" "${OPENCAST_DATA}" "${OPENCAST_UHOME}"

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      fontconfig \
      fonts-dejavu \
      fonts-freefont-ttf \
      fonts-liberation \
      fonts-linuxlibertine \
      hunspell \
      hunspell-en-au \
      hunspell-en-ca \
      hunspell-en-gb \
      hunspell-en-us \
      hunspell-en-za \
      inotify-tools \
      jq \
      netcat-openbsd \
      openssl \
      python3 \
      python3-pip \
      rsync \
      sox \
      synfig \
      tesseract-ocr \
      tesseract-ocr-eng \
      tzdata \
 && pip install \
      vosk-cli \
 && rm -rf /var/lib/apt/lists/*

COPY --from=build /usr/local/sbin/su-exec /usr/local/sbin/
COPY --from=build /usr/local/bin/ff* /usr/local/bin/
COPY --from=build "${OPENCAST_HOME}" "${OPENCAST_HOME}"
COPY rootfs /

ARG OPENCAST_REPO="https://github.com/opencast/opencast.git"
ARG OPENCAST_VERSION="develop"
ARG OPENCAST_DISTRIBUTION
ARG VERSION=unkown
ARG BUILD_DATE=unkown
ARG GIT_COMMIT=unkown

ENV OPENCAST_REPO=${OPENCAST_REPO} \
    OPENCAST_VERSION=${OPENCAST_VERSION} \
    OPENCAST_DISTRIBUTION=${OPENCAST_DISTRIBUTION}

RUN if [ "${OPENCAST_DISTRIBUTION}" = "allinone" ]; then \
      rm -f "${OPENCAST_CONFIG}/org.opencastproject.organization-mh_default_org.cfg-clustered"; \
    fi \
 && mv "${OPENCAST_CONFIG}/org.opencastproject.organization-mh_default_org.cfg-clustered" "${OPENCAST_CONFIG}/org.opencastproject.organization-mh_default_org.cfg" || true \
 && chown "${OPENCAST_USER}:${OPENCAST_GROUP}" "${OPENCAST_HOME}" "${OPENCAST_CONFIG}" \
 && chown -R "${OPENCAST_USER}:${OPENCAST_GROUP}" "${OPENCAST_HOME}/data" \
  \
 && mkdir -p "${OPENCAST_STAGE_BASE_HOME}" \
 && rsync -vrlog --chown=0:0 "${OPENCAST_CONFIG}" "${OPENCAST_STAGE_BASE_HOME}" \
  \
 && javac "${OPENCAST_SCRIPTS}/TryToConnectToDb.java" \
 && rm -rf /tmp/* "${OPENCAST_SCRIPTS}/TryToConnectToDb.java"

WORKDIR "${OPENCAST_HOME}"

EXPOSE 8080
VOLUME [ "${OPENCAST_DATA}" ]

LABEL maintainer="educast.nrw <info@educast.nrw>" \
      org.opencontainers.image.title="opencast-${OPENCAST_DISTRIBUTION}" \
      org.opencontainers.image.description="container image for the Opencast ${OPENCAST_DISTRIBUTION} distribution" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.vendor="Opencast" \
      org.opencontainers.image.authors="educast.nrw <info@educast.nrw>" \
      org.opencontainers.image.licenses="ECL-2.0" \
      org.opencontainers.image.url="https://github.com/opencast/opencast-docker/blob/${VERSION}/README.md" \
      org.opencontainers.image.documentation="https://github.com/opencast/opencast-docker/blob/${VERSION}/README.md" \
      org.opencontainers.image.source="https://github.com/opencast/opencast-docker" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.revision="${GIT_COMMIT}"

HEALTHCHECK --timeout=10s CMD /docker-healthcheck.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["app:start"]
