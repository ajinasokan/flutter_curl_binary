part of 'main.dart';

Future<void> cloneRepos() async {
  await clone(
    dir: "c-ares",
    repo: "https://github.com/c-ares/c-ares",
    tag: "cares-1_19_0",
  );
  await clone(
    dir: "nghttp2",
    repo: "https://github.com/nghttp2/nghttp2",
    tag: "v1.52.0",
  );
  await clone(
    dir: "quiche",
    repo: "https://github.com/cloudflare/quiche",
    tag: "0.16.0",
    submodules: true,
  );
  await clone(
    dir: "brotli",
    repo: "https://github.com/google/brotli",
    tag: "v1.0.9",
  );
  await clone(
    dir: "curl",
    repo: "https://github.com/curl/curl",
    tag: "curl-7_88_1",
  );
}

Future<void> setupDirs() async {
  await run(
    "rm -rf build\n"
    "mkdir -p build/android/jni/armeabi-v7a build/android/jni/arm64-v8a build/android/jni/x86_64 build/ios build/macos",
  );
}

Future<void> clean() async {
  await run("rm -rf brotli c-ares curl nghttp2 quiche build");
}

Future<void> clone({
  required String dir,
  required String repo,
  required String tag,
  bool submodules = false,
}) async {
  if (dirExists(dir)) {
    await run("rm -rf $dir");
  }
  await run("git clone $repo --depth 1 --branch $tag $dir");
  if (submodules) {
    await run("git submodule update --init --depth 1", dir: dir);
  }
  await run("rm -rf $dir/.git");
}
