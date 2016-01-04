FROM maven:3-jdk-8
MAINTAINER WWU eLectures team <learnweb@uni-muenster.de>

ENV OPENCAST_VERSION="2.1.0" \
    OPENCAST_DISTRIBUTION="allinone" \
    OPENCAST_SRC="/usr/src/opencast" \
    OPENCAST_HOME="/opencast" \
    OPENCAST_STORAGE="/data/opencast" \
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
RUN mkdir -p "${OPENCAST_SRC}" "${OPENCAST_HOME}" "${OPENCAST_STORAGE}" "${OPENCAST_SCRIPTS}" \
 && groupadd -r "${OPENCAST_GROUP}" -g "${OPENCAST_GID}" \
 && useradd -r -g "${OPENCAST_GROUP}" -d "${OPENCAST_HOME}" -u "${OPENCAST_UID}" "${OPENCAST_USER}" \
 && chown "${OPENCAST_USER}":"${OPENCAST_GROUP}" "${OPENCAST_SRC}" "${OPENCAST_HOME}" "${OPENCAST_STORAGE}"

RUN cd "${OPENCAST_SRC}" \
 && curl -sSL "${OPENCAST_URL}" | tar -xvj --strip 1 -C . \
 && mvn --batch-mode clean install -Dmaven.test.skip=true \
 && tar -xvzf "build/opencast-dist-${OPENCAST_DISTRIBUTION}-${OPENCAST_VERSION}.tar.gz" --strip 1 -C "${OPENCAST_HOME}" \
 && rm -rf "${OPENCAST_SRC}" /tmp/*

COPY assets/scripts/* "${OPENCAST_SCRIPTS}/"
COPY assets/etc/* "${OPENCAST_CONFIG}/"
RUN chown -R "${OPENCAST_USER}":"${OPENCAST_GROUP}" "${OPENCAST_HOME}" "${OPENCAST_STORAGE}"

USER "${OPENCAST_USER}"
WORKDIR "${OPENCAST_HOME}"

EXPOSE 8080
VOLUME [ "${OPENCAST_STORAGE}" ]
VOLUME [ "${OPENCAST_CONFIG}" ]

COPY assets/docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["app:start"]
