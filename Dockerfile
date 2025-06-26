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

ARG IMAGE_BASE=default

FROM --platform=${BUILDPLATFORM}  docker.io/library/eclipse-temurin:21-jdk AS base-build
FROM --platform=${TARGETPLATFORM} docker.io/library/eclipse-temurin:21-jre AS base-target
LABEL org.opencontainers.image.base.name="docker.io/library/eclipse-temurin:21-jre"

FROM base-target AS base-default-runtime
FROM base-default-runtime AS base-default-dev

# Adapted from:
#   https://gitlab.com/nvidia/container-images/cuda/-/blob/master/dist/12.4.1/ubuntu2204/base/Dockerfile
#   https://gitlab.com/nvidia/container-images/cuda/-/blob/master/dist/12.4.1/ubuntu2204/runtime/Dockerfile
# BSD-3-Clause License: https://gitlab.com/nvidia/container-images/cuda/-/blob/master/LICENSE
FROM base-target AS base-nvidia-cuda-runtime-amd64
ENV NVARCH=x86_64
FROM base-target AS base-nvidia-cuda-runtime-arm64
ENV NVARCH=sbsa
FROM base-nvidia-cuda-runtime-${TARGETARCH} AS base-nvidia-cuda-runtime
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      gnupg2 \
 && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL "https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/${NVARCH}/3bf863cc.pub" | gpg --dearmor -o /etc/apt/keyrings/nvidia-cuda-keyring.gpg \
 && echo "deb [signed-by=/etc/apt/keyrings/nvidia-cuda-keyring.gpg] https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/${NVARCH} /" > /etc/apt/sources.list.d/nvidia-cuda.list

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      cuda-compat-12-4 \
      cuda-cudart-12-4 \
      cuda-libraries-12-4 \
      cuda-nvtx-12-4 \
      libcublas-12-4 \
      libcusparse-12-4 \
      libnccl2 \
      libnpp-12-4 \
 && rm -rf /var/lib/apt/lists/*

ENV NVIDIA_REQUIRE_CUDA="cuda>=12.4 brand=tesla,driver>=470,driver<471 brand=unknown,driver>=470,driver<471 brand=nvidia,driver>=470,driver<471 brand=nvidiartx,driver>=470,driver<471 brand=geforce,driver>=470,driver<471 brand=geforcertx,driver>=470,driver<471 brand=quadro,driver>=470,driver<471 brand=quadrortx,driver>=470,driver<471 brand=titan,driver>=470,driver<471 brand=titanrtx,driver>=470,driver<471 brand=tesla,driver>=525,driver<526 brand=unknown,driver>=525,driver<526 brand=nvidia,driver>=525,driver<526 brand=nvidiartx,driver>=525,driver<526 brand=geforce,driver>=525,driver<526 brand=geforcertx,driver>=525,driver<526 brand=quadro,driver>=525,driver<526 brand=quadrortx,driver>=525,driver<526 brand=titan,driver>=525,driver<526 brand=titanrtx,driver>=525,driver<526 brand=tesla,driver>=535,driver<536 brand=unknown,driver>=535,driver<536 brand=nvidia,driver>=535,driver<536 brand=nvidiartx,driver>=535,driver<536 brand=geforce,driver>=535,driver<536 brand=geforcertx,driver>=535,driver<536 brand=quadro,driver>=535,driver<536 brand=quadrortx,driver>=535,driver<536 brand=titan,driver>=535,driver<536 brand=titanrtx,driver>=535,driver<536"
ENV NVIDIA_VISIBLE_DEVICES="all"
ENV NVIDIA_DRIVER_CAPABILITIES="compute,utility"

ENV PATH="/usr/local/cuda/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/cuda/lib:/usr/local/cuda/lib64:/usr/local/cuda/compat:${LD_LIBRARY_PATH}"


# Adapted from: https://gitlab.com/nvidia/container-images/cuda/-/blob/master/dist/12.4.1/ubuntu2204/devel/Dockerfile
# BSD-3-Clause License: https://gitlab.com/nvidia/container-images/cuda/-/blob/master/LICENSE
FROM base-nvidia-cuda-runtime AS base-nvidia-cuda-dev
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      cuda-command-line-tools-12-4 \
      cuda-cudart-dev-12-4 \
      cuda-libraries-dev-12-4 \
      cuda-minimal-build-12-4 \
      cuda-nsight-compute-12-4 \
      cuda-nvml-dev-12-4 \
      libcublas-dev-12-4 \
      libcusparse-dev-12-4 \
      libnccl-dev \
      libnpp-dev-12-4 \
 && rm -rf /var/lib/apt/lists/*

ENV LIBRARY_PATH=/usr/local/cuda/lib64/stubs:/usr/local/cuda/compat


FROM base-${IMAGE_BASE}-runtime AS base-runtime
FROM base-${IMAGE_BASE}-dev AS base-dev


FROM --platform=${BUILDPLATFORM} docker.io/library/alpine:edge AS build-ffmpeg
ARG TARGETARCH
ARG FFMPEG_VERSION="release"
RUN apk add --no-cache \
      curl \
      tar \
      xz \
 && mkdir -p /rootfs/usr/local/bin /tmp/ffmpeg \
 && cd /tmp/ffmpeg \
 && curl -sSL "https://s3.opencast.org/opencast-ffmpeg-static/ffmpeg-${FFMPEG_VERSION}-${TARGETARCH}-static.tar.xz" \
     | tar xJf - --strip-components 1 --wildcards '*/ffmpeg' '*/ffprobe' \
 && chown root:root ff* \
 && mv ff* /rootfs/usr/local/bin


