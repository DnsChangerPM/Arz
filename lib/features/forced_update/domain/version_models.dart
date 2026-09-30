import '../../../core/utils/semver.dart';

class VersionConfig {
  const VersionConfig({
    required this.current,
    required this.minimum,
    required this.downloadUrl,
    required this.telegramUrl,
    required this.releaseNotes,
  });
  final SemanticVersion current, minimum;
  final Uri downloadUrl, telegramUrl;
  final String releaseNotes;
  factory VersionConfig.fromJson(Map<String, dynamic> j) {
    final current = SemanticVersion.parse(j['current_version'] as String);
    final minimum = SemanticVersion.parse(
      j['minimum_supported_version'] as String,
    );
    Uri valid(String key, {bool optional = false}) {
      final raw = j[key]?.toString() ?? '';
      final u = Uri.tryParse(raw);
      if (optional && raw.isEmpty) return Uri();
      if (u == null || u.scheme != 'https' || u.host.isEmpty) {
        throw FormatException('Invalid $key');
      }
      return u;
    }

    return VersionConfig(
      current: current,
      minimum: minimum,
      downloadUrl: valid('download_url'),
      telegramUrl: valid('telegram_url', optional: true),
      releaseNotes: j['release_notes']?.toString() ?? '',
    );
  }
  Map<String, dynamic> toJson() => {
        'current_version': current.toString(),
        'minimum_supported_version': minimum.toString(),
        'download_url': downloadUrl.toString(),
        'telegram_url': telegramUrl.toString(),
        'release_notes': releaseNotes,
      };
}

abstract interface class VersionRepository {
  Future<VersionConfig?> check();
}
