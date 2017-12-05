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

FROM alpine:3.6
LABEL maintainer="WWU eLectures team <electures.dev@uni-muenster.de>" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.version="3.4" \
      org.label-schema.name="opencast-ingest" \
      org.label-schema.description="Docker image for the Opencast ingest distribution" \
      org.label-schema.usage="https://github.com/opencast/opencast-docker/blob/3.4/README.md" \
      org.label-schema.url="http://www.opencast.org/" \
      org.label-schema.vcs-url="https://github.com/opencast/opencast-docker" \
      org.label-schema.vendor="University of Münster" \
      org.label-schema.docker.debug="docker exec -it $CONTAINER sh" \
      org.label-schema.docker.cmd.help="docker run --rm opencast/ingest:3.4 app:help"

ARG repo="https://bitbucket.org/opencast-community/opencast.git"
ARG branch="3.4"

ENV LANG="C.UTF-8" \
    JAVA_HOME="/usr/lib/jvm/java-1.8-openjdk" \
    PATH="$PATH:/usr/lib/jvm/java-1.8-openjdk/jre/bin:/usr/lib/jvm/java-1.8-openjdk/bin" \
    \
    OPENCAST_VERSION="3.4" \
    OPENCAST_DISTRIBUTION="ingest" \
    OPENCAST_SRC="/usr/src/opencast" \
    OPENCAST_HOME="/opencast" \
    OPENCAST_DATA="/data" \
    OPENCAST_CUSTOM_CONFIG="/etc/opencast" \
    OPENCAST_USER="opencast" \
    OPENCAST_GROUP="opencast" \
    OPENCAST_UID="800" \
    OPENCAST_GID="800" \
    \
    TESSERACT_BASE_URL="https://github.com/tesseract-ocr/tessdata/raw/3.04.00" \
    HUNSPELL_BASE_URL="http://download.services.openoffice.org/contrib/dictionaries"
ENV OPENCAST_SCRIPTS="${OPENCAST_HOME}/docker/scripts" \
    OPENCAST_SUPPORT="${OPENCAST_HOME}/docker/support" \
    OPENCAST_CONFIG="${OPENCAST_HOME}/etc" \
    OPENCAST_REPO="${repo}" \
    OPENCAST_BRANCH="${branch}"

