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

FROM maven:3.6-jdk-8-slim
LABEL maintainer="WWU eLectures team <electures.dev@uni-muenster.de>" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.version="8.5" \
      org.label-schema.name="opencast-build" \
      org.label-schema.description="Image that provides an Opencast build and development environment" \
      org.label-schema.usage="https://github.com/opencast/opencast-docker/blob/8.5/README.md" \
      org.label-schema.url="http://www.opencast.org/" \
      org.label-schema.vcs-url="https://github.com/opencast/opencast-docker" \
      org.label-schema.vendor="University of Münster" \
      org.label-schema.docker.debug="docker exec -it $CONTAINER bash"

ARG repo="https://github.com/opencast/opencast.git"
ARG branch="8.5"

ENV ORG_OPENCASTPROJECT_SECURITY_ADMIN_USER="admin" \
    ORG_OPENCASTPROJECT_SECURITY_ADMIN_PASS="opencast" \
    ORG_OPENCASTPROJECT_SECURITY_DIGEST_USER="opencast_system_account" \
    ORG_OPENCASTPROJECT_SECURITY_DIGEST_PASS="CHANGE_ME" \
    \
    OPENCAST_VERSION="8.5" \
    OPENCAST_SRC="/usr/src/opencast" \
    OPENCAST_HOME="/opencast" \
    OPENCAST_DATA="/data" \
    OPENCAST_CUSTOM_CONFIG="/etc/opencast" \
    OPENCAST_USER="opencast" \
    OPENCAST_GROUP="opencast" \
    OPENCAST_UID="800" \
    OPENCAST_GID="800" \
    OPENCAST_BUILD_ASSETS="/docker" \
    FFMPEG_VERSION="20200316042902-N-96975-gc467328f07"
ENV OPENCAST_SCRIPTS="${OPENCAST_HOME}/docker/scripts" \
    OPENCAST_SUPPORT="${OPENCAST_HOME}/docker/support" \
    OPENCAST_CONFIG="${OPENCAST_HOME}/etc" \
    OPENCAST_REPO="${repo}" \
    OPENCAST_BRANCH="${branch}"

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      sudo \
      tar gzip bzip2 xz-utils git \
      ca-certificates openssl \
      make gcc g++ libc-dev \
 && apt-get install -y --no-install-recommends \
      ca-certificates openssl tzdata curl jq \
      fontconfig fonts-dejavu fonts-freefont-ttf fonts-liberation fonts-linuxlibertine \
      hunspell hunspell-en-au hunspell-en-ca hunspell-en-gb hunspell-en-us hunspell-en-za \
      tesseract-ocr tesseract-ocr-eng \
      sox synfig \
      nfs-common netcat-openbsd \
  \
 && git clone https://github.com/ncopa/su-exec.git /tmp/su-exec \
 && cd /tmp/su-exec \
 && make \
 && cp su-exec /usr/local/sbin \
  \
 && mkdir -p /tmp/ffmpeg \
 && cd /tmp/ffmpeg \
 && curl -sSL "https://pkg.opencast.org/bin/ffmpeg/ffmpeg-${FFMPEG_VERSION}.tar.xz" \
     | tar xJf - --strip-components 1 --wildcards '*/ffmpeg' '*/ffprobe' \
 && chown root:root ff* \
 && mv ff* /usr/local/bin \
  \
 && groupadd --system -g "${OPENCAST_GID}" "${OPENCAST_GROUP}" \
 && useradd --system -M -N -g "${OPENCAST_GROUP}" -d "${OPENCAST_HOME}" -u "${OPENCAST_UID}" "${OPENCAST_USER}" \
 && mkdir -p "${OPENCAST_SRC}" "${OPENCAST_HOME}" "${OPENCAST_DATA}" "${OPENCAST_BUILD_ASSETS}" \
 && chown -R "${OPENCAST_USER}:${OPENCAST_GROUP}" "${OPENCAST_HOME}" "${OPENCAST_DATA}" \
 && echo "opencast-builder ALL = NOPASSWD: ALL" > /etc/sudoers.d/opencast-builder \
  \
 && cd \
 && rm -rf /tmp/* /var/lib/apt/lists/*

COPY assets/docker-entrypoint.sh /docker-entrypoint.sh
COPY assets/build "${OPENCAST_BUILD_ASSETS}/"
COPY assets/bin/* "/usr/local/bin/"

WORKDIR "${OPENCAST_SRC}"

EXPOSE 8080 5005
VOLUME [ "${OPENCAST_DATA}", "${OPENCAST_SRC}", "/root/.m2" ]

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["bash"]
