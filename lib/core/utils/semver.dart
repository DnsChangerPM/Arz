class SemanticVersion implements Comparable<SemanticVersion> {
  const SemanticVersion(this.major, this.minor, this.patch, {this.preRelease});
  final int major, minor, patch;
  final String? preRelease;
  static SemanticVersion parse(String value) {
    final m = RegExp(
      r'^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-([0-9A-Za-z.-]+))?(?:\+[0-9A-Za-z.-]+)?$',
    ).firstMatch(value);
    if (m == null) throw FormatException('Invalid semantic version: $value');
    return SemanticVersion(
      int.parse(m[1]!),
      int.parse(m[2]!),
      int.parse(m[3]!),
      preRelease: m[4],
    );
  }

  @override
  int compareTo(SemanticVersion o) {
    for (final v in [(major, o.major), (minor, o.minor), (patch, o.patch)]) {
      final c = v.$1.compareTo(v.$2);
      if (c != 0) return c;
    }
    if (preRelease == null && o.preRelease != null) return 1;
    if (preRelease != null && o.preRelease == null) return -1;
    return (preRelease ?? '').compareTo(o.preRelease ?? '');
  }

  @override
  String toString() =>
      '$major.$minor.$patch${preRelease == null ? '' : '-$preRelease'}';
}
