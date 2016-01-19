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
