OS := $(shell uname)
ifeq ($(OS),Linux)
	TAR_OPTS := --wildcards
endif

all: deps lint test install

fmt:
	go fmt ./...

test:
	go test ./...

vet:
	go vet ./...

megacheck:
	megacheck 2> /dev/null; if [ $$? -eq 127 ]; then \
		go get -v honnef.co/go/tools/cmd/megacheck; \
	fi
	megacheck ./...

check-fmt:
	bash -c "diff --line-format='%L' <(echo -n) <(gofmt -d -s .)"

lint: check-fmt vet

deps:
	go get

install:
	go install ./...

databases := GeoLite2-City GeoLite2-Country

$(databases):
	mkdir -p data
	curl -fsSL -m 30 https://geolite.maxmind.com/download/geoip/database/$@.tar.gz | tar $(TAR_OPTS) --strip-components=1 -C $(PWD)/data -xzf - '*.mmdb'
	test ! -f data/GeoLite2-City.mmdb || mv data/GeoLite2-City.mmdb data/city.mmdb
	test ! -f data/GeoLite2-Country.mmdb || mv data/GeoLite2-Country.mmdb data/country.mmdb

geoip-download: $(databases)
