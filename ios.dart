part of 'main.dart';

Future<void> alliOS() async {
  await configiPhoneARM64();
  await collectPaths();
  await buildiOS();
  await combineStaticLibs();

  await configiPhoneSimulatorARM64();
  await collectPaths();
  await buildiOS();
  await combineStaticLibs();

  await configiPhoneSimulatorx86();
  await collectPaths();
  await buildiOS();
  await combineStaticLibs();

  await stripiOSBinary();

  await packiOSXCFramework();
  await zipiOSXCFramework();
}

Future<void> buildiOS() async {
  await configBrotli();
  await buildBrotli();

  await configNghttp2();
  await buildNghttp2();

  await buildQuiche();

  await configCurl();
  await buildCurl();
}

Future<void> combineStaticLibs() async {
  await run(
    "libtool -static -o build/ios/Curl_${arch}_${platform.value}.a "
    "build/ios/libnghttp2_${arch}_${platform.value}.a "
    "build/ios/libquiche_${arch}_${platform.value}.a "
    "build/ios/libbrotlidec_${arch}_${platform.value}.a "
    "build/ios/libbrotlicommon_${arch}_${platform.value}.a "
    "build/ios/libcurl_${arch}_${platform.value}.a",
  );
}

Future<void> stripiOSBinary() async {
  await run(
    "strip -rSTx Curl_arm64_iphonesimulator.a\n"
    "strip -rSTx Curl_x86_64_iphonesimulator.a\n"
    "strip -rSTx Curl_arm64_iphone.a",
    dir: "build/ios",
  );
}

/// Packs the per-slice static libs into a static-library xcframework.
/// Device and simulator libs go in as separate `-library` slices; xcodebuild
/// reads the platform from each archive's Mach-O. SPM links a static-library
/// xcframework (LibraryPath = libCurl.a) instead of embedding it, which is what
/// an FFI plugin using DynamicLibrary.process() needs.
Future<void> packiOSXCFramework() async {
  await run(
    // combine the simulator arches into one fat static lib
    "lipo Curl_arm64_iphonesimulator.a Curl_x86_64_iphonesimulator.a -create -output Curl_iphonesimulator.a\n"
    // name every slice's library libCurl.a so LibraryPath is consistent
    "rm -rf slices Curl.xcframework\n"
    "mkdir -p slices/device slices/sim\n"
    "cp Curl_arm64_iphone.a slices/device/libCurl.a\n"
    "cp Curl_iphonesimulator.a slices/sim/libCurl.a\n"
    "xcodebuild -create-xcframework "
    "-library slices/device/libCurl.a "
    "-library slices/sim/libCurl.a "
    "-output Curl.xcframework",
    dir: "build/ios",
  );
}

Future<void> zipiOSXCFramework() async {
  await run(
    "rm -rf Curl.ios.xcframework.zip\n"
    "zip -r Curl.ios.xcframework.zip Curl.xcframework",
    dir: "build/ios",
  );
  // SPM binaryTarget(url:) checksum is the SHA-256 of the zip.
  final checksum = runCapture(
    "shasum -a 256 Curl.ios.xcframework.zip | awk '{print \$1}'",
    dir: "build/ios",
  );
  print("Curl.ios.xcframework.zip checksum: $checksum");
}
