# autosd-quickstart

Get started with [CentOS Automotive Stream Distribution (AutoSD)](https://sigs.centos.org/automotive/latest/getting-started/index.html) — a Linux distro tailored for in-vehicle and edge automotive use cases.

This repo provides:

- **Image manifests** for building AutoSD QEMU images (`manifests/`)
- A sample **C++ application** with CMake and RPM packaging (`src/`)
- **Quadlet container units** and systemd services for running containerised workloads on AutoSD (`files/`)
- **OpenShift deployment files** for engine/radio/vsomeip services (`files/ocp/`)
- A **Makefile** that drives all builds inside a Podman container
- **GitHub Actions CI** for multi-arch container builds (`.github/workflows/`)
- A **devfile** for cloud-based developer workspaces (`.devfile.yaml`)

## Prerequisites

Image builds run inside a rootful Podman container. Install Podman for your platform by following the [official Podman installation instructions](https://podman.io/docs/installation).

On macOS (or any system where Podman runs inside a managed VM rather than natively), you also need to create and start a Podman machine. The machine must be configured as **rootful** because image builds require root-level access inside the container:

```shell
podman machine init
podman machine set --rootful
podman machine start
```

On a native Linux host with Podman already installed, you can skip the machine setup — just make sure you run the build commands with `sudo` or as root.

## Build the application

All build targets run inside the `ghcr.io/rhadp-examples/codespaces` container, so no local toolchain is needed beyond Podman.

```shell
make build           # compile auto-app (output: bin/auto-app)
make build-rpm       # build the RPM and source tarball (output: bin/*.rpm)
```

See `src/` for the C++ source, CMakeLists.txt, and RPM spec.

## Build an AutoSD image

Build a minimal QEMU-bootable image from one of the included manifests:

```shell
make build-autosd                                      # uses manifests/minimal.aib.yml
make build-autosd AUTOSD_MANIFEST=manifests/qm.aib.yml # or pick another
```

Available manifests:

| Manifest | Description |
|----------|-------------|
| `minimal.aib.yml` | Bare-bones image |
| `developer.aib.yml` | Development tools, compilers, git, rpm-build |
| `container.aib.yml` | Containerised engine/radio services via Quadlet |
| `qm.aib.yml` | QM safety partition (empty) |
| `qm-container.aib.yml` | Containerised services inside the QM partition |
| `static-ip.aib.yml` | Static network configuration |

## Run the image

Launch the image with `air`, a convenience wrapper around `qemu-system`:

```shell
./air --nographics images/minimal-autosd.qcow2
```

Log in with **root** / **password**, then verify:

```shell
uname -r
uname -m
```

Useful `air` options:

| Flag | Description |
|------|-------------|
| `--nographics` | Headless serial console (no GUI window) |
| `--memory 4G` | Set guest RAM (default 2G) |
| `--ssh-port 2222` | Forward host port to guest SSH (default 2222) |
| `--snapshot` | Run on a throwaway copy — original image stays untouched |
| `--cdrom file.iso` | Attach an ISO as a CD-ROM drive |

See `./air --help` for the full list.

## Repository layout

```
src/                   C++ app source, CMake build, RPM spec
manifests/             AutoSD image-builder manifests
files/                 Quadlet .container units and systemd services
files/ocp/             OpenShift/Kubernetes deployment files
containers/codespaces/ Containerfile for the dev/build container
.github/workflows/     CI: multi-arch container build + attestation
.devfile.yaml          Devfile for cloud workspaces
```
