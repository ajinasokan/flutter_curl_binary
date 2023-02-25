part of 'main.dart';

Future<void> allAndroid() async {
  await configAndroidARM();
  await collectPaths();
  await buildAndroid();

  await configAndroidARM64();
  await collectPaths();
  await buildAndroid();

  await configAndroidx86();
  await collectPaths();
  await buildAndroid();

  await packAAR();
}

Future<void> buildAndroid() async {
  await configBrotli();
  await buildBrotli();

  await configNghttp2();
  await buildNghttp2();

  await buildQuiche();

  await configCurl();
  await buildCurl();
}

Future<void> packAAR() async {
  File("build/android/AndroidManifest.xml")
      .writeAsStringSync("""<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.ajinasokan.flutter_libcurl_jni"
    android:versionCode="1"
    android:versionName="0.0.1" >
    <uses-sdk
        android:minSdkVersion="16"
        android:targetSdkVersion="21" />
</manifest>""");
  await run(
    "rm -f Curl.aar\n"
    "zip -r Curl.aar AndroidManifest.xml jni",
    dir: "build/android",
  );
}
