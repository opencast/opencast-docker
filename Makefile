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

DOCKER_IMAGE_BASE=quay.io/opencast
DOCKER_TAG=$(shell cat VERSION)

REPO=$(shell sed -n -e 's/^ARG repo="\(.*\)"/\1/p' Dockerfiles/allinone/Dockerfile)
BRANCH=$(shell sed -n -e 's/^ARG branch="\(.*\)"/\1/p' Dockerfiles/allinone/Dockerfile)

CUSTOM_DOCKER_BUILD_ARGS=

all: lint build test

build: build-allinone build-admin build-adminpresentation build-ingest build-presentation build-worker build-build
build-allinone:
	docker build \
		--pull \
		--build-arg repo=$(REPO) \
		--build-arg branch=$(BRANCH) \
		-t $(DOCKER_IMAGE_BASE)/allinone \
		-t $(DOCKER_IMAGE_BASE)/allinone:$(DOCKER_TAG) \
		$(CUSTOM_DOCKER_BUILD_ARGS) \
		Dockerfiles/allinone
build-admin:
	docker build \
		--pull \
		--build-arg repo=$(REPO) \
		--build-arg branch=$(BRANCH) \
		-t $(DOCKER_IMAGE_BASE)/admin \
		-t $(DOCKER_IMAGE_BASE)/admin:$(DOCKER_TAG) \
		$(CUSTOM_DOCKER_BUILD_ARGS) \
		Dockerfiles/admin
build-adminpresentation:
	docker build \
		--pull \
		--build-arg repo=$(REPO) \
		--build-arg branch=$(BRANCH) \
		-t $(DOCKER_IMAGE_BASE)/adminpresentation \
		-t $(DOCKER_IMAGE_BASE)/adminpresentation:$(DOCKER_TAG) \
		$(CUSTOM_DOCKER_BUILD_ARGS) \
		Dockerfiles/adminpresentation
build-ingest:
	docker build \
		--pull \
		--build-arg repo=$(REPO) \
		--build-arg branch=$(BRANCH) \
		-t $(DOCKER_IMAGE_BASE)/ingest \
		-t $(DOCKER_IMAGE_BASE)/ingest:$(DOCKER_TAG) \
		$(CUSTOM_DOCKER_BUILD_ARGS) \
		Dockerfiles/ingest
build-presentation:
	docker build \
		--pull \
		--build-arg repo=$(REPO) \
		--build-arg branch=$(BRANCH) \
		-t $(DOCKER_IMAGE_BASE)/presentation \
		-t $(DOCKER_IMAGE_BASE)/presentation:$(DOCKER_TAG) \
		$(CUSTOM_DOCKER_BUILD_ARGS) \
		Dockerfiles/presentation
build-worker:
	docker build \
		--pull \
		--build-arg repo=$(REPO) \
		--build-arg branch=$(BRANCH) \
		-t $(DOCKER_IMAGE_BASE)/worker \
		-t $(DOCKER_IMAGE_BASE)/worker:$(DOCKER_TAG) \
		$(CUSTOM_DOCKER_BUILD_ARGS) \
		Dockerfiles/worker
build-build:
	docker build \
		--pull \
		--build-arg repo=$(REPO) \
		--build-arg branch=$(BRANCH) \
		-t $(DOCKER_IMAGE_BASE)/build \
		-t $(DOCKER_IMAGE_BASE)/build:$(DOCKER_TAG) \
		$(CUSTOM_DOCKER_BUILD_ARGS) \
		Dockerfiles/build
.PHONY: build build-allinone build-admin build-adminpresentation build-ingest build-presentation build-worker build-build

test: test-common test-allinone test-admin test-adminpresentation test-ingest test-presentation test-worker test-build
test-common:
	bats test
test-allinone: build-allinone
test-admin: build-admin
test-adminpresentation: build-adminpresentation
test-ingest: build-ingest
test-presentation: build-presentation
test-worker: build-worker
test-build: build-build
.PHONY: test test-common test-allinone test-admin test-adminpresentation test-ingest test-presentation test-worker test-build

clean:
	-docker rmi $(DOCKER_IMAGE_BASE)/allinone
	-docker rmi $(DOCKER_IMAGE_BASE)/admin
	-docker rmi $(DOCKER_IMAGE_BASE)/ingest
	-docker rmi $(DOCKER_IMAGE_BASE)/presentation
	-docker rmi $(DOCKER_IMAGE_BASE)/worker
	-docker rmi $(DOCKER_IMAGE_BASE)/build
	-docker rmi $(DOCKER_IMAGE_BASE)/allinone:$(DOCKER_TAG)
	-docker rmi $(DOCKER_IMAGE_BASE)/admin:$(DOCKER_TAG)
	-docker rmi $(DOCKER_IMAGE_BASE)/adminpresentation:$(DOCKER_TAG)
	-docker rmi $(DOCKER_IMAGE_BASE)/ingest:$(DOCKER_TAG)
	-docker rmi $(DOCKER_IMAGE_BASE)/presentation:$(DOCKER_TAG)
	-docker rmi $(DOCKER_IMAGE_BASE)/worker:$(DOCKER_TAG)
	-docker rmi $(DOCKER_IMAGE_BASE)/build:$(DOCKER_TAG)
.PHONY: clean

lint:
	cd Dockerfiles/admin/assets && shellcheck --shell=sh --external-sources *.sh ./**/*.sh
	cd Dockerfiles/build/assets/bin && shellcheck --shell=sh --external-sources *
.PHONY: lint
