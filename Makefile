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

all: build test

build: build-allinone build-admin build-presentation build-worker
build-allinone:
	docker build -t learnweb/opencast:allinone Dockerfiles/allinone
build-admin:
	docker build -t learnweb/opencast:admin Dockerfiles/admin
build-presentation:
	docker build -t learnweb/opencast:presentation Dockerfiles/presentation
build-worker:
	docker build -t learnweb/opencast:worker Dockerfiles/worker
.PHONY: build build-allinone build-admin build-presentation build-worker

test: test-common test-allinone test-admin test-presentation test-worker
test-common:
	bats test
test-allinone: build-allinone
test-admin: build-admin
test-presentation: build-presentation
test-worker: build-worker
.PHONY: test test-common test-allinone test-admin test-presentation test-worker

clean:
	-docker rmi learnweb/opencast:allinone
	-docker rmi learnweb/opencast:admin
	-docker rmi learnweb/opencast:presentation
	-docker rmi learnweb/opencast:worker
.PHONY: clean
