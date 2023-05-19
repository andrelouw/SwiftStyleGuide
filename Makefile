VERSION=0.0.7
ARTIFACT_BUNDLE=swiftstyle.artifactbundle
INFO_TEMPLATE=spm-artifact-bundle-info.template
MAC_BINARY_OUTPUT_DIR=$(ARTIFACT_BUNDLE)/swiftstyle-$(VERSION)-macos/bin
SWIFTSTYLE_BIN_PATH=$(shell swift build -c release --arch x86_64 --arch arm64 --show-bin-path)

.PHONY: build

build:
	swift build -c release --arch x86_64 --arch arm64
	mkdir -p $(ARTIFACT_BUNDLE)
	sed 's/__VERSION__/'"$(VERSION)"'/g' $(INFO_TEMPLATE) > "$(ARTIFACT_BUNDLE)/info.json"
	mkdir -p "$(MAC_BINARY_OUTPUT_DIR)"
	swift build -c release --arch x86_64 --arch arm64 --show-bin-path
	cp $(SWIFTSTYLE_BIN_PATH)/swiftstyle $(MAC_BINARY_OUTPUT_DIR)
	zip -yr - $(ARTIFACT_BUNDLE) > "$(ARTIFACT_BUNDLE).zip"
	rm -rf $(ARTIFACT_BUNDLE)
	swift package compute-checksum swiftstyle.artifactbundle.zip





