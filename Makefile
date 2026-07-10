# Host-aware workflow commands. Override with `make switch TARGET=<name>`.

HOSTNAME := $(shell hostname -s)

TARGET_Hunters-Air := hunter-mac
TARGET_Hunters-MacBook-Air := hunter-mac
TARGET_arch := hunter-arch
TARGET_aspire := aspire
TARGET_nixos := aspire

TARGET ?= $(TARGET_$(HOSTNAME))

ifeq ($(TARGET),)
$(error Unknown host '$(HOSTNAME)'. Set TARGET explicitly, e.g. `make switch TARGET=hunter-mac`)
endif

HOME_TARGETS := hunter-arch hunter-mac
NIXOS_TARGETS := aspire
FLAKE := .\#$(TARGET)

ifneq ($(filter $(TARGET),$(HOME_TARGETS)),)
BUILD_CMD := home-manager build --flake $(FLAKE)
TEST_CMD := $(BUILD_CMD)
SWITCH_CMD := home-manager switch -b backup --flake $(FLAKE)
else ifneq ($(filter $(TARGET),$(NIXOS_TARGETS)),)
BUILD_CMD := nixos-rebuild build --flake $(FLAKE)
TEST_CMD := sudo nixos-rebuild test --flake $(FLAKE)
SWITCH_CMD := sudo nixos-rebuild switch --flake $(FLAKE)
else
$(error Unknown TARGET '$(TARGET)'. Expected one of: $(HOME_TARGETS) $(NIXOS_TARGETS))
endif

.PHONY: target build test switch update upgrade fmt check clean

target:
	@echo "hostname: $(HOSTNAME)"
	@echo "target:   $(TARGET)"
	@echo "build:    $(BUILD_CMD)"
	@echo "test:     $(TEST_CMD)"
	@echo "switch:   $(SWITCH_CMD)"

build:
	$(BUILD_CMD)

test:
	$(TEST_CMD)

switch:
	$(SWITCH_CMD)

update:
	nix flake update

upgrade: update switch

fmt:
	nix fmt

check:
	nix flake check --all-systems

clean:
	nix-collect-garbage -d