FROM base-dev AS build-whisper-cpp
ARG WHISPER_CPP_VERSION="master"
ENV WHISPER_CPP_MODELS="/usr/share/whisper.cpp/models"
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ccache \
      cmake \
      g++ \
      gcc \
      git \
      libc-dev \
      make
RUN mkdir -p /tmp/whisper.cpp
WORKDIR /tmp/whisper.cpp
RUN git clone https://github.com/ggerganov/whisper.cpp.git . \
 && git checkout "$WHISPER_CPP_VERSION"
ARG IMAGE_BASE=default
RUN cmake -B build \
      -DBUILD_SHARED_LIBS=OFF \
      -DGGML_CPU=ON \
      -DGGML_CPU_ARM_ARCH=native \
      -DGGML_CUDA=$(if [ "${IMAGE_BASE}" = "nvidia-cuda" ]; then echo ON; else echo OFF; fi) \
      -DGGML_NATIVE=OFF \
      -DWHISPER_BUILD_EXAMPLES=ON \
      -DWHISPER_BUILD_SERVER=OFF \
      -DWHISPER_BUILD_TESTS=OFF \
 && cmake --build build --config Release -j $(nproc) \
 && sed -i "s#models_path=.*\$#models_path=${WHISPER_CPP_MODELS}/#" models/download-ggml-model.sh \
 && sed -i "s#models_path=.*\$#models_path=${WHISPER_CPP_MODELS}/#" models/download-vad-model.sh
RUN mkdir -p /rootfs/usr/local/bin /rootfs/usr/local/sbin \
 && mv build/bin/whisper-*           /rootfs/usr/local/bin/ \
 && mv models/download-ggml-model.sh /rootfs/usr/local/sbin/whisper-ggml-model-download \
 && mv models/download-vad-model.sh  /rootfs/usr/local/sbin/whisper-download-vad-model


FROM --platform=${BUILDPLATFORM} base-build AS build-opencast

ARG OPENCAST_REPO="https://github.com/opencast/opencast.git"
ARG OPENCAST_VERSION="develop"

