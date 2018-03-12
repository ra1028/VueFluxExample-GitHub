.PHONY: bootstrap update

CARTHAGE := $(shell command -v carthage 2> /dev/null)

bootstrap:
ifndef CARTHAGE
	$(error "run `brew install carthage` beforehand")
endif
	carthage bootstrap --platform iOS --cache-builds

update:
ifndef CARTHAGE
        $(error "run `brew install carthage` beforehand")
endif
	carthage update --platform iOS --cache-builds
