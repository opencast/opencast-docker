# Copyright 2016 The University of Münster eLectures Team All rights reserved.
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

FROM --platform=${BUILDPLATFORM} docker.io/alpine:edge AS build-ffmpeg
ARG TARGETARCH
ARG FFMPEG_VERSION="release"
RUN apk add --no-cache \
      curl \
      tar \
      xz \
 && mkdir -p /tmp/ffmpeg \
 && cd /tmp/ffmpeg \
 && curl -sSL "https://s3.opencast.org/opencast-ffmpeg-static/ffmpeg-${FFMPEG_VERSION}-${TARGETARCH}-static.tar.xz" \
     | tar xJf - --strip-components 1 --wildcards '*/ffmpeg' '*/ffprobe' \
 && chown root:root ff* \
 && mv ff* /usr/local/bin


FROM docker.io/eclipse-temurin:17-jdk AS build-whisper-cpp
ARG WHISPER_CPP_VERSION="master"
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      g++ \
      gcc \
      git \
      libc-dev \
      make
RUN mkdir -p /tmp/whisper.cpp
WORKDIR /tmp/whisper.cpp
RUN git clone https://github.com/ggerganov/whisper.cpp.git . \
 && git checkout "$WHISPER_CPP_VERSION"
RUN make -j \
 && sed -i 's#models_path=.*$#models_path=/usr/share/whisper.cpp/models/#' models/download-ggml-model.sh
RUN mkdir -p out \
 && mv main out/whisper.cpp \
 && mv quantize out/whisper.cpp-quantize \
 && mv server out/whisper.cpp-server \
 && mv models/download-ggml-model.sh out/whisper.cpp-model-download


FROM --platform=${BUILDPLATFORM} docker.io/maven:3-eclipse-temurin-17 AS build-opencast

ARG OPENCAST_REPO="https://github.com/opencast/opencast.git"
ARG OPENCAST_VERSION="develop"

ENV OPENCAST_SRC="/usr/src/opencast" \
    OPENCAST_HOME="/opencast" \
    OPENCAST_UHOME="/home/opencast" \
    OPENCAST_UID="800" \
    OPENCAST_GID="800" \
    OPENCAST_USER="opencast" \
    OPENCAST_GROUP="opencast"

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates \
      git \
      gzip \
      tar

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


FROM docker.io/eclipse-temurin:17-jdk
LABEL org.opencontainers.image.base.name="docker.io/eclipse-temurin:17-jdk"

ENV OPENCAST_HOME="/opencast" \
    OPENCAST_DATA="/data" \
    OPENCAST_CUSTOM_CONFIG="/etc/opencast" \
    OPENCAST_USER="opencast" \
    OPENCAST_GROUP="opencast" \
    OPENCAST_UHOME="/home/opencast" \
    OPENCAST_UID="800" \
    OPENCAST_GID="800" \
    WHISPER_CPP_MODELS="/usr/share/whisper.cpp/models"
ENV OPENCAST_CONFIG="${OPENCAST_HOME}/etc" \
    OPENCAST_SCRIPTS="${OPENCAST_HOME}/docker/scripts" \
    OPENCAST_STAGE_BASE_HOME="${OPENCAST_HOME}/docker/stage/base" \
    OPENCAST_STAGE_OUT_HOME="${OPENCAST_HOME}/docker/stage/out"

RUN groupadd --system -g "${OPENCAST_GID}" "${OPENCAST_GROUP}" \
 && useradd --system -M -N -g "${OPENCAST_GROUP}" -d "${OPENCAST_UHOME}" -u "${OPENCAST_UID}" "${OPENCAST_USER}" \
 && mkdir -p "${OPENCAST_DATA}" "${OPENCAST_UHOME}" "${WHISPER_CPP_MODELS}" \
 && chown -R "${OPENCAST_USER}:${OPENCAST_GROUP}" "${OPENCAST_DATA}" "${OPENCAST_UHOME}" "${WHISPER_CPP_MODELS}"

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      fontconfig \
      fonts-dejavu \
      fonts-freefont-ttf \
      fonts-liberation \
      fonts-linuxlibertine \
      gosu \
      inotify-tools \
      jq \
      netcat-openbsd \
      openssl \
      rsync \
      tesseract-ocr \
      tesseract-ocr-eng \
      tzdata \
 && rm -rf /var/lib/apt/lists/*

COPY --from=build-ffmpeg       /usr/local/bin/ff*      /usr/local/bin/
COPY --from=build-whisper-cpp  /tmp/whisper.cpp/out/*  /usr/local/bin/
COPY --from=build-opencast     "${OPENCAST_HOME}"      "${OPENCAST_HOME}"
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

LABEL maintainer="University of Münster eLectures Team <electures.dev@uni-muenster.de>" \
      org.opencontainers.image.title="opencast-${OPENCAST_DISTRIBUTION}" \
      org.opencontainers.image.description="container image for the Opencast ${OPENCAST_DISTRIBUTION} distribution" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.vendor="Opencast" \
      org.opencontainers.image.authors="University of Münster eLectures Team <electures.dev@uni-muenster.de>" \
      org.opencontainers.image.licenses="ECL-2.0" \
      org.opencontainers.image.url="https://github.com/opencast/opencast-docker/blob/${VERSION}/README.md" \
      org.opencontainers.image.documentation="https://github.com/opencast/opencast-docker/blob/${VERSION}/README.md" \
      org.opencontainers.image.source="https://github.com/opencast/opencast-docker" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.revision="${GIT_COMMIT}"

HEALTHCHECK --timeout=10s CMD /docker-healthcheck.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["app:start"]
