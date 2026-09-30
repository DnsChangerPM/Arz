import 'package:flutter_test/flutter_test.dart';
import 'package:toman_rates/core/utils/semver.dart';

void main() {
  test('semantic numeric comparison is correct', () {
    expect(
      SemanticVersion.parse('1.9.0').compareTo(SemanticVersion.parse('1.10.0')),
      lessThan(0),
    );
    expect(
      SemanticVersion.parse(
        '2.0.0-beta',
      ).compareTo(SemanticVersion.parse('2.0.0')),
      lessThan(0),
    );
  });
  test('invalid versions rejected', () {
    expect(() => SemanticVersion.parse('1.2'), throwsFormatException);
  });
}
