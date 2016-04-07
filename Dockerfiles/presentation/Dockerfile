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

FROM maven:3-jdk-8
MAINTAINER WWU eLectures team <dev.learnweb@uni-muenster.de>

ENV OPENCAST_VERSION="2.1.1" \
    OPENCAST_DISTRIBUTION="presentation" \
    OPENCAST_SRC="/usr/src/opencast" \
    OPENCAST_HOME="/opencast" \
    OPENCAST_DATA="/data" \
    OPENCAST_CUSTOM_CONFIG="/etc/opencast" \
    OPENCAST_USER="opencast" \
    OPENCAST_GROUP="opencast" \
    OPENCAST_UID="800" \
    OPENCAST_GID="800"
ENV OPENCAST_SCRIPTS="${OPENCAST_HOME}/docker/scripts" \
    OPENCAST_CONFIG="${OPENCAST_HOME}/etc" \
    OPENCAST_URL="https://bitbucket.org/opencast-community/matterhorn/get/${OPENCAST_VERSION}.tar.bz2"

# Dependencies
#   - cURL and bzip2
#   - FFmpeg
#   - MediaInfo
#   - Sound eXchange (SoX)
#   - Tesseract Open Source OCR Engine
#   -   - english
#   -   - german
#   - TODO: which languages to include?
#   - Hunspell
#   -   - english
#   -   - german
#   - TODO: which languages to include?
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      curl bzip2 \
      ffmpeg \
      mediainfo \
      sox libsox-fmt-all \
      tesseract-ocr tesseract-ocr-eng tesseract-ocr-deu \
      hunspell hunspell-en-us hunspell-de-de \
 && rm -rf /var/lib/apt/lists/*

# Opencast
RUN mkdir -p "${OPENCAST_SRC}" "${OPENCAST_HOME}" "${OPENCAST_DATA}" "${OPENCAST_SCRIPTS}" \
 && groupadd -r "${OPENCAST_GROUP}" -g "${OPENCAST_GID}" \
 && useradd -r -g "${OPENCAST_GROUP}" -d "${OPENCAST_HOME}" -u "${OPENCAST_UID}" "${OPENCAST_USER}" \
 && chown "${OPENCAST_USER}":"${OPENCAST_GROUP}" "${OPENCAST_SRC}" "${OPENCAST_HOME}" "${OPENCAST_DATA}"

RUN cd "${OPENCAST_SRC}" \
 && curl -sSL "${OPENCAST_URL}" | tar -xj --strip 1 -C . \
 && mvn --quiet --batch-mode clean install -DskipTests=true -Dcheckstyle.skip=true \
 && tar -xzf "build/opencast-dist-${OPENCAST_DISTRIBUTION}-${OPENCAST_VERSION}.tar.gz" --strip 1 -C "${OPENCAST_HOME}" \
 && chown -R "${OPENCAST_USER}":"${OPENCAST_GROUP}" "${OPENCAST_HOME}" \
 && rm -rf "${OPENCAST_SRC}" /tmp/*

COPY assets/scripts/* "${OPENCAST_SCRIPTS}/"
COPY assets/etc/* "${OPENCAST_CONFIG}/"
COPY assets/etc/index/adminui/settings.yml "${OPENCAST_CONFIG}/index/adminui/"
RUN javac "${OPENCAST_SCRIPTS}/TryToConnectToDb.java" \
 && chown -R "${OPENCAST_USER}":"${OPENCAST_GROUP}" "${OPENCAST_CONFIG}"

USER "${OPENCAST_USER}"
WORKDIR "${OPENCAST_HOME}"

EXPOSE 8080
VOLUME [ "${OPENCAST_DATA}" ]

COPY assets/docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["app:start"]
