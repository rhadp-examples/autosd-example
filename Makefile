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
PROJECT_DIR := /projects

# AutoSD (RHIVOS) image build
AUTOSD_MANIFEST ?= manifests/auto-app.aib.yml
AUTOSD_IMAGE ?= images/auto-app-autosd.qcow2
AUTOSD_TARGET ?= qemu

.PHONY: build build-rpm build-local build-rpm-local update-repo build-autosd build-container clean

build-local: clean
	cmake -B src/build src
	cmake --build src/build
	cp src/build/auto-app bin/

build: clean
	$(CONTAINER_TOOL) run --rm \
		-v "$(CURDIR):$(PROJECT_DIR):ro" \
		-v "$(CURDIR)/bin:/output" \
		--tmpfs $(PROJECT_DIR)/src/build \
		-w $(PROJECT_DIR)/src \
		$(CONTAINER_IMAGE) \
		bash -c "cmake -B build . && cmake --build build && \
		  cp build/auto-app /output/"

build-rpm-local:
	cd /tmp && \
	  NAME=auto-app && \
	  VERSION=0.1 && \
	  RPMBUILD=/tmp/rpmbuild && \
	  cp -r $(CURDIR)/src $${NAME}-$${VERSION} && \
	  tar czf $${NAME}-$${VERSION}.tar.gz $${NAME}-$${VERSION} && \
	  mkdir -p $${RPMBUILD}/{SOURCES,SPECS} && \
	  cp $${NAME}-$${VERSION}.tar.gz $${RPMBUILD}/SOURCES/ && \
	  cp $${NAME}-$${VERSION}/auto-app.spec $${RPMBUILD}/SPECS/ && \
	  rpmbuild --define "_topdir $${RPMBUILD}" -ba $${RPMBUILD}/SPECS/auto-app.spec && \
	  cp $${RPMBUILD}/SOURCES/*.tar.gz $(CURDIR)/bin/ && \
	  cp $${RPMBUILD}/RPMS/*/*.rpm $(CURDIR)/bin/ && \
	  rm -rf $${NAME}-$${VERSION} $${NAME}-$${VERSION}.tar.gz $${RPMBUILD}

build-rpm:
	$(CONTAINER_TOOL) run --rm \
		-v "$(CURDIR):$(PROJECT_DIR):ro" \
		-v "$(CURDIR)/bin:/output" \
		-w /tmp \
		$(CONTAINER_IMAGE) \
		bash -c "\
		  NAME=auto-app && \
		  VERSION=0.1 && \
		  cp -r $(PROJECT_DIR)/src \$${NAME}-\$${VERSION} && \
		  tar czf \$${NAME}-\$${VERSION}.tar.gz \$${NAME}-\$${VERSION} && \
		  mkdir -p ~/rpmbuild/{SOURCES,SPECS} && \
		  cp \$${NAME}-\$${VERSION}.tar.gz ~/rpmbuild/SOURCES/ && \
		  cp \$${NAME}-\$${VERSION}/auto-app.spec ~/rpmbuild/SPECS/ && \
		  rpmbuild -ba ~/rpmbuild/SPECS/auto-app.spec && \
		  cp ~/rpmbuild/SOURCES/*.tar.gz /output/ && \
		  cp ~/rpmbuild/RPMS/*/*.rpm /output/ && \
		  createrepo_c --update /output"

update-repo:
	$(CONTAINER_TOOL) run --rm \
		-v "$(CURDIR)/bin:/output" \
		-w /output \
		$(CONTAINER_IMAGE) \
		createrepo_c --update .
		  
build-container:
	$(CONTAINER_TOOL) build $(BUILD_ARGS) \
		-f containers/codespaces/Containerfile \
		-t $(CONTAINER_IMAGE):$(TAG) \
		containers/codespaces/

build-autosd:
	mkdir -p $(dir $(AUTOSD_IMAGE))
	./auto-image-builder.sh -d build \
		--target $(AUTOSD_TARGET) \
		$(AUTOSD_MANIFEST) \
		$(AUTOSD_IMAGE)

clean:
	rm -rf src/build src/CMakeCache.txt src/cmake_install.cmake src/CMakeFiles src/auto-app
	rm -f bin/*.rpm bin/*.tar.gz bin/auto-app src/Makefile src/*.tar.gz src/*.rpm
	rm -rf bin/repodata
	rm -f images/*.qcow2
