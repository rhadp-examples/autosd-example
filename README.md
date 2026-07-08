# autosd-quickstart

Get started with [CentOS Automotive Stream Distribution (AutoSD)](https://sigs.centos.org/automotive/latest/getting-started/index.html) — a Linux distro tailored for in-vehicle and edge automotive use cases.

This repo provides sample image manifests and the tools to build and run your first AutoSD virtual machine image in minutes.

## Prerequisites

Image builds run inside a rootful Podman container. Install Podman for your platform by following the [official Podman installation instructions](https://podman.io/docs/installation).

On macOS (or any system where Podman runs inside a managed VM rather than natively), you also need to create and start a Podman machine. The machine must be configured as **rootful** because image builds require root-level access inside the container:

```shell
podman machine init
podman machine set --rootful
podman machine start
```

On a native Linux host with Podman already installed, you can skip the machine setup — just make sure you run the build commands with `sudo` or as root.

## Install the tools

Download **auto-image-builder** (the image build wrapper) and **air** (the QEMU VM launcher):

```shell
curl -o auto-image-builder.sh \
  "https://gitlab.com/CentOS/automotive/src/automotive-image-builder/-/raw/main/auto-image-builder.sh"
chmod +x auto-image-builder.sh

curl -o air \
  "https://gitlab.com/CentOS/automotive/src/automotive-image-builder/-/raw/main/bin/air"
chmod +x air
```

## Build an image

Build a minimal QEMU-bootable image from one of the included manifests:

```shell
./auto-image-builder.sh -d build \
  --target qemu \
  manifests/minimal.aib.yml \
  images/minimal-autosd.qcow2
```

Other sample manifests are available under `manifests/` (e.g. `developer.aib.yml`, `qm.aib.yml`).

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
