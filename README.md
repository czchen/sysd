sysd: the daemon who supplies firsthand system data
====

sysd is an open source project to supply the system data with HTTP API in a
lightweight daemon.

sysd implements a light dependeny daemon in golang, and provides /proc,/sys the
firsthand system data in json/xml/... common formats with a high-level RESTful
HTTP API. With sysd, application and plugin developers are able to save their
works from parsing variant output from low-level unix command tools, and
dependencies.

## Installation

### Build sysd with docker

```
git clone https://github.com/hacking-thursday/sysd && cd sysd
docker run --rm -v "$(pwd)":/usr/src/sysd -w /usr/src/sysd golang ./make.sh
```

## Usage

```
./sysd/sysd
curl http://0.0.0.0:8080/apilist
```
