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

FROM java:8-jdk-alpine
MAINTAINER WWU eLectures team <electures.dev@uni-muenster.de>

ENV OPENCAST_VERSION="2.1.2" \
    OPENCAST_DISTRIBUTION="presentation" \
    OPENCAST_SRC="/usr/src/opencast" \
    OPENCAST_HOME="/opencast" \
    OPENCAST_DATA="/data" \
    OPENCAST_CUSTOM_CONFIG="/etc/opencast" \
    OPENCAST_USER="opencast" \
    OPENCAST_GROUP="opencast" \
    OPENCAST_UID="800" \
    OPENCAST_GID="800" \
    \
    TESSERACT_URL="https://github.com/tesseract-ocr/tessdata/archive/master.tar.gz" \
    TESSERACT_LANG="-name 'eng*' -o -name 'deu*'" \
    \
    HUNSPELL_BASE_URL="http://download.services.openoffice.org/contrib/dictionaries" \
    HUNSPELL_LANG="\
59141b649996af61271b7e832d8772d02c1fa9d074be1308ad444a8ccb42c987 de_DE_comb.zip\n\
01f0ff4200b475248fa62540c374eb3854725cebfeb416e137f2352f80e15fdb en_GB.zip\
    "
ENV OPENCAST_SCRIPTS="${OPENCAST_HOME}/docker/scripts" \
    OPENCAST_CONFIG="${OPENCAST_HOME}/etc" \
    OPENCAST_URL="https://bitbucket.org/opencast-community/matterhorn/get/${OPENCAST_VERSION}.tar.gz"

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
 && apk add --no-cache --virtual .build-deps \
      tar gzip \
      git \
      make gcc g++ binutils-gold \
      maven \
      python \
      nodejs \
  \
  # Install dependencies
  #   - FFmpeg
  #   - Sound eXchange (SoX)
  #   - Tesseract Open Source OCR Engine
  #   - Hunspell
 && apk add --no-cache --virtual .run-deps \
      ffmpeg \
      sox \
      tesseract-ocr \
      hunspell \
 && mkdir -p /tmp/tessdata /tmp/hunspell \
 && wget -q -O - "${TESSERACT_URL}" | tar -xz --strip 1 -C /tmp/tessdata \
 && find /tmp/tessdata -type f $TESSERACT_LANG -exec cp {} /usr/share/tessdata + \
 && echo -e ${HUNSPELL_LANG} > /tmp/hunspell/SHASUMS256.txt \
  \
  # TODO: download hunspell dictionaries
  \
  # Compile frontend assets manually as the bundeled node does not run on Alpine
 && mkdir -p "${OPENCAST_SRC}" "${OPENCAST_HOME}" "${OPENCAST_DATA}" "${OPENCAST_SCRIPTS}" \
 && wget -q -O - "${OPENCAST_URL}" | tar -xz --strip 1 -C "${OPENCAST_SRC}" \
 && cd "${OPENCAST_SRC}/modules/matterhorn-admin-ui-ng" \
 && sed -i 's/"grunt-sass":.*/"grunt-sass": "^1.2.0",/g' package.json \
 && npm install -g npm@2 \
 && npm install -g grunt \
 && npm install \
 && grunt build --no-color --skipTests=true \
  \
  # Compile and install Opencast
 && cd "${OPENCAST_SRC}" \
 && mvn --quiet --batch-mode install -P '!frontend' -DskipTests=true -Dcheckstyle.skip=true \
 && tar -xzf build/opencast-dist-${OPENCAST_DISTRIBUTION}-*.tar.gz --strip 1 -C "${OPENCAST_HOME}" \
 && addgroup -S -g "${OPENCAST_GID}" "${OPENCAST_GROUP}" \
 && adduser -S -D -H -G "${OPENCAST_GROUP}" -h "${OPENCAST_HOME}" -u "${OPENCAST_UID}" "${OPENCAST_USER}" \
 && chown -R "${OPENCAST_USER}":"${OPENCAST_GROUP}" "${OPENCAST_HOME}" "${OPENCAST_DATA}" \
  \
  # Cleanup
 && apk del .build-deps \
 && rm -rf "${OPENCAST_SRC}" /tmp/* ~/.m2 ~/.npm ~/.node-gyp /usr/lib/node_modules

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
