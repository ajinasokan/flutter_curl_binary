part of 'main.dart';

Future<void> nghttp2() async {
  await configNghttp2();
  await buildNghttp2();
}

Future<void> buildNghttp2() async {
  await run(
    "make clean install",
    dir: "nghttp2",
  );
  if (isDarwin) {
    await run(
        "cp nghttp2/build/lib/libnghttp2.a build/ios/libnghttp2_${arch}_${platform.value}.a");
  }
}

Future<void> configNghttp2() async {
  await run("rm -rf build && mkdir build", dir: "nghttp2");
  await run("autoreconf -i", dir: "nghttp2");
  await run(
    isAndroid
        ? "./configure --host=$tripple --disable-shared --without-systemd --without-jemalloc --prefix=${abs("nghttp2/build")} --enable-lib-only"
        : "./configure --disable-shared --disable-app --disable-threads --enable-lib-only  --prefix=${abs("nghttp2/build")} --host=$tripple",
    dir: "nghttp2",
    env: isAndroid ? getAndroidEnv() : getiOSEnv(),
  );
}
