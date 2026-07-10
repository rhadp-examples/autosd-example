CONTAINER_IMAGE := ghcr.io/rhadp-examples/codespaces:latest
PROJECT_DIR      := /projects

.PHONY: build build-rpm clean

build: clean
	podman run --rm \
		-v "$(CURDIR):$(PROJECT_DIR):ro" \
		-v "$(CURDIR)/bin:/output" \
		--tmpfs $(PROJECT_DIR)/src/build \
		-w $(PROJECT_DIR)/src \
		$(CONTAINER_IMAGE) \
		bash -c "cmake -B build . && cmake --build build && \
		  cp build/auto-hello /output/"

build-rpm:
	podman run --rm \
		-v "$(CURDIR):$(PROJECT_DIR):ro" \
		-v "$(CURDIR)/bin:/output" \
		-w $(PROJECT_DIR)/src \
		$(CONTAINER_IMAGE) \
		bash -c "\
		  cp -r $(PROJECT_DIR)/src /tmp/build-rpm && \
		  cd /tmp/build-rpm && \
		  make -f Makefile.rpm rpm && \
		  cp /tmp/build-rpm/*.tar.gz /output/ && \
		  cp ~/rpmbuild/RPMS/*/*.rpm /output/"

clean:
	rm -rf src/build src/CMakeCache.txt src/cmake_install.cmake src/CMakeFiles src/auto-hello
