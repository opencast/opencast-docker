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

VERSION=$(shell cat VERSION)
IMAGE=learnweb/opencast

all: lint build test

build: build-allinone build-admin build-adminworker build-ingest build-presentation build-worker build-build
build-allinone:
	docker build \
		-t ${IMAGE}:allinone \
		-t ${IMAGE}:allinone-${VERSION} \
		Dockerfiles/allinone
build-admin:
	docker build \
		-t ${IMAGE}:admin \
		-t ${IMAGE}:admin-${VERSION} \
		Dockerfiles/admin
build-adminworker:
	docker build \
		-t ${IMAGE}:adminworker \
		-t ${IMAGE}:adminworker-${VERSION} \
		Dockerfiles/adminworker
build-ingest:
	docker build \
		-t ${IMAGE}:ingest \
		-t ${IMAGE}:ingest-${VERSION} \
		Dockerfiles/ingest
build-presentation:
	docker build \
		-t ${IMAGE}:presentation \
		-t ${IMAGE}:presentation-${VERSION} \
		Dockerfiles/presentation
build-worker:
	docker build \
		-t ${IMAGE}:worker \
		-t ${IMAGE}:worker-${VERSION} \
		Dockerfiles/worker
build-build:
	docker build \
		-t ${IMAGE}:build \
		-t ${IMAGE}:build-${VERSION} \
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
	-docker rmi ${IMAGE}:allinone
	-docker rmi ${IMAGE}:admin
	-docker rmi ${IMAGE}:adminworker
	-docker rmi ${IMAGE}:ingest
	-docker rmi ${IMAGE}:presentation
	-docker rmi ${IMAGE}:worker
	-docker rmi ${IMAGE}:build
	-docker rmi ${IMAGE}:allinone-${VERSION}
	-docker rmi ${IMAGE}:admin-${VERSION}
	-docker rmi ${IMAGE}:adminworker-${VERSION}
	-docker rmi ${IMAGE}:ingest-${VERSION}
	-docker rmi ${IMAGE}:presentation-${VERSION}
	-docker rmi ${IMAGE}:worker-${VERSION}
	-docker rmi ${IMAGE}:build-${VERSION}
.PHONY: clean

lint:
	cd Dockerfiles/admin/assets && shellcheck --shell=sh --external-sources *.sh ./**/*.sh
.PHONY: lint
