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

ENV OPENCAST_VERSION="2.2.0" \
    OPENCAST_DISTRIBUTION="allinone" \
    OPENCAST_SRC="/usr/src/opencast" \
    OPENCAST_HOME="/opencast" \
    OPENCAST_DATA="/data" \
    OPENCAST_CUSTOM_CONFIG="/etc/opencast" \
    OPENCAST_USER="opencast" \
    OPENCAST_GROUP="opencast" \
    OPENCAST_UID="800" \
    OPENCAST_GID="800" \
    \
    TESSERACT_BASE_URL="https://github.com/tesseract-ocr/tessdata/raw/3cf1e2df1fe1d1da29295c9ef0983796c7958b7d" \
    HUNSPELL_BASE_URL="http://download.services.openoffice.org/contrib/dictionaries"
ENV OPENCAST_SCRIPTS="${OPENCAST_HOME}/docker/scripts" \
    OPENCAST_CONFIG="${OPENCAST_HOME}/etc" \
    OPENCAST_URL="https://bitbucket.org/opencast-community/matterhorn/get/${OPENCAST_VERSION}.tar.gz"

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
 && echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
 && apk add --no-cache --virtual .build-deps \
      tar gzip \
      git \
      make gcc g++ binutils-gold \
      maven \
      python \
  \
  # Install dependencies
  #   - FFmpeg
  #   - Sound eXchange (SoX)
  #   - Tesseract Open Source OCR Engine
  #   - Hunspell
 && apk add --no-cache --virtual .run-deps \
      su-exec openssl tzdata \
      fontconfig ttf-dejavu ttf-freefont ttf-liberation ttf-linux-libertine \
      ffmpeg \
      sox \
      hunspell \
      tesseract-ocr \
  \
  # TODO: Remove @old repo when http://stackoverflow.com/questions/37450473/cssmin-is-giving-me-path-must-be-a-string-received-undefined is fixed
  && apk add --no-cache --repository "@old http://dl-cdn.alpinelinux.org/alpine/v3.3/main" \
      nodejs@old \
  \
  # Install languag files for tesseract and hunspell
 && mkdir -p /tmp/tesseract /tmp/hunspell /usr/share/tessdata /usr/share/hunspell \
 && { \
      echo "cb7eb42a7e972cec7ef904fe81825d7b547c46df684c814fdb11a930b13bca3a  deu.traineddata"; \
      echo "64adf2cc0b2a6705368aa357224d1a6739035d5fe892cd0cc457016df5b4280f  eng.cube.bigrams"; \
      echo "2b229895623934b493fe69c51fcc387295d91af8b4e43cc51748b3d269a95eed  eng.cube.fold"; \
      echo "a6f769245b0a55f42a3ce157cd19d96828483c3384c6483433ed83579ea16e36  eng.cube.lm"; \
      echo "8f345f1c19772dd71a5214bc94175ccf647c003ab77e4143fde48f11bf3cb0ef  eng.cube.nn"; \
      echo "c2aa2854951bd823d89cc86d53a6d9712a6a885de6fbaf650ff3df48bfed85d7  eng.cube.params"; \
      echo "e5f95de7e2754eb2df03451885277ca4573b3770816043ae2e2f09d1f7232604  eng.cube.size"; \
      echo "8d612bef20ae3052fce0b8650575a80d87c94d772ec6d1f0c6a1ad591586ea44  eng.cube.word-freq"; \
      echo "196bedc8a5bc8c30361c2c9518f648b45b498759cb6041827ff6fbfb8da2a8d1  eng.tesseract_cube.nn"; \
      echo "c0515c9f1e0c79e1069fcc05c2b2f6a6841fb5e1082d695db160333c1154f06d  eng.traineddata"; \
    } > /tmp/tesseract-sha256sum.txt \
 && cd /tmp/tesseract \
 && for file in $(awk '{print $2}' /tmp/tesseract-sha256sum.txt); do \
      wget -O "${file}" "${TESSERACT_BASE_URL}/${file}"; \
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
      wget -O "${file}" "${HUNSPELL_BASE_URL}/${file}"; \
      grep "${file}" /tmp/hunspell-sha256sum.txt | sha256sum -c -; \
      unzip "/tmp/hunspell/${file}"; \
    done \
 && cp *.aff *.dic /usr/share/hunspell \
  \
  # Compile front-end assets manually as the bundeled node does not run on Alpine
 && mkdir -p "${OPENCAST_SRC}" "${OPENCAST_HOME}" "${OPENCAST_DATA}" "${OPENCAST_SCRIPTS}" \
 && wget -O - "${OPENCAST_URL}" | tar -xz --strip 1 -C "${OPENCAST_SRC}" \
 && cd "${OPENCAST_SRC}/modules/matterhorn-admin-ui-ng" \
 && sed -i 's/"grunt-sass":.*/"grunt-sass": "^1.2.0",/g' package.json \
 && npm install -g npm \
 && npm install -g grunt-cli \
 && npm install \
 && grunt build --no-color --skipTests=true \
  \
  # Compile and install Opencast
 && cd "${OPENCAST_SRC}" \
 && mvn --quiet --batch-mode install -P '!frontend' -DskipTests=true -Dcheckstyle.skip=true -DskipJasmineTests=true \
 && tar -xzf build/opencast-dist-${OPENCAST_DISTRIBUTION}-*.tar.gz --strip 1 -C "${OPENCAST_HOME}" \
 && addgroup -S -g "${OPENCAST_GID}" "${OPENCAST_GROUP}" \
 && adduser -S -D -H -G "${OPENCAST_GROUP}" -h "${OPENCAST_HOME}" -u "${OPENCAST_UID}" "${OPENCAST_USER}" \
 && chown -R "${OPENCAST_USER}:${OPENCAST_GROUP}" "${OPENCAST_HOME}" "${OPENCAST_DATA}" \
  \
  # Cleanup
 && apk del --no-cache nodejs \
 && apk del --no-cache .build-deps \
 && rm -rf "${OPENCAST_SRC}" /tmp/* ~/.m2 ~/.npm ~/.node-gyp /usr/lib/node_modules

COPY assets/scripts/* "${OPENCAST_SCRIPTS}/"
COPY assets/etc/* "${OPENCAST_CONFIG}/"
COPY assets/etc/index/adminui/settings.yml "${OPENCAST_CONFIG}/index/adminui/"
RUN javac "${OPENCAST_SCRIPTS}/TryToConnectToDb.java" \
 && chown -R "${OPENCAST_USER}:${OPENCAST_GROUP}" "${OPENCAST_CONFIG}"

WORKDIR "${OPENCAST_HOME}"

EXPOSE 8080
VOLUME [ "${OPENCAST_DATA}" ]

COPY assets/docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["app:start"]
