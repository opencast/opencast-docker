all: build

build:
	docker build -t mtneug/opencast:allinone allinone
	docker build -t mtneug/opencast:admin admin
	docker build -t mtneug/opencast:engage engage
	docker build -t mtneug/opencast:worker worker
.PHONY: build

test check: build
	docker run -it --rm mtneug/opencast:allinone mvn --batch-mode test -Dall -Dsurefire.rerunFailingTestsCount=2
.PHONY: test check

clean:
	-docker rmi mtneug/opencast:allinone
	-docker rmi mtneug/opencast:admin
	-docker rmi mtneug/opencast:engage
	-docker rmi mtneug/opencast:worker
.PHONY: clean
