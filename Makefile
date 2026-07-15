# Default registry and namespace
REGISTRY ?= ghcr.io
NAMESPACE ?= rhadp-examples

# Build tool
CONTAINER_TOOL ?= podman

# Image name and tag
CONTAINER_IMAGE := ghcr.io/rhadp-examples/codespaces
TAG ?= latest

# Build arguments
BUILD_ARGS ?= --build-arg TARGETARCH=$(shell uname -m | sed 's/x86_64/amd64/')
PROJECT_DIR      := /projects

.PHONY: build build-rpm clean
	
build: clean
	$(CONTAINER_TOOL) run --rm \
		-v "$(CURDIR):$(PROJECT_DIR):ro" \
		-v "$(CURDIR)/bin:/output" \
		--tmpfs $(PROJECT_DIR)/src/build \
		-w $(PROJECT_DIR)/src \
		$(CONTAINER_IMAGE) \
		bash -c "cmake -B build . && cmake --build build && \
		  cp build/auto-hello /output/"

build-rpm:
	$(CONTAINER_TOOL) run --rm \
		-v "$(CURDIR):$(PROJECT_DIR):ro" \
		-v "$(CURDIR)/bin:/output" \
		-w /tmp \
		$(CONTAINER_IMAGE) \
		bash -c "\
		  NAME=auto-apps && \
		  VERSION=0.1 && \
		  cp -r $(PROJECT_DIR)/src \$${NAME}-\$${VERSION} && \
		  tar czf \$${NAME}-\$${VERSION}.tar.gz \$${NAME}-\$${VERSION} && \
		  mkdir -p ~/rpmbuild/{SOURCES,SPECS} && \
		  cp \$${NAME}-\$${VERSION}.tar.gz ~/rpmbuild/SOURCES/ && \
		  cp \$${NAME}-\$${VERSION}/auto-apps.spec ~/rpmbuild/SPECS/ && \
		  rpmbuild -ba ~/rpmbuild/SPECS/auto-apps.spec && \
		  cp ~/rpmbuild/SOURCES/*.tar.gz /output/ && \
		  cp ~/rpmbuild/RPMS/*/*.rpm /output/"

build-container: 
	$(CONTAINER_TOOL) build $(BUILD_ARGS) \
		-f containers/codespaces/Containerfile \
		-t $(CONTAINER_IMAGE):$(TAG) \
		containers/codespaces/

clean:
	rm -rf src/build src/CMakeCache.txt src/cmake_install.cmake src/CMakeFiles src/auto-hello
	rm -f bin/*.rpm bin/*.tar.gz bin/auto-hello src/Makefile src/*.tar.gz src/*.rpm
