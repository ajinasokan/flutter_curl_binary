part of 'main.dart';

Future<void> allmacOS() async {
  await configmacOSARM64();
  await collectPaths();
  await buildmacOS();
  await combinemacOSStaticLibs();

  await configmacOSx86();
  await collectPaths();
  await buildmacOS();
  await combinemacOSStaticLibs();

  await stripmacOSBinary();
  await packmacOSXCFramework();
  await zipmacOSXCFramework();
}

Future<void> buildmacOS() async {
  await configBrotli();
  await buildBrotli();

  await configNghttp2();
  await buildNghttp2();

  await configCares();
  await buildCares();

  await buildQuiche();

  await configCurl();
  await buildCurl();
}

Future<void> combinemacOSStaticLibs() async {
  await run(
    "libtool -static -o build/macos/Curl_${arch}_${platform.value}.a "
    "build/macos/libnghttp2_${arch}_${platform.value}.a "
    "build/macos/libquiche_${arch}_${platform.value}.a "
    "build/macos/libbrotlidec_${arch}_${platform.value}.a "
    "build/macos/libbrotlicommon_${arch}_${platform.value}.a "
    "build/macos/libcares_${arch}_${platform.value}.a "
    "build/macos/libcurl_${arch}_${platform.value}.a",
  );
}

Future<void> stripmacOSBinary() async {
  await run(
    "strip -rSTx Curl_arm64_macos.a\n"
    "strip -rSTx Curl_x86_64_macos.a",
    dir: "build/macos",
  );
}

/// Packs the combined static libs into a static-library xcframework.
/// SPM links static-library xcframeworks (LibraryPath = libCurl.a) instead of
/// embedding them, which is what an FFI plugin using DynamicLibrary.process()
/// needs. A .framework slice would be embedded and require a full bundle.
Future<void> packmacOSXCFramework() async {
  await run(
    "rm -rf Curl.xcframework libCurl.a\n"
    "lipo Curl_arm64_macos.a Curl_x86_64_macos.a -create -output libCurl.a\n"
    "xcodebuild -create-xcframework -library libCurl.a -output Curl.xcframework",
    dir: "build/macos",
  );
}

Future<void> zipmacOSXCFramework() async {
  await run(
    "rm -rf Curl.macos.xcframework.zip\n"
    "zip -r Curl.macos.xcframework.zip Curl.xcframework",
    dir: "build/macos",
  );
  // SPM binaryTarget(url:) checksum is the SHA-256 of the zip.
  final checksum = runCapture(
    "shasum -a 256 Curl.macos.xcframework.zip | awk '{print \$1}'",
    dir: "build/macos",
  );
  print("Curl.macos.xcframework.zip checksum: $checksum");
}
