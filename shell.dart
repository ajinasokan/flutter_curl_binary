part of 'main.dart';

Future<void> handleCommand(
    List<Future<void> Function()> cmds, List<String> args) async {
  print(args);
  for (var arg in args) {
    bool ran = false;
    for (var cmd in cmds) {
      if (cmd.toString().contains("'$arg'")) {
        await cmd();
        ran = true;
        break;
      }
    }
    if (!ran) {
      print("command $arg not found");
    }
  }
}

Future<void> run(String exec, {Map<String, String>? env, String? dir}) async {
  print(exec);
  final proc = await Process.start(
    "sh",
    ["-c", exec],
    environment: env,
    workingDirectory: dir,
  );
  final out = stdout.addStream(proc.stdout);
  final err = stderr.addStream(proc.stderr);
  if (await proc.exitCode != 0) {
    await out;
    await err;
    print("\nCommand exited with non-zero exit code");
    exit(1);
  }
}

bool dirExists(String path) {
  return Directory(path).existsSync();
}

String abs(String path) {
  return Directory(path).absolute.path;
}
