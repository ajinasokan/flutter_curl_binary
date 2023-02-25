part of 'main.dart';

String ndk =
    "${Platform.environment['HOME']}/Library/Android/sdk/ndk/21.4.7075529";
String toolchain = "$ndk/toolchains/llvm/prebuilt/darwin-x86_64/bin";

String nproc = "10";

class BuildPlatform {
  final String value;
  BuildPlatform(this.value);

  static final Android = BuildPlatform("android");
  static final iPhone = BuildPlatform("iphone");
  static final iPhoneSimulator = BuildPlatform("iphonesimulator");
  static final macOS = BuildPlatform("macos");
}

BuildPlatform platform = BuildPlatform.Android;

bool get isAndroid => platform == BuildPlatform.Android;
bool get isDarwin =>
    platform == BuildPlatform.iPhone ||
    platform == BuildPlatform.iPhoneSimulator;

String arch = "";
String cc = "";
String cxx = "";
String ld = "";
String ar = "";
String as = "";
String strip = "";
String ranlib = "";
String objcopy = "";
String cctripple = "";
String tripple = "";
String rustTripple = "";
String androidArch = "";

String xcode = "/Applications/Xcode.app/Contents/Developer";
String iOSSDK = "";
String iOSMinVersion = "";
String iOSPlatform = "";

String cFlags = "";
String ldFlags = "";

Future<void> configAndroidARM() async {
  platform = BuildPlatform.Android;
  arch = "arm";
}

Future<void> configAndroidARM64() async {
  platform = BuildPlatform.Android;
  arch = "aarch64";
}

Future<void> configAndroidx86() async {
  platform = BuildPlatform.Android;
  arch = "x86_64";
}

Future<void> configiPhoneARM64() async {
  platform = BuildPlatform.iPhone;
  arch = "arm64";
}

Future<void> configiPhoneSimulatorARM64() async {
  platform = BuildPlatform.iPhoneSimulator;
  arch = "arm64";
}

Future<void> configiPhoneSimulatorx86() async {
  platform = BuildPlatform.iPhoneSimulator;
  arch = "x86_64";
}

Future<void> collectPaths() async {
  if (isAndroid) {
    if (arch == "arm") {
      tripple = "arm-linux-androideabi";
      cctripple = "armv7a-linux-androideabi21";
      rustTripple = "armv7-linux-androideabi";
      androidArch = "armeabi-v7a";
    } else if (arch == "aarch64") {
      tripple = "aarch64-linux-android";
      cctripple = "aarch64-linux-android21";
      rustTripple = "aarch64-linux-android";
      androidArch = "arm64-v8a";
    } else if (arch == "x86_64") {
      tripple = "x86_64-linux-android";
      cctripple = "x86_64-linux-android21";
      rustTripple = "x86_64-linux-android";
      androidArch = "x86_64";
    }

    cc = "$toolchain/$cctripple-clang";
    cxx = "$toolchain/$cctripple-clang++";
    ld = "$toolchain/$tripple-ld";
    ar = "$toolchain/$tripple-ar";
    as = "$toolchain/$tripple-as";
    objcopy = "$toolchain/$tripple-objcopy";
    strip = "$toolchain/$tripple-strip";
    ranlib = "$toolchain/$tripple-ranlib";
  } else if (isDarwin) {
    iOSMinVersion = "8.0";

    if (platform == BuildPlatform.iPhone) {
      iOSPlatform = "iPhoneOS";
    } else {
      iOSPlatform = "iPhoneSimulator";
    }

    iOSSDK =
        "$xcode/Platforms/${iOSPlatform}.platform/Developer/SDKs/${iOSPlatform}.sdk";
    cc = "$xcode/usr/bin/gcc";
    cxx = "$xcode/usr/bin/g++";
    ld = "$xcode/usr/bin/ld";
    ar = "$xcode/Toolchains/XcodeDefault.xctoolchain/usr/bin/ar";
    as = "$xcode/Toolchains/XcodeDefault.xctoolchain/usr/bin/as";
    strip = "$xcode/Toolchains/XcodeDefault.xctoolchain/usr/bin/strip";
    ranlib = "$xcode/Toolchains/XcodeDefault.xctoolchain/usr/bin/ranlib";

    cFlags = "-arch ${arch} -pipe -Os -gdwarf-2 -isysroot $iOSSDK";

    if (platform == BuildPlatform.iPhone) {
      cFlags += " -miphoneos-version-min=${iOSMinVersion}";
    } else if (platform == BuildPlatform.iPhoneSimulator) {
      cFlags += " -miphonesimulator-version-min=${iOSMinVersion}";
    }

    ldFlags = "-arch ${arch} -isysroot $iOSSDK";
    tripple = "${arch}-apple-darwin";
    if (arch == "arm64" || arch == "arm64e") {
      tripple = "arm-apple-darwin";
    }

    cctripple = "${arch}-apple-ios";
    if (arch == "arm64") {
      cctripple = "aarch64-apple-ios";
      if (platform == BuildPlatform.iPhoneSimulator) {
        cctripple += "-sim";
      }
    }
  }
}

Map<String, String> getAndroidEnv() {
  return {
    "CC": cc,
    "CXX": cxx,
    "LD": ld,
    "AR": ar,
    "AS": as,
    "OBJCOPY": objcopy,
    "STRIP": strip,
    "RANLIB": ranlib,
  };
}

Map<String, String> getiOSEnv() {
  return {
    "CC": cc,
    "CXX": cxx,
    "LD": ld,
    "CFLAGS": cFlags,
    "LDFLAGS": ldFlags,
  };
}
