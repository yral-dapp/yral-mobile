#!/bin/bash

##################################################
# We call this from an Xcode run script.
##################################################

set -e

if [[ -z "$PROJECT_DIR" ]]; then
    echo "Must provide PROJECT_DIR environment variable set to the Xcode project directory." 1>&2
    exit 1
fi

cd $PROJECT_DIR

export PATH="$HOME/.cargo/bin:$PATH"

# Without this we can't compile on MacOS Big Sur
# https://github.com/TimNN/cargo-lipo/issues/41#issuecomment-774793892
if [[ -n "${DEVELOPER_SDK_DIR:-}" ]]; then
  export LIBRARY_PATH="${DEVELOPER_SDK_DIR}/MacOSX.sdk/usr/lib:${LIBRARY_PATH:-}"
fi

# For GitHub Actions, we'll only build for arm64 initially
if [[ "$CI" == "true" ]]; then
    echo "Building for CI environment (aarch64-apple-ios only)"
        cargo lipo \
      --manifest-path ../rust-agent/Cargo.toml \
      --targets aarch64-apple-ios \
      -p yral-mobile-swift-binding

else
    # Original logic for local development
    TARGETS=""
    if [[ "$PLATFORM_NAME" = "iphonesimulator" ]]; then
        TARGETS="aarch64-apple-ios-sim,x86_64-apple-ios"
    else
        TARGETS="aarch64-apple-ios,x86_64-apple-ios"
    fi

    if [[ $CONFIGURATION == "Release" ]]; then
        echo "BUILDING FOR RELEASE ($TARGETS)"
        cargo lipo --release --manifest-path ../rust-agent/Cargo.toml --targets $TARGETS
    else
        echo "BUILDING FOR DEBUG ($TARGETS)"
        cargo lipo --manifest-path ../rust-agent/Cargo.toml --targets $TARGETS
    fi
fi
