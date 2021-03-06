PWD=$(shell pwd)

build:
	./scripts/make.sh || true

build2:
	BuildTags="docker" ./scripts/make.sh || true

run:
	DEBUG=1 SYSD_UI_DIR="$$(pwd)/mods/ui/files" sysd/sysd

run2:
	DEBUG=1 sysd/sysd --SYSD_BACKEND="docker"

test:
	env

clean:
	rm -rf .gopath || true
	rm -rf .tmp || true
	rm -rf sysd/sysd || true

Manifest: clean
	find . -type f | grep -v -e "^\./\.git" | sort | uniq > Manifest

dist:
	./scripts/tarball.sh || true

install:
	## @if [ ! -f "/usr/bin/sysd" ]; then \
	## 	ln -s $(PWD)/sysd/sysd /usr/bin/sysd; \
	## fi
	install -D --mode=0644 sysd/sysd $(DESTDIR)/usr/sbin/sysd

.PHONY: clean Manifest
