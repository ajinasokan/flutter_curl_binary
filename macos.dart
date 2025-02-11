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

  await packmacOSFramework();
  await zipmacOSFramework();
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

Future<void> packmacOSFramework() async {
  await run(
    "mkdir -p Curl.framework\n"
    "lipo Curl_arm64_macos.a Curl_x86_64_macos.a -create -output Curl.framework/Curl",
    dir: "build/macos",
  );
}

Future<void> zipmacOSFramework() async {
  await run(
    "rm -rf Curl.framework.zip\n"
    "zip -r Curl.framework.zip Curl.framework",
    dir: "build/macos",
  );
}
