all: build test

build: build-allinone build-admin build-presentation build-worker
.PHONY: build

build-allinone:
	docker build -t learnweb/opencast:allinone Dockerfiles/allinone
.PHONY: build-allinone

build-admin:
	docker build -t learnweb/opencast:admin Dockerfiles/admin
.PHONY: build-admin

build-presentation:
	docker build -t learnweb/opencast:presentation Dockerfiles/presentation
.PHONY: build-presentation

build-worker:
	docker build -t learnweb/opencast:worker Dockerfiles/worker
.PHONY: build-worker

test check: build
	bats test
.PHONY: test check

clean:
	-docker rmi learnweb/opencast:allinone
	-docker rmi learnweb/opencast:admin
	-docker rmi learnweb/opencast:presentation
	-docker rmi learnweb/opencast:worker
.PHONY: clean
