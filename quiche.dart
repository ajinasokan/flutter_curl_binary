part of 'main.dart';

Future<void> buildQuiche() async {
  if (isAndroid) {
    await run(
      "cargo ndk --target $androidArch --platform 21 -- build --package quiche --release --features ffi,pkg-config-meta,qlog\n"
      "rm -rf deps\n"
      "mkdir -p deps/boringssl/lib\n"
      "cp \$(find target/$rustTripple -name libcrypto.a -o -name libssl.a) deps/boringssl/lib/\n"
      "cp -R quiche/deps/boringssl/src/include deps/boringssl/",
      dir: "quiche",
      env: {
        "ANDROID_NDK_HOME": ndk,
      },
    );
    await run(
      "rm *.so",
      dir: "${abs("quiche")}/target/$rustTripple/release",
    );
  } else if (isDarwin) {
    await run(
      "cargo clean\n"
      "cargo build --release --target $cctripple --features ffi,pkg-config-meta,qlog\n"
      "rm -rf deps\n"
      "mkdir -p deps/boringssl/lib\n"
      "cp \$(find target/$cctripple -name libcrypto.a -o -name libssl.a) deps/boringssl/lib/\n"
      "cp -R quiche/deps/boringssl/src/include deps/boringssl/",
      dir: "quiche",
      // env: getiOSEnv(),
    );
    await run(
      "rm *.dylib",
      dir: "${abs("quiche")}/target/$cctripple/release",
    );
    await run(
      "cp quiche/target/$cctripple/release/libquiche.a build/ios/libquiche_${arch}_${platform.value}.a",
    );
  }
}
