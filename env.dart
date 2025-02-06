part of 'main.dart';

String ndk =
    "${Platform.environment['HOME']}/Library/Android/sdk/ndk/26.1.10909125";
String toolchain = "$ndk/toolchains/llvm/prebuilt/darwin-x86_64/bin";

String nproc = "10";
String machineArch = "arm";

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
bool get isMacos => platform == BuildPlatform.macOS;
bool get isDarwin =>
    platform == BuildPlatform.iPhone ||
    platform == BuildPlatform.iPhoneSimulator ||
    platform == BuildPlatform.macOS;

String arch = "";
String cc = "";
String cxx = "";
String ld = "";
String ar = "";
String as = "";
String strip = "";
String ranlib = "";
String objcopy = "";
String hostTripple = "";
String buildTripple = "";
String ndkTripple = "";
String llvmTripple = "";
String androidArch = "";

String xcode = "/Applications/Xcode.app/Contents/Developer";
String darwinSDK = "";
String iOSMinVersion = "";
String macOSMinVersion = "";
String darwinPlatform = "";

String cFlags = "";
String ldFlags = "";

String buildDir = "";

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

Future<void> configmacOSARM64() async {
  platform = BuildPlatform.macOS;
  arch = "arm64";
}

Future<void> configmacOSx86() async {
  platform = BuildPlatform.macOS;
  arch = "x86_64";
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
      hostTripple = "arm-linux-androideabi";
      ndkTripple = "armv7a-linux-androideabi21";
      llvmTripple = "armv7-linux-androideabi";
      androidArch = "armeabi-v7a";
    } else if (arch == "aarch64") {
      hostTripple = "aarch64-linux-android";
      ndkTripple = "aarch64-linux-android21";
      llvmTripple = "aarch64-linux-android";
      androidArch = "arm64-v8a";
    } else if (arch == "x86_64") {
      hostTripple = "x86_64-linux-android";
      ndkTripple = "x86_64-linux-android21";
      llvmTripple = "x86_64-linux-android";
      androidArch = "x86_64";
    }

    cc = "$toolchain/$ndkTripple-clang";
    cxx = "$toolchain/$ndkTripple-clang++";
    ld = "$toolchain/ld";
    ar = "$toolchain/llvm-ar";
    as = "$toolchain/llvm-as";
    objcopy = "$toolchain/llvm-objcopy";
    strip = "$toolchain/llvm-strip";
    ranlib = "$toolchain/llvm-ranlib";
  } else if (isDarwin) {
    iOSMinVersion = "8.0";
    macOSMinVersion = "10.12";

    if (platform == BuildPlatform.iPhone) {
      darwinPlatform = "iPhoneOS";
      buildDir = "build/ios";
    } else if (platform == BuildPlatform.iPhoneSimulator) {
      darwinPlatform = "iPhoneSimulator";
      buildDir = "build/ios";
    } else if (platform == BuildPlatform.macOS) {
      darwinPlatform = "MacOSX";
      buildDir = "build/macos";
    }

    darwinSDK =
        "$xcode/Platforms/${darwinPlatform}.platform/Developer/SDKs/${darwinPlatform}.sdk";
    cc = "$xcode/usr/bin/gcc";
    cxx = "$xcode/usr/bin/g++";
    ld = "$xcode/usr/bin/ld";
    ar = "$xcode/Toolchains/XcodeDefault.xctoolchain/usr/bin/ar";
    as = "$xcode/Toolchains/XcodeDefault.xctoolchain/usr/bin/as";
    strip = "$xcode/Toolchains/XcodeDefault.xctoolchain/usr/bin/strip";
    ranlib = "$xcode/Toolchains/XcodeDefault.xctoolchain/usr/bin/ranlib";

    cFlags = "-arch ${arch} -pipe -Os -gdwarf-2 -isysroot $darwinSDK";

    if (platform == BuildPlatform.iPhone) {
      cFlags += " -miphoneos-version-min=${iOSMinVersion}";
    } else if (platform == BuildPlatform.iPhoneSimulator) {
      cFlags += " -miphonesimulator-version-min=${iOSMinVersion}";
    } else if (platform == BuildPlatform.macOS) {
      cFlags += " -mmacosx-version-min=${macOSMinVersion}";
    }

    ldFlags = "-arch ${arch} -isysroot $darwinSDK";

    if (machineArch == "arm") {
      buildTripple = "arm-apple-darwin";
    } else if (machineArch == "x86_64") {
      buildTripple = "x86_64-apple-darwin";
    }

    if (arch == "arm64") {
      hostTripple = "arm-apple-darwin";
    }
    if (arch == "x86_64") {
      hostTripple = "x86_64-apple-darwin";
    }

    if (arch == "arm64" && platform == BuildPlatform.iPhone) {
      llvmTripple = "aarch64-apple-ios";
    }
    if (arch == "arm64" && platform == BuildPlatform.iPhoneSimulator) {
      llvmTripple = "aarch64-apple-ios-sim";
    }
    if (arch == "x86_64" && platform == BuildPlatform.iPhoneSimulator) {
      llvmTripple = "x86_64-apple-ios";
    }
    if (arch == "arm64" && platform == BuildPlatform.macOS) {
      llvmTripple = "aarch64-apple-darwin";
    }
    if (arch == "x86_64" && platform == BuildPlatform.macOS) {
      llvmTripple = "x86_64-apple-darwin";
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

Map<String, String> getDarwinEnv() {
  return {
    "CC": cc,
    "CXX": cxx,
    "LD": ld,
    "CFLAGS": cFlags,
    "LDFLAGS": ldFlags,
  };
}
