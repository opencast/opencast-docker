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

all: lint build test

build: build-allinone build-admin build-adminworker build-ingest build-presentation build-worker
build-allinone:
	docker build \
		-t learnweb/opencast:allinone \
		-t learnweb/opencast:allinone-${VERSION} \
		Dockerfiles/allinone
build-admin:
	docker build \
		-t learnweb/opencast:admin \
		-t learnweb/opencast:admin-${VERSION} \
		Dockerfiles/admin
build-adminworker:
	docker build \
		-t learnweb/opencast:adminworker \
		-t learnweb/opencast:adminworker-${VERSION} \
		Dockerfiles/adminworker
build-ingest:
	docker build \
		-t learnweb/opencast:ingest \
		-t learnweb/opencast:ingest-${VERSION} \
		Dockerfiles/ingest
build-presentation:
	docker build \
		-t learnweb/opencast:presentation \
		-t learnweb/opencast:presentation-${VERSION} \
		Dockerfiles/presentation
build-worker:
	docker build \
		-t learnweb/opencast:worker \
		-t learnweb/opencast:worker-${VERSION} \
		Dockerfiles/worker
.PHONY: build build-allinone build-admin build-adminworker build-ingest build-presentation build-worker

test: test-common test-allinone test-admin test-adminworker test-ingest test-presentation test-worker
test-common:
	bats test
test-allinone: build-allinone
test-admin: build-admin
test-adminworker: build-admin
test-ingest: build-allinone
test-presentation: build-presentation
test-worker: build-worker
.PHONY: test test-common test-allinone test-admin test-adminworker test-ingest test-presentation test-worker

clean:
	-docker rmi learnweb/opencast:allinone
	-docker rmi learnweb/opencast:admin
	-docker rmi learnweb/opencast:adminworker
	-docker rmi learnweb/opencast:ingest
	-docker rmi learnweb/opencast:presentation
	-docker rmi learnweb/opencast:worker
	-docker rmi learnweb/opencast:allinone-${VERSION}
	-docker rmi learnweb/opencast:admin-${VERSION}
	-docker rmi learnweb/opencast:adminworker-${VERSION}
	-docker rmi learnweb/opencast:ingest-${VERSION}
	-docker rmi learnweb/opencast:presentation-${VERSION}
	-docker rmi learnweb/opencast:worker-${VERSION}
.PHONY: clean

lint:
	cd Dockerfiles/admin/assets && shellcheck --shell=sh --external-sources *.sh ./**/*.sh
.PHONY: lint
