import 'dart:async';
import 'dart:io';

import 'package:runtime/runtime.dart';

Future main(List<String> args) async {
  print(Directory("/home/travis/.pub-cache/").listSync(recursive: true).map((f) => f.path).join("\n"));

  final blacklist = ["no_default_constructor_test.dart"];
  final testFiles = Directory.fromUri(Directory.current.uri.resolve("test/"))
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith("_test.dart"))
      .where((f) => blacklist
          .where((blacklisted) => f.uri.path.endsWith(blacklisted))
          .isEmpty)
      .toList();

  var remainingCounter = testFiles.length;
  var passCounter = 0;
  var failCounter = 0;
  for (File f in testFiles) {
    final makePrompt = () =>
        "(Pass: $passCounter Fail: $failCounter Remain: $remainingCounter)";
    print("${makePrompt()} Loading test ${f.path}...");
    final ctx = BuildContext(
        Directory.current.uri.resolve("lib/").resolve("safe_config.dart"),
        Directory.current.uri.resolve("build/"),
        Directory.current.uri.resolve("run"),
        f.readAsStringSync(),
        forTests: true);
    final bm = BuildManager(ctx);
    await bm.build();

    print("${makePrompt()} Running tests derived from ${f.path}...");
    final result = await Process.run("./run", [],
        workingDirectory:
            Directory.current.uri.toFilePath(windows: Platform.isWindows),
        environment: {
          "TEST_BOOL": "true",
          "TEST_DB_ENV_VAR": "postgres://user:password@host:5432/dbname",
          "TEST_VALUE": "1"
        });
    print(result.stdout);
    print(result.stderr);
    if (result.exitCode != 0) {
      exitCode = -1;
      failCounter++;
      print("Tests FAILED in ${f.path}.");
    } else {
      passCounter++;
    }
    print("${makePrompt()} Completed tests derived from ${f.path}.");
    await bm.clean();
    File.fromUri(Directory.current.uri.resolve("run")).deleteSync();
    remainingCounter--;
  }
}
