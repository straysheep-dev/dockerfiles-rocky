# dockerfiles-rocky

Dockerfiles to build Rocky images. See [straysheep-dev/docker-configs](https://github.com/straysheep-dev/docker-configs) for a general overview and references.

> [!WARNING]
> Rocky Linux is unique in that the `:latest` tag sometimes points to previous major versions. You should instead specify a major version (e.g. 8, 9, 10) which is why this repo won't maintain a "latest" Dockerfile.
>
> See [_/rockylinux](https://hub.docker.com/_/rockylinux) which points to [r/rockylinux](https://hub.docker.com/r/rockylinux/rockylinux).

> [!NOTE]
> These files were built from a combination of:
> - [geerlingguy's](https://github.com/geerlingguy) `docker-<os>-ansible` templates
> - [Molecule's systemd-enabled container guide](https://ansible.readthedocs.io/projects/molecule/guides/systemd-container/)
> - [Rocky Linux Docker image systemd integration notes](https://hub.docker.com/r/rockylinux/rockylinux#systemd-integration)
> - Searching for, and reviewing, examples and documentation with ChatGPT or AI mode Google Search


## Images

| Version | Components and Software | Status |
| :--- | :---: | :---: |
| `rockylinux/rockylinux:10` | `systemd` | ![Static Badge](https://img.shields.io/badge/supported-green) |
| `rockylinux/rockylinux:9` | `systemd` | ![Static Badge](https://img.shields.io/badge/supported-green) |
| `rockylinux/rockylinux:8` | `systemd` | ![Static Badge](https://img.shields.io/badge/supported-green) |


## Build & Test

See [build, tag, and publish an image](https://docs.docker.com/get-started/docker-concepts/building-images/build-tag-and-publish-an-image/).

```bash
# Tag the file with any name you want, and point to the dockerfile with -f
# This also assumes you're in the cwd of the dockerfile with the "." on the end
docker build -t local/my-image-name -f ./some.Dockerfile .
```

If the image you built uses systemd, you need to start it with `systemd` executed in the background first. The arguments required are the [same that you'd use for running molecule containers with systemd support](https://ansible.readthedocs.io/projects/molecule/guides/systemd-container/#systemd-container). You can see an example of this in [geerlingguy's build.yml using GitHub actions to build and test Docker containers](https://github.com/geerlingguy/docker-rockylinux9-ansible/blob/4c366b8059f5bf993e30b7d38da37b9900b6f17f/.github/workflows/build.yml#L26).

- See the [`docker run` command reference](https://docs.docker.com/reference/cli/docker/container/run/#description)
- `-d` is most important here, it runs as a daemon in the background so `systemd` can start within the container as PID 1
- `--name` can be anything you want to name that instance of the running container
- `--hostname` is also independant of the container image name
- `local/kali-molecule` is the same arg as `-t [registry/]repository[:tag]` when you either pulled or built the image

```bash
container_name='kali-molecule'
container_hostname='kali-molecule'
image_registry='local'
image_name='kali-molecule'

docker run -d \
  --name "${container_name}" \
  --hostname "${container_hostname}" \
  --privileged \
  --cgroupns=host \
  --tmpfs /run \
  --tmpfs /tmp \
  -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
  -e container=docker \
  "${image_registry}"/"${image_name}" /sbin/init

```

*Then* interactively execute a shell in the running container once it starts:

```bash
docker exec -it "${container_name}" /bin/bash
# When you're done
exit
docker stop "${container_name}"

```


## License

[MIT](LICENSE)
