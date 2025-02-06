part of 'main.dart';

Future<void> brotli() async {
  await configBrotli();
  await buildBrotli();
}

Future<void> buildBrotli() async {
  await run(
    "cmake --build . --config Release --target install --parallel=$nproc",
    dir: "brotli/out",
  );
  if (isDarwin) {
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
      "cmake -DCMAKE_C_COMPILER=$cc -DCMAKE_CXX_COMPILER=$cxx -DCMAKE_AR=$ar -DCMAKE_LINKER=$ld -DCMAKE_RANLIB=$ranlib -DCMAKE_SYSTEM_NAME=Linux -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DCMAKE_INSTALL_PREFIX=./installed ..",
      dir: "brotli/out",
    );
  } else if (isDarwin) {
    await run(
      "cmake -DCMAKE_C_COMPILER=$cc -DCMAKE_OSX_SYSROOT=$darwinSDK -DCMAKE_OSX_ARCHITECTURES=$arch -DCMAKE_SYSTEM_NAME=Darwin -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DCMAKE_INSTALL_PREFIX=./installed ..",
      dir: "brotli/out",
      env: getDarwinEnv(),
    );
  }
}
