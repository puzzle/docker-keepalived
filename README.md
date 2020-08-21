# puzzle/keepalived

![Docker Pulls](https://img.shields.io/docker/pulls/puzzle/keepalived)
![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/puzzle/keepalived)
![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/puzzle/keepalived)
![Docker Image Version (latest by date)](https://img.shields.io/docker/v/puzzle/keepalived)

Get pre-built images from the [Docker Hub](https://hub.docker.com/r/puzzle/keepalived/).

**A Docker image to run Keepalived.**
> [keepalived.org](http://keepalived.org/)

- [Quick start](#quick-start)
- [Beginner Guide](#beginner-guide)
	- [Use your own Backup Manager config](#use-your-own-backup-manager-config)
	- [Fix docker mounted file problems](#fix-docker-mounted-file-problems)
	- [Debug](#debug)
- [Environment Variables](#environment-variables)
	- [Set your own environment variables](#set-your-own-environment-variables)
		- [Use command line argument](#use-command-line-argument)
		- [Link environment file](#link-environment-file)
		- [Make your own image or extend this image](#make-your-own-image-or-extend-this-image)
- [Advanced User Guide](#advanced-user-guide)
	- [Extend puzzle/keepalived:latest image](#extend-osixiakeepalived145-image)
	- [Make your own keepalived image](#make-your-own-keepalived-image)
	- [Tests](#tests)
	- [Under the hood: osixia/light-baseimage](#under-the-hood-osixialight-baseimage)
- [Credit](#credit)

## Quick start

This image require the kernel module ip_vs loaded on the host (`modprobe ip_vs`) and need to be run with : --cap-add=NET_ADMIN --net=host

```bash
docker run --cap-add=NET_ADMIN --net=host -d puzzle/keepalived:latest
```

## Beginner Guide

### Use your own Keepalived config
This image comes with a keepalived config file that can be easily customized via environment variables for a quick bootstrap,
but setting your own keepalived.conf is possible. 2 options:

- Link your config file at run time to `/container/service/keepalived/assets/keepalived.conf` :

```bash
docker run --volume /data/my-keepalived.conf:/container/service/keepalived/assets/keepalived.conf --detach puzzle/keepalived:latest
```

- Add your config file by extending or cloning this image, please refer to the [Advanced User Guide](#advanced-user-guide)

### Fix docker mounted file problems

You may have some problems with mounted files on some systems. The startup script try to make some file adjustment and fix files owner and permissions, this can result in multiple errors. See [Docker documentation](https://docs.docker.com/v1.4/userguide/dockervolumes/#mount-a-host-file-as-a-data-volume).

To fix that run the container with `--copy-service` argument :

```bash
docker run [your options] puzzle/keepalived:latest --copy-service
```

### Debug

The container default log level is **info**.
Available levels are: `none`, `error`, `warning`, `info`, `debug` and `trace`.

Example command to run the container in `debug` mode:

```bash
docker run --detach puzzle/keepalived:latest --loglevel debug
```

See all command line options:

```bash
docker run puzzle/keepalived:latest --help
```

## Environment Variables

Environment variables defaults are set in **image/environment/default.yaml**

See how to [set your own environment variables](#set-your-own-environment-variables)


- **KEEPALIVED_INTERFACE**: Keepalived network interface. Defaults to `eth0`
- **KEEPALIVED_PASSWORD**: Keepalived password. Defaults to `sG9lWB37Bgc59cv7` (yes, we chose this a bit more secure default password on purpose)
- **KEEPALIVED_PRIORITY** Keepalived node priority. Defaults to `150`
- **KEEPALIVED_ROUTER_ID** Keepalived virtual router ID. Defaults to `51`

- **KEEPALIVED_UNICAST_PEERS** Keepalived unicast peers. Defaults to :
      - 192.168.1.10
      - 192.168.1.11

  If you want to set this variable at docker run command add the tag `#PYTHON2BASH:` and convert the yaml in python:

```bash
docker run --env KEEPALIVED_UNICAST_PEERS="#PYTHON2BASH:['192.168.1.10', '192.168.1.11']" --detach puzzle/keepalived:latest
```

  To convert yaml to python online : http://yaml-online-parser.appspot.com/


- **KEEPALIVED_VIRTUAL_IPS** Keepalived virtual IPs. Defaults to :
      - 192.168.1.231
      - 192.168.1.232

  If you want to set this variable at docker run command convert the yaml in python, see above.

- **KEEPALIVED_NOTIFY** Script to execute when node state change. Defaults to `/container/service/keepalived/assets/notify.sh`

- **KEEPALIVED_COMMAND_LINE_ARGUMENTS** Keepalived command line arguments; Defaults to `--log-detail --dump-conf`

### Set your own environment variables

#### Use command line argument
Environment variables can be set by adding the --env argument in the command line, for example:

```bash
docker run --env KEEPALIVED_INTERFACE="eno1" --env KEEPALIVED_PASSWORD="password!" \
  --env KEEPALIVED_PRIORITY="100" --detach puzzle/keepalived:latest
```

#### Link environment file

For example if your environment file is in: /data/environment/my-env.yaml

```bash
docker run --volume /data/environment/my-env.yaml:/container/environment/01-custom/env.yaml \
  --detach puzzle/keepalived:latest
```

Take care to link your environment file to `/container/environment/XX-somedir` (with XX < 99 so they will be processed before default environment files) and not  directly to `/container/environment` because this directory contains predefined baseimage environment files to fix container environment (INITRD, LANG, LANGUAGE and LC_CTYPE).

#### Make your own image or extend this image

This is the best solution if you have a private registry. Please refer to the [Advanced User Guide](#advanced-user-guide) just below.

## Advanced User Guide

### Docker Image Versioning
There are three different kind of Docker tags used:

1. `latest`: Latest build from latest Git commit to the `main` branch. Do **not** use this tag for production environments.
2. `<keepalived_version>-rc.*`: Test build of a new Keepalived version. Do **not** use this tag for production, only for testing/staging. This tag could be overridden.
3. `<keepalived_version>`: Stable build of a **tested** Keepalived version. Use this tag for production workloads. This tag should **not** be overridden.

### Extend puzzle/keepalived image

If you need to add your custom TLS certificate, bootstrap config or environment files the easiest way is to extends this image.

Dockerfile example:

```
FROM puzzle/keepalived:<current_version_here>
LABEL maintainer="Your Name <your@name.com>"

ADD keepalived.conf /container/service/keepalived/assets/keepalived.conf
ADD environment /container/environment/01-custom
ADD scripts.sh /container/service/keepalived/assets/notify.sh
```

### Tests

We use **Bats** (Bash Automated Testing System) to test this image:

> [https://github.com/sstephenson/bats](https://github.com/sstephenson/bats)

Install Bats, and in this project directory run :

```bash
make test
```

### Under the hood: osixia/light-baseimage

This image is based on osixia/light-baseimage.
More info: https://github.com/osixia/docker-light-baseimage

## Credit

Thanks to [https://github.com/osixia/docker-keepalived](https://github.com/osixia/docker-keepalived) and [https://github.com/splattner/docker-keepalived](https://github.com/splattner/docker-keepalived)!