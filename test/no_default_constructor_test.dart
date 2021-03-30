import 'package:runtime_2/runtime_2.dart';
import 'package:safe_config_2/safe_config_2.dart';
import 'package:test/test.dart';

void main() {
  test("Nested configuration without unnamed constructor is an error at compile time", () {
    try {
      RuntimeContext.current;
      fail('unreachable');
    } on StateError catch (e) {
      expect(e.toString(), contains("Failed to compile 'BadConfig'"));
    }
  });
}

class ParentConfig extends Configuration {
  BadConfig badConfig;
}

class BadConfig extends Configuration {
  BadConfig.from(this.id);
  String id;
}
