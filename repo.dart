part of 'main.dart';

// Dependency version tags — used by cloneRepos() and uploadRelease()
const String cAresTag = "v1.34.6";
const String nghttp2Tag = "v1.69.0";
const String quicheTag = "0.26.1";
const String brotliTag = "v1.2.0";
const String curlTag = "curl-8_20_0";

Future<void> cloneRepos() async {
  await clone(
    dir: "c-ares",
    repo: "https://github.com/c-ares/c-ares",
    tag: cAresTag,
  );
  await clone(
    dir: "nghttp2",
    repo: "https://github.com/nghttp2/nghttp2",
    tag: nghttp2Tag,
  );
  await clone(
    dir: "quiche",
    repo: "https://github.com/cloudflare/quiche",
    tag: quicheTag,
    submodules: true,
  );
  await clone(
    dir: "brotli",
    repo: "https://github.com/google/brotli",
    tag: brotliTag,
  );
  await clone(
    dir: "curl",
    repo: "https://github.com/curl/curl",
    tag: curlTag,
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

/// Uploads all build artifacts as a GitHub release.
Future<void> uploadRelease() async {
  // Get the latest git tag from this repo
  final tag = runCapture("git tag | sort -V | tail -1");
  print("Uploading release for tag: $tag");

  // Check if a release with this tag already exists
  final existingRelease = runCapture(
    "gh release view $tag --json tagName --jq '.tagName' 2>/dev/null || echo ''",
  );
  if (existingRelease.isNotEmpty) {
    print("Release '$tag' already exists.");
    stdout.write("Overwrite? (y/N): ");
    final answer = stdin.readLineSync();
    if ((answer ?? "").toLowerCase() != "y") {
      print("Aborted.");
      return;
    }
    // Delete the existing release and its assets
    await run("gh release delete $tag --cleanup-tag --yes");
  }

  // Create the release with the dependency versions in the body
  final body = "c-ares: $cAresTag\n"
      "nghttp2: $nghttp2Tag\n"
      "quiche: $quicheTag\n"
      "brotli: $brotliTag\n"
      "curl: $curlTag\n"
      "\n"
      "NDK: $ndkVersion\n"
      "Min iOS: 8.0\n"
      "Min macOS: 10.12";

  await run(
    "gh release create $tag "
    "--title 'flutter_curl v$tag' "
    "--notes '$body'",
  );

  // Collect and upload assets
  final List<String> assets = [
    "build/android/Curl.aar",
    "build/ios/Curl.xcframework.zip",
    "build/macos/Curl.framework.zip",
    ...Directory("build/ios")
        .listSync()
        .whereType<File>()
        .where((f) => f.path.contains(".artifactbundle.zip"))
        .map((f) => f.path),
    ...Directory("build/macos")
        .listSync()
        .whereType<File>()
        .where((f) => f.path.contains(".artifactbundle.zip"))
        .map((f) => f.path),
  ];

  for (final asset in assets) {
    if (File(asset).existsSync()) {
      print("Uploading: $asset");
      await run("gh release upload $tag $asset --clobber");
    } else {
      print("WARNING: asset not found: $asset");
    }
  }

  print("Release $tag uploaded successfully.");
}