ENV OPENCAST_SRC="/usr/src/opencast"
ENV OPENCAST_HOME="/rootfs/opencast"
ENV OPENCAST_UHOME="/home/opencast"
ENV OPENCAST_UID="800"
ENV OPENCAST_GID="800"
ENV OPENCAST_USER="opencast"
ENV OPENCAST_GROUP="opencast"

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
 && git checkout "${OPENCAST_VERSION}"
RUN ./mvnw --batch-mode install \
      -Dmaven.wagon.httpconnectionManager.ttlSeconds=120 \
      -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=warn \
      -DskipTests=true \
      -Dcheckstyle.skip=true \
      -DskipJasmineTests=true
ARG OPENCAST_DISTRIBUTION
RUN tar -xzf build/opencast-dist-${OPENCAST_DISTRIBUTION}-*.tar.gz --strip 1 -C "${OPENCAST_HOME}"


FROM --platform=${BUILDPLATFORM} base-build AS build-rootfs
ENV OPENCAST_HOME="/rootfs/opencast"
ENV OPENCAST_SCRIPTS="${OPENCAST_HOME}/docker/scripts"
COPY rootfs /rootfs
RUN javac "${OPENCAST_SCRIPTS}/TryToConnectToDb.java" \
 && rm -rf "${OPENCAST_SCRIPTS}/TryToConnectToDb.java"


FROM base-runtime

ENV OPENCAST_HOME="/opencast"
ENV OPENCAST_DATA="/data"
ENV OPENCAST_CUSTOM_CONFIG="/etc/opencast"
ENV OPENCAST_USER="opencast"
ENV OPENCAST_GROUP="opencast"
ENV OPENCAST_UHOME="/home/opencast"
ENV OPENCAST_UID="800"
ENV OPENCAST_GID="800"
ENV WHISPER_CPP_MODELS="/usr/share/whisper.cpp/models"
ENV OPENCAST_CONFIG="${OPENCAST_HOME}/etc"
ENV OPENCAST_SCRIPTS="${OPENCAST_HOME}/docker/scripts"
ENV OPENCAST_STAGE_BASE_HOME="${OPENCAST_HOME}/docker/stage/base"
ENV OPENCAST_STAGE_OUT_HOME="${OPENCAST_HOME}/docker/stage/out"

RUN groupadd --system -g "${OPENCAST_GID}" "${OPENCAST_GROUP}" \
 && useradd --system -M -N -g "${OPENCAST_GROUP}" -d "${OPENCAST_UHOME}" -u "${OPENCAST_UID}" "${OPENCAST_USER}" \
 && mkdir -p "${OPENCAST_DATA}" "${OPENCAST_UHOME}" "${WHISPER_CPP_MODELS}" \
 && chown -R "${OPENCAST_USER}:${OPENCAST_GROUP}" "${OPENCAST_DATA}" "${OPENCAST_UHOME}" "${WHISPER_CPP_MODELS}"

# libgomp1 is a dependency of whisper.cpp. It is also installed as a dependency of Tesseract, but we want it to be an
# explicitly installed package.
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
      libgomp1 \
      netcat-openbsd \
      openssl \
      rsync \
      tesseract-ocr \
      tesseract-ocr-eng \
      tzdata \
 && rm -rf /var/lib/apt/lists/*

COPY --from=build-ffmpeg       /rootfs  /
COPY --from=build-whisper-cpp  /rootfs  /
COPY --from=build-opencast     /rootfs  /
COPY --from=build-rootfs       /rootfs  /

ARG OPENCAST_REPO="https://github.com/opencast/opencast.git"
ARG OPENCAST_VERSION="develop"
ARG OPENCAST_DISTRIBUTION
ARG VERSION=unkown
ARG BUILD_DATE=unkown
ARG GIT_COMMIT=unkown

ENV OPENCAST_REPO="${OPENCAST_REPO}"
ENV OPENCAST_VERSION="${OPENCAST_VERSION}"
ENV OPENCAST_DISTRIBUTION="${OPENCAST_DISTRIBUTION}"

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
 && rm -rf /tmp/*

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
