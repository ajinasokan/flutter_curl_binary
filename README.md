# Dart script to build curl for iOS and Android

Builds curl native lib in following config:

- HTTP3 with quiche
- HTTP2 with nghttp2
- Brotli
- Android lib as AAR (arm64-v8a, armeabi-v7a, x86_64)
- iOS lib as xcframework (arm64 iphoneos, arm64 iphonesimulator, x86_64 iphonesimulator)
- macOS lib framework (arm64 Apple Silicon, x86_64 Intel)

Binaries are available to download in the releases.

## Setup

Tested in a MacBook Pro with M1 Max, macOS Ventura 13.2.1

Requirements:

- dart
- git
- autoconf
- automake
- libtool
- cmake
- pkg-config
- go
- rust
- cargo-ndk

Rust targets:

- aarch64-linux-android
- armv7-linux-androideabi
- x86_64-linux-android
- aarch64-apple-ios
- x86_64-apple-ios
- x86_64-apple-darwin
- aarch64-apple-darwin

## Running script

```sh
$ dart main.dart clean cloneRepos patchQuiche patchCurl setupDirs

# clones git repos, applies patches

$ dart main.dart alliOS

# output in build/ios/Curl.xcframework

$ dart main.dart allmacOS

# output in build/ios/Curl.framework

$ dart main.dart allAndroid

# output in build/android/Curl.aar
```

## References

- curl - https://github.com/curl/curl
- Build process - https://curl.se/docs/http3.html
- Brotli - https://github.com/google/brotli
- Quiche - https://github.com/cloudflare/quiche
- ngHTTP2 - https://github.com/nghttp2/nghttp2
- c-ares - https://github.com/c-ares/c-ares
