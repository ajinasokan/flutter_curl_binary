part of 'main.dart';

// exclude qlog-dancer from workspace since it depends on a private repo
// and patch build.rs for correct cmake target for boringssl simulators
Future<void> patchQuiche() async {
  // exclude qlog-dancer from workspace
  File("quiche/Cargo.toml").writeAsStringSync(
    File("quiche/Cargo.toml").readAsStringSync().replaceAll(
      '  "qlog-dancer",\n',
      '',
    ).replaceAll(
      'exclude = ["fuzz", "tools/http3_test"]',
      'exclude = ["fuzz", "tools/http3_test", "qlog-dancer"]',
    ),
  );
  File("quiche/quiche/src/build.rs").writeAsStringSync(
    File("quiche/quiche/src/build.rs").readAsStringSync().replaceAll(
      """// Hack for Xcode 10.1.
            let target_cflag = if arch == "x86_64" {
                "-target x86_64-apple-ios-simulator"
            } else {
                ""
            };""",
      """// Hack for Xcode 10.1.
            let target_cflag = if target == "aarch64-apple-ios-sim" {
                "-target aarch64-apple-ios-simulator"
            } else if target == "x86_64-apple-ios" {
                "-target x86_64-apple-ios-simulator"
            } else {
                ""
            };""",
    ).replaceAll("""let arch = std::env::var("CARGO_CFG_TARGET_ARCH").unwrap();
    let os = std::env::var("CARGO_CFG_TARGET_OS").unwrap();""",
        """let arch = std::env::var("CARGO_CFG_TARGET_ARCH").unwrap();
    let target = std::env::var("TARGET").unwrap();
    let os = std::env::var("CARGO_CFG_TARGET_OS").unwrap();"""),
  );
}

// dart ffi doesn't work nicely with varargs in C. so adding these additional
// helper functions to get explicit function params.
Future<void> patchCurl() async {
  File("curl/lib/setopt.c").writeAsStringSync(
    File("curl/lib/setopt.c").readAsStringSync() +
        """
// EXTRAS FOR LIBCURL
CURL_EXTERN CURLcode curl_easy_setopt_string(struct Curl_easy *data, CURLoption tag, char* val)
{
  return curl_easy_setopt(data, tag, val);
}

CURL_EXTERN CURLcode curl_easy_setopt_int(struct Curl_easy *data, CURLoption tag, int val)
{
  return curl_easy_setopt(data, tag, val);
}

CURL_EXTERN CURLcode curl_easy_setopt_ptr(struct Curl_easy *data, CURLoption tag, void* val)
{
  return curl_easy_setopt(data, tag, val);
}

CURL_EXTERN CURLcode curl_easy_getinfo_long(CURL *curl, CURLINFO info, long* val)
{
  return curl_easy_getinfo(curl, info, val);
}
""",
  );
}
