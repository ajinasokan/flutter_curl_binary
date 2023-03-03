part of 'main.dart';

Future<void> configCares() async {
  await run(
    "rm -rf build && mkdir build",
    dir: "c-ares",
  );
  await run("autoreconf -i", dir: "c-ares");
  await run(
    isAndroid
        ? "./configure --host=$hostTripple --disable-shared --prefix=${abs("c-ares/build")}"
        : "./configure --host=$hostTripple --build=$buildTripple --prefix=${abs("c-ares/build")} ",
    dir: "c-ares",
    env: isAndroid ? getAndroidEnv() : getDarwinEnv(),
  );
}

Future<void> buildCares() async {
  await run(
    "make -j $nproc clean install",
    dir: "c-ares",
    env: isAndroid ? getAndroidEnv() : getDarwinEnv(),
  );
  if (isDarwin) {
    await run(
        "cp c-ares/build/lib/libcares.a $buildDir/libcares_${arch}_${platform.value}.a");
  }
}
