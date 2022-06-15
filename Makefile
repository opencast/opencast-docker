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

# user configurable variables

OPENCAST_REPO     ?= https://github.com/opencast/opencast.git
OPENCAST_VERSION  ?= $(shell cat VERSION_OPENCAST)

FFMPEG_VERSION    ?= $(shell cat VERSION_FFMPEG)

IMAGE_REGISTRY    ?= quay.io/opencast
IMAGE_TAG         ?= $(shell cat VERSION)
DOCKER_BUILD_ARGS ?=

GIT_COMMIT        ?= $(shell git rev-parse --short HEAD || echo "unknown")
BUILD_DATE        ?= $(shell date -u +"%Y-%m-%dT%TZ")

# build variables (do not change)

export DOCKER_BUILDKIT = 1
OPENCAST_DISTRIBUTIONS = \
	admin \
	adminpresentation \
	allinone \
	ingest \
	presentation \
	worker

# targets

all: lint build

.PHONY: build
build: $(addprefix build-, $(OPENCAST_DISTRIBUTIONS)) build-build
build-%:
	docker build \
		--pull \
		--build-arg OPENCAST_REPO="$(OPENCAST_REPO)" \
		--build-arg OPENCAST_VERSION="$(OPENCAST_VERSION)" \
		--build-arg OPENCAST_DISTRIBUTION="$*" \
		--build-arg BUILD_DATE="$(BUILD_DATE)" \
		--build-arg GIT_COMMIT="$(GIT_COMMIT)" \
		--build-arg VERSION="$(IMAGE_TAG)" \
		-t "$(IMAGE_REGISTRY)/$*:latest" \
		-t "$(IMAGE_REGISTRY)/$*:$(IMAGE_TAG)" \
		$(DOCKER_BUILD_ARGS) \
		-f Dockerfile \
		.

build-build:
	docker build \
		--pull \
		--build-arg OPENCAST_REPO="$(OPENCAST_REPO)" \
		--build-arg OPENCAST_VERSION="$(OPENCAST_VERSION)" \
		--build-arg BUILD_DATE="$(BUILD_DATE)" \
		--build-arg GIT_COMMIT="$(GIT_COMMIT)" \
		--build-arg VERSION="$(IMAGE_TAG)" \
		-t "$(IMAGE_REGISTRY)/build:latest" \
		-t "$(IMAGE_REGISTRY)/build:$(IMAGE_TAG)" \
		$(DOCKER_BUILD_ARGS) \
		-f Dockerfile-build \
		.

.PHONY: clean
clean: $(addprefix clean-, $(OPENCAST_DISTRIBUTIONS)) clean-build
clean-%:
	-docker rmi $(IMAGE_REGISTRY)/$*
	-docker rmi $(IMAGE_REGISTRY)/$*:$(IMAGE_TAG)

lint:
	cd rootfs                     && shellcheck --external-sources *.sh ./opencast/docker/scripts/*.sh
	cd rootfs-build/usr/local/bin && shellcheck --external-sources *
.PHONY: lint
