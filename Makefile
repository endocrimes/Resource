.PHONY: all clean build test

all: build test

clean:
	swift build --clean

build:
	swift build

test:
	.build/debug/spectre-build