RUN { \
     echo '#!/bin/sh'; \
     echo 'for i in $(seq 1 4); do'; \
     echo '  "$@" && exit 0'; \
     echo 'done'; \
     echo 'exit 1'; \
   } > /tmp/retry \
 && chmod +x /tmp/retry \
 && apk add --no-cache --virtual .build-deps \
      tar gzip \
      git \
      make gcc g++ binutils-gold \
      maven \
      python2 nodejs-current nodejs-current-npm \
  \
 && apk add --no-cache --virtual .run-deps \
      openjdk8 \
      bash su-exec openssl tzdata curl \
      fontconfig ttf-dejavu ttf-freefont ttf-liberation ttf-linux-libertine \
      ffmpeg \
      sox \
      hunspell \
      tesseract-ocr \
  \
 && mkdir -p /tmp/tesseract /tmp/hunspell /usr/share/tessdata /usr/share/hunspell \
 && { \
      echo "cb7eb42a7e972cec7ef904fe81825d7b547c46df684c814fdb11a930b13bca3a  deu.traineddata"; \
      echo "c0515c9f1e0c79e1069fcc05c2b2f6a6841fb5e1082d695db160333c1154f06d  eng.traineddata"; \
    } > /tmp/tesseract-sha256sum.txt \
 && cd /tmp/tesseract \
 && for file in $(awk '{print $2}' /tmp/tesseract-sha256sum.txt); do \
      curl -L -o "${file}" "${TESSERACT_BASE_URL}/${file}"; \
      grep "${file}" /tmp/tesseract-sha256sum.txt | sha256sum -c -; \
      cp "${file}" /usr/share/tessdata; \
    done \
 && { \
      echo "2478723ab67dd801ec6add11b1af9d32665e7859a1cb00c95bfc2b618584a802  de_AT.zip"; \
      echo "c30bb085ba0a3d22a23aef51f4dd94ae9ae0cc811c0590ebf3713a93b209d823  de_CH.zip"; \
      echo "220e01c3137000305247336d8d10cd550bda3990fb10e50b31633947969a34b8  de_DE_comb.zip"; \
      echo "22e217a631977d7b377f8dd22d2bbacd2d36b32765ce13f3474b03a4a97dd700  en_AU.zip"; \
      echo "31fac12a1b520cde686f328d3fa7560f6eba772cddc872197ff842c57a0dc1ea  en_CA.zip"; \
      echo "5869d8bd80eb2eb328ebe36b356348de4ae2acb1db6df39d1717d33f89f63728  en_GB.zip"; \
      echo "6cc717b4de43240595662a2deef5447b06062e82380f5647196f07c9089284fa  en_NZ.zip"; \
      echo "9227f658f182c9cece797352f041a888134765c11bffc91951c010a73187baea  en_US.zip"; \
      echo "090285b721dcaabff51b467123f82a181a6904d187c90bda812c6e5f365ff19a  en_ZA.zip"; \
    } > /tmp/hunspell-sha256sum.txt \
 && cd /tmp/hunspell \
 && for file in $(awk '{print $2}' /tmp/hunspell-sha256sum.txt); do \
      curl -L -o "${file}" "${HUNSPELL_BASE_URL}/${file}"; \
      grep "${file}" /tmp/hunspell-sha256sum.txt | sha256sum -c -; \
      unzip "/tmp/hunspell/${file}"; \
    done \
 && cp *.aff *.dic /usr/share/hunspell \
  \
 && mkdir -p "${OPENCAST_SRC}" "${OPENCAST_HOME}" "${OPENCAST_DATA}" "${OPENCAST_SCRIPTS}" \
 && git clone --recursive "${OPENCAST_REPO}" "${OPENCAST_SRC}" \
 && cd "${OPENCAST_SRC}" \
 && git checkout "${OPENCAST_BRANCH}" \
  \
 && cd "${OPENCAST_SRC}/modules/matterhorn-admin-ui-ng" \
 && /tmp/retry npm install -g npm \
 && /tmp/retry npm install -g grunt-cli \
 && /tmp/retry npm install --save-dev 'node-sass@~4.6.0' \
 && /tmp/retry npm install \
 && /tmp/retry grunt build --no-color --skipTests=true \
  \
 && cd "${OPENCAST_SRC}" \
 && mvn --quiet --batch-mode install -P '!frontend' -DskipTests=true -Dcheckstyle.skip=true -DskipJasmineTests=true \
 && tar -xzf build/opencast-dist-${OPENCAST_DISTRIBUTION}-*.tar.gz --strip 1 -C "${OPENCAST_HOME}" \
 && addgroup -S -g "${OPENCAST_GID}" "${OPENCAST_GROUP}" \
 && adduser -S -D -H -G "${OPENCAST_GROUP}" -h "${OPENCAST_HOME}" -u "${OPENCAST_UID}" "${OPENCAST_USER}" \
 && chown -R "${OPENCAST_USER}:${OPENCAST_GROUP}" "${OPENCAST_HOME}" "${OPENCAST_DATA}" \
  \
 && apk del --no-cache .build-deps \
 && rm -rf "${OPENCAST_SRC}" /tmp/* ~/.m2 ~/.npm ~/.node-gyp /usr/lib/node_modules

COPY assets/docker-entrypoint.sh assets/docker-healthcheck.sh /
COPY assets/scripts/* "${OPENCAST_SCRIPTS}/"
COPY assets/support "${OPENCAST_SUPPORT}"
COPY assets/etc/* "${OPENCAST_CONFIG}/"
COPY assets/etc/index/adminui/settings.yml "${OPENCAST_CONFIG}/index/adminui/"
COPY assets/etc/index/externalapi/settings.yml "${OPENCAST_CONFIG}/index/externalapi/"
RUN javac "${OPENCAST_SCRIPTS}/TryToConnectToDb.java" \
 && chown -R "${OPENCAST_USER}:${OPENCAST_GROUP}" "${OPENCAST_CONFIG}"

WORKDIR "${OPENCAST_HOME}"

EXPOSE 8080
VOLUME [ "${OPENCAST_DATA}" ]

HEALTHCHECK --timeout=10s CMD /docker-healthcheck.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["app:start"]
