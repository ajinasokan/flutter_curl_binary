part of 'main.dart';

Future<void> alliOS() async {
  await configiPhoneARM64();
  await collectPaths();
  await buildiOS();

  await configiPhoneSimulatorARM64();
  await collectPaths();
  await buildiOS();
  await combineStaticLibs();

  await configiPhoneSimulatorx86();
  await collectPaths();
  await buildiOS();

  await combineStaticLibs();
  await packFramework();
  await zipFramework();
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
    "build/ios/libcurl_${arch}_${platform.value}.a",
  );
}

Future<void> packFramework() async {
  await run(
    "lipo Curl_arm64_iphonesimulator.a Curl_x86_64_iphonesimulator.a -create -output Curl_iphonesimulator.a",
    dir: "build/ios",
  );

  // emulating what xcodebuild does
  // xcodebuild -create-xcframework -framework ./CurliPhone.framework -framework ./CurliPhoneSimulator.framework -output Curl.xcframework

  await run(
    "rm -rf Curl.xcframework\n"
    "mkdir Curl.xcframework\n"
    "mkdir -p Curl.xcframework/ios-arm64/Curl.framework\n"
    "mkdir -p Curl.xcframework/ios-arm64_x86_64-simulator/Curl.framework\n"
    "cp Curl_arm64_iphone.a Curl.xcframework/ios-arm64/Curl.framework/Curl\n"
    "cp Curl_iphonesimulator.a Curl.xcframework/ios-arm64_x86_64-simulator/Curl.framework/Curl",
    dir: "build/ios",
  );

  File("build/ios/Curl.xcframework/Info.plist").writeAsStringSync(plist);
}

Future<void> zipFramework() async {
  await run(
    "rm -rf Curl.xcframework.zip\n"
    "zip -r Curl.xcframework.zip Curl.xcframework",
    dir: "build/ios",
  );
}

final plist = """<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>AvailableLibraries</key>
	<array>
		<dict>
			<key>LibraryIdentifier</key>
			<string>ios-arm64</string>
			<key>LibraryPath</key>
			<string>Curl.framework</string>
			<key>SupportedArchitectures</key>
			<array>
				<string>arm64</string>
			</array>
			<key>SupportedPlatform</key>
			<string>ios</string>
		</dict>
		<dict>
			<key>LibraryIdentifier</key>
			<string>ios-arm64_x86_64-simulator</string>
			<key>LibraryPath</key>
			<string>Curl.framework</string>
			<key>SupportedArchitectures</key>
			<array>
				<string>arm64</string>
				<string>x86_64</string>
			</array>
			<key>SupportedPlatform</key>
			<string>ios</string>
			<key>SupportedPlatformVariant</key>
			<string>simulator</string>
		</dict>
	</array>
	<key>CFBundlePackageType</key>
	<string>XFWK</string>
	<key>XCFrameworkFormatVersion</key>
	<string>1.0</string>
</dict>
</plist>
""";
