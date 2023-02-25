part of 'main.dart';

Future<void> curl() async {
  await configCurl();
  await buildCurl();
}

Future<void> buildCurl() async {
  await run(
    "make clean\n"
    "make -j $nproc install",
    dir: "curl",
  );
  if (isAndroid) {
    await run(
      "$strip build/lib/libcurl.so",
      dir: "curl",
    );
    await run(
        "cp curl/build/lib/libcurl.so build/android/jni/$androidArch/libcurl.so");
  } else if (isDarwin) {
    await run(
      "cp curl/build/lib/libcurl.a build/ios/libcurl_${arch}_${platform.value}.a",
    );
  }
}

Future<void> configCurl() async {
  if (isAndroid) {
    await run(
      "autoreconf -i",
      dir: "curl",
      env: getAndroidEnv(),
    );
    await run(
      "./configure LDFLAGS=\"-lm\" --host=$tripple --prefix=\$(PWD)/build "
      "--disable-debug "
      "--disable-dependency-tracking "
      "--disable-silent-rules "
      "--disable-ldap "
      "--disable-ldaps "
      "--disable-imap "
      "--disable-gopher "
      "--disable-ftp "
      "--disable-dict "
      "--disable-rtsp "
      "--disable-smtp "
      "--disable-telnet "
      "--disable-tftp "
      "--disable-unix-sockets "
      "--without-librtmp "
      "--disable-manual "
      "--enable-optimize "
      "--without-secure-transport "
      "--without-ca-bundle "
      "--without-ca-path "
      "--with-ca-path=/system/etc/security/cacerts "
      "--with-brotli=${abs("brotli")}/out/installed "
      "--with-nghttp2=${abs("nghttp2")}/build "
      "--with-ssl=${abs("quiche")}/deps/boringssl "
      "--with-quiche=${abs("quiche")}/target/$rustTripple/release "
      "--enable-alt-sv",
      dir: "curl",
      env: getAndroidEnv(),
    );
  } else {
    await run(
      "autoreconf -i",
      dir: "curl",
      env: getiOSEnv(),
    );
    await run(
      "./configure LDFLAGS=\"-framework Security -framework CoreFoundation\" --host=$tripple --prefix=\$(PWD)/build "
      "--disable-debug "
      "--disable-dependency-tracking "
      "--disable-silent-rules "
      "--disable-ldap "
      "--disable-ldaps "
      "--disable-imap "
      "--disable-gopher "
      "--disable-ftp "
      "--disable-dict "
      "--disable-rtsp "
      "--disable-smtp "
      "--disable-telnet "
      "--disable-tftp "
      "--disable-unix-sockets "
      "--without-librtmp "
      "--disable-manual "
      "--enable-optimize "
      "--without-secure-transport "
      "--with-brotli=${abs("brotli")}/out/installed "
      "--with-nghttp2=${abs("nghttp2")}/build "
      "--with-ssl=${abs("quiche")}/deps/boringssl "
      "--with-quiche=${abs("quiche")}/target/$cctripple/release "
      "--enable-alt-svc",
      dir: "curl",
      env: getiOSEnv(),
    );
  }
}
