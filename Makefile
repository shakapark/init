IMAGE ?= storageos/init:test
GO_BUILD_CMD = go build -v
GO_ENV = GOOS=linux CGO_ENABLED=0

# Test node image name.
NODE_IMAGE ?= storageos/node:1.4.0
# Test scripts path.
SCRIPTS_PATH ?= /scripts

all: unittest build

.PHONY: build

build:
	@echo "Building init"
	$(GO_ENV) $(GO_BUILD_CMD) -o ./build/_output/bin/init .

image:
	docker build --no-cache . -f Dockerfile -t $(IMAGE)

unittest: generate
	go test -v -race `go list -v ./...`

clean:
	rm -rf build/_output

# Run the init scripts on the host.
run:
	docker run --rm \
		--cap-add=SYS_ADMIN \
		--privileged \
		-v /lib/modules:/lib/modules \
		-v /var/lib/storageos:/var/lib/storageos:rshared \
		-v /sys:/sys:rshared \
		storageos/init:test \
		/init -scripts=$(SCRIPTS_PATH) -nodeImage=$(NODE_IMAGE)

# Generate mocks.
generate:
	go generate ./...
