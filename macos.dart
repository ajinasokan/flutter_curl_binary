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
  await createArtifactBundlemacOS();
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

/// Wraps Curl.framework in an .xcframework + .artifactbundle and zips it for SPM remote binary targets.
/// SPM binaryTarget requires an .xcframework, so we first wrap the .framework into one, then wrap that in an artifactbundle.
Future<void> createArtifactBundlemacOS() async {
  // First create an xcframework from the macOS framework
  await run(
    "rm -rf Curl.xcframework\n"
    "mkdir -p Curl.xcframework/macos-arm64_x86_64/Curl.framework\n"
    "cp -r Curl.framework/Curl Curl.xcframework/macos-arm64_x86_64/Curl.framework/Curl\n"
    "cat > Curl.xcframework/Info.plist << 'EOF'\n"
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n"
    "<plist version=\"1.0\">\n"
    "<dict>\n"
    "\t<key>AvailableLibraries</key>\n"
    "\t<array>\n"
    "\t\t<dict>\n"
    "\t\t\t<key>LibraryIdentifier</key>\n"
    "\t\t\t<string>macos-arm64_x86_64</string>\n"
    "\t\t\t<key>LibraryPath</key>\n"
    "\t\t\t<string>Curl.framework</string>\n"
    "\t\t\t<key>SupportedArchitectures</key>\n"
    "\t\t\t<array>\n"
    "\t\t\t\t<string>arm64</string>\n"
    "\t\t\t\t<string>x86_64</string>\n"
    "\t\t\t</array>\n"
    "\t\t\t<key>SupportedPlatform</key>\n"
    "\t\t\t<string>macos</string>\n"
    "\t\t</dict>\n"
    "\t</array>\n"
    "\t<key>CFBundlePackageType</key>\n"
    "\t<string>XFWK</string>\n"
    "\t<key>XCFrameworkFormatVersion</key>\n"
    "\t<string>1.0</string>\n"
    "</dict>\n"
    "</plist>\n"
    "EOF",
    dir: "build/macos",
  );

  // Then wrap in an artifactbundle and zip
  await run(
    "rm -rf Curl.artifactbundle\n"
    "mkdir -p Curl.artifactbundle\n"
    "cp -r Curl.xcframework Curl.artifactbundle/\n"
    "cat > Curl.artifactbundle/Info.json << 'EOF'\n"
    "{\n"
    "  \"schemeVersion\": \"1.0\",\n"
    "  \"artifacts\": {\n"
    "    \"Curl.xcframework\": {\n"
    "      \"type\": \"xcframework\",\n"
    "      \"settings\": {}\n"
    "    }\n"
    "  }\n"
    "}\n"
    "EOF\n"
    "rm -f Curl.artifactbundle.zip\n"
    "cd Curl.artifactbundle && zip -r ../Curl.artifactbundle.zip .",
    dir: "build/macos",
  );
  // Compute SHA-256 and rename the artifactbundle zip
  final checksum = runCapture(
    "shasum -a 256 Curl.artifactbundle.zip | awk '{print \$1}'",
    dir: "build/macos",
  );
  await run(
    "mv Curl.artifactbundle.zip macos.${checksum}.artifactbundle.zip",
    dir: "build/macos",
  );
  print("macos.${checksum}.artifactbundle.zip");
}
