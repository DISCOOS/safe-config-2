import 'dart:io';
import 'dart:mirrors';

import 'package:runtime_2/runtime_2.dart';

import 'configuration.dart';
import 'runtime.dart';

class ConfigurationCompiler extends Compiler {
  @override
  Map<String, dynamic> compile(MirrorContext context) {
    return Map.fromEntries(context.getSubclassesOf(Configuration).map((c) {
      return MapEntry(MirrorSystem.getName(c.simpleName), ConfigurationRuntimeImpl(c));
    }));
  }

  @override
  void deflectPackage(Directory destinationDirectory) {
    final libFile = File.fromUri(destinationDirectory.uri.resolve("lib/").resolve("safe_config_2.dart"));
    final contents = libFile.readAsStringSync();
    libFile.writeAsStringSync(contents.replaceFirst("export 'src/compiler.dart';", ""));
  }
}
