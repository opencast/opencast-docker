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

DOCKER_REPO=learnweb/opencast
DOCKER_TAG=$(shell cat VERSION)

REPO=https://bitbucket.org/opencast-community/matterhorn.git
BRANCH=$(DOCKER_TAG)

all: lint build test

build: build-allinone build-admin build-adminworker build-ingest build-presentation build-worker build-build
build-allinone:
	docker build \
		--build-arg repo=$(REPO) \
		--build-arg branch=$(BRANCH) \
		-t $(DOCKER_REPO):allinone \
		-t $(DOCKER_REPO):allinone-$(DOCKER_TAG) \
		Dockerfiles/allinone
build-admin:
	docker build \
		--build-arg repo=$(REPO) \
		--build-arg branch=$(BRANCH) \
		-t $(DOCKER_REPO):admin \
		-t $(DOCKER_REPO):admin-$(DOCKER_TAG) \
		Dockerfiles/admin
build-adminworker:
	docker build \
		--build-arg repo=$(REPO) \
		--build-arg branch=$(BRANCH) \
		-t $(DOCKER_REPO):adminworker \
		-t $(DOCKER_REPO):adminworker-$(DOCKER_TAG) \
		Dockerfiles/adminworker
build-ingest:
	docker build \
		--build-arg repo=$(REPO) \
		--build-arg branch=$(BRANCH) \
		-t $(DOCKER_REPO):ingest \
		-t $(DOCKER_REPO):ingest-$(DOCKER_TAG) \
		Dockerfiles/ingest
build-presentation:
	docker build \
		--build-arg repo=$(REPO) \
		--build-arg branch=$(BRANCH) \
		-t $(DOCKER_REPO):presentation \
		-t $(DOCKER_REPO):presentation-$(DOCKER_TAG) \
		Dockerfiles/presentation
build-worker:
	docker build \
		--build-arg repo=$(REPO) \
		--build-arg branch=$(BRANCH) \
		-t $(DOCKER_REPO):worker \
		-t $(DOCKER_REPO):worker-$(DOCKER_TAG) \
		Dockerfiles/worker
build-build:
	docker build \
		--build-arg repo=$(REPO) \
		--build-arg branch=$(BRANCH) \
		-t $(DOCKER_REPO):build \
		-t $(DOCKER_REPO):build-$(DOCKER_TAG) \
		Dockerfiles/build
.PHONY: build build-allinone build-admin build-adminworker build-ingest build-presentation build-worker build-build

test: test-common test-allinone test-admin test-adminworker test-ingest test-presentation test-worker test-build
test-common:
	bats test
test-allinone: build-allinone
test-admin: build-admin
test-adminworker: build-admin
test-ingest: build-allinone
test-presentation: build-presentation
test-worker: build-worker
test-build: build-build
.PHONY: test test-common test-allinone test-admin test-adminworker test-ingest test-presentation test-worker test-build

clean:
	-docker rmi $(DOCKER_REPO):allinone
	-docker rmi $(DOCKER_REPO):admin
	-docker rmi $(DOCKER_REPO):adminworker
	-docker rmi $(DOCKER_REPO):ingest
	-docker rmi $(DOCKER_REPO):presentation
	-docker rmi $(DOCKER_REPO):worker
	-docker rmi $(DOCKER_REPO):build
	-docker rmi $(DOCKER_REPO):allinone-$(DOCKER_TAG)
	-docker rmi $(DOCKER_REPO):admin-$(DOCKER_TAG)
	-docker rmi $(DOCKER_REPO):adminworker-$(DOCKER_TAG)
	-docker rmi $(DOCKER_REPO):ingest-$(DOCKER_TAG)
	-docker rmi $(DOCKER_REPO):presentation-$(DOCKER_TAG)
	-docker rmi $(DOCKER_REPO):worker-$(DOCKER_TAG)
	-docker rmi $(DOCKER_REPO):build-$(DOCKER_TAG)
.PHONY: clean

lint:
	cd Dockerfiles/admin/assets && shellcheck --shell=sh --external-sources *.sh ./**/*.sh
.PHONY: lint
