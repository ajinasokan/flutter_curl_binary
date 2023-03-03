part of 'main.dart';

Future<void> brotli() async {
  await configBrotli();
  await buildBrotli();
}

Future<void> buildBrotli() async {
  final cmake = "brotli/CMakeLists.txt";
  File(cmake).writeAsStringSync(File(cmake).readAsStringSync().replaceFirst(
      "add_library(brotlidec-static STATIC \${BROTLI_DEC_C})",
      "add_library(brotlidec-static STATIC \${BROTLI_DEC_C} \${BROTLI_COMMON_C})"));

  await run(
    "cmake --build . --config Release --target install --parallel=$nproc",
    dir: "brotli/out",
  );
  if (isAndroid) {
    // delete .so shared lib files. otherwise clang prefers shared libs.
    // rename lib-static.a to lib.a
    await run(
      "rm libbrotlicommon.so*\n"
      "rm libbrotlidec.so*\n"
      "rm libbrotlienc.so*\n"
      "mv libbrotlicommon-static.a libbrotlicommon.a\n"
      "mv libbrotlidec-static.a libbrotlidec.a\n"
      "mv libbrotlienc-static.a libbrotlienc.a\n",
      dir: "brotli/out/installed/lib",
    );
  } else if (isDarwin) {
    await run(
      "rm *.dylib\n"
      "mv libbrotlidec-static.a libbrotlidec.a\n"
      "mv libbrotlienc-static.a libbrotlienc.a\n"
      "mv libbrotlicommon-static.a libbrotlicommon.a\n",
      dir: "brotli/out/installed/lib",
    );
    await run(
      "cp brotli/out/installed/lib/libbrotlidec.a $buildDir/libbrotlidec_${arch}_${platform.value}.a\n"
      "cp brotli/out/installed/lib/libbrotlicommon.a $buildDir/libbrotlicommon_${arch}_${platform.value}.a\n",
    );
  }
}

Future<void> configBrotli() async {
  await run("rm -rf brotli/out && mkdir brotli/out");
  if (isAndroid) {
    await run(
      "cmake -DCMAKE_C_COMPILER=$cc -DCMAKE_CXX_COMPILER=$cxx -DCMAKE_AR=$ar -DCMAKE_LINKER=$ld -DCMAKE_RANLIB=$ranlib -DCMAKE_SYSTEM_NAME=Linux -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=./installed ..",
      dir: "brotli/out",
    );
  } else if (isDarwin) {
    await run(
      "cmake -DCMAKE_C_COMPILER=$cc -DCMAKE_OSX_SYSROOT=$darwinSDK -DCMAKE_OSX_ARCHITECTURES=$arch -DCMAKE_SYSTEM_NAME=Darwin -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=./installed ..",
      dir: "brotli/out",
      env: getDarwinEnv(),
    );
  }
}
