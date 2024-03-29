import 'dart:io';

part 'shell.dart';
part 'env.dart';
part 'repo.dart';
part 'android.dart';
part 'ios.dart';
part 'macos.dart';
part 'brotli.dart';
part 'c-ares.dart';
part 'nghttp2.dart';
part 'quiche.dart';
part 'curl.dart';
part 'patch.dart';

void main(List<String> args) async {
  await handleCommand([
    clean,
    setupDirs,
    cloneRepos,
    patchQuiche,
    patchCurl,
    configAndroidARM,
    configAndroidARM64,
    configAndroidx86,
    configiPhoneARM64,
    configiPhoneSimulatorARM64,
    configiPhoneSimulatorx86,
    configmacOSARM64,
    configmacOSx86,
    collectPaths,
    buildAndroid,
    buildiOS,
    buildmacOS,
    brotli,
    configBrotli,
    buildBrotli,
    nghttp2,
    configNghttp2,
    buildNghttp2,
    buildQuiche,
    curl,
    configCurl,
    buildCurl,
    combineStaticLibs,
    stripiOSBinary,
    packFramework,
    zipFramework,
    packAAR,
    alliOS,
    allAndroid,
    allmacOS,
    configCares,
    buildCares,
    combinemacOSStaticLibs,
  ], args);
}
