# Host-aware workflow commands for this flake.
# Override TARGET when needed, e.g. `make switch TARGET=hunter-arch`.

UNAME := $(shell uname -s)
HOSTNAME := $(shell hostname -s 2>/dev/null || hostname)
IS_NIXOS := $(shell test -e /etc/NIXOS && echo 1 || echo 0)

ifeq ($(origin TARGET),undefined)
  ifeq ($(HOSTNAME),Hunters-Air)
    TARGET := hunter-mac
  else ifeq ($(HOSTNAME),nixos)
    TARGET := nixos
  else ifeq ($(HOSTNAME),arch)
    TARGET := hunter-arch
  else
    $(error Unknown host '$(HOSTNAME)'. Set TARGET explicitly, e.g. `make switch TARGET=hunter-mac`)
  endif
endif

ifeq ($(TARGET),hunter-mac)
BUILD_CMD := home-manager build --flake .\#$(TARGET)
TEST_CMD := $(BUILD_CMD)
SWITCH_CMD := home-manager switch --flake .\#$(TARGET)
else ifeq ($(TARGET),hunter-arch)
BUILD_CMD := home-manager build --flake .\#$(TARGET)
TEST_CMD := $(BUILD_CMD)
SWITCH_CMD := home-manager switch --flake .\#$(TARGET)
else ifeq ($(TARGET),nixos)
BUILD_CMD := nixos-rebuild build --flake .\#$(TARGET)
TEST_CMD := sudo nixos-rebuild test --flake .\#$(TARGET)
SWITCH_CMD := sudo nixos-rebuild switch --flake .\#$(TARGET)
else
$(error Unknown TARGET '$(TARGET)'. Expected hunter-mac, hunter-arch, or nixos)
endif

.PHONY: target build test switch update upgrade fmt check clean

target:
	@echo "uname:    $(UNAME)"
	@echo "hostname: $(HOSTNAME)"
	@echo "nixos:    $(IS_NIXOS)"
	@echo "target:   $(TARGET)"
	@echo "build:    $(BUILD_CMD)"
	@echo "test:     $(TEST_CMD)"
	@echo "switch:   $(SWITCH_CMD)"

build:
	@echo "building target: $(TARGET)"
	$(BUILD_CMD)

test:
	@echo "testing target: $(TARGET)"
	$(TEST_CMD)

switch:
	@echo "switching target: $(TARGET)"
	$(SWITCH_CMD)

update:
	nix flake update

upgrade: update switch

fmt:
	nix fmt

check:
	nix flake check

clean:
	nix-collect-garbage -d
