import '../../../core/config/app_config.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/network/http_client.dart';
import '../domain/models.dart';

abstract interface class ExchangeRateRemoteDataSource {
  Future<RateSnapshot> fetch();
}

class TomanifyRemoteDataSource implements ExchangeRateRemoteDataSource {
  TomanifyRemoteDataSource(this._http);
  final HttpClient _http;
  @override
  Future<RateSnapshot> fetch() async {
    final raw = await _fetchFeed();
    if (raw is! Map) {
      throw const AppException(AppErrorKind.invalidData, 'Root is not object');
    }
    final json = Map<String, dynamic>.from(raw);
    final values = json['values'];
    if (values is! Map) {
      throw const AppException(AppErrorKind.invalidData, 'Missing values');
    }
    final map = Map<String, dynamic>.from(values);
    final rates = <CurrencyRate>[];
    for (final code in AppConfig.supportedCurrencies) {
      final value = map[code];
      if (value is num && value > 0 && value < 1000000000) {
        rates.add(CurrencyRate(code: code, toman: value, isDerived: false));
      }
    }
    // Tomanify currently has no GBP. Derive it from the free-market USD anchor and
    // an international USD/GBP cross-rate; this is explicitly marked derived.
    if (!rates.any((e) => e.code == 'GBP') && map['USD'] is num) {
      try {
        final cross = await _http.getJson(AppConfig.crossRatesUrl, attempts: 1);
        if (cross is Map && cross['rates'] is Map) {
          final gbp = (cross['rates'] as Map)['GBP'];
          if (gbp is num && gbp > 0) {
            rates.add(
              CurrencyRate(
                code: 'GBP',
                toman: (map['USD'] as num) / gbp,
                isDerived: true,
              ),
            );
          }
        }
      } catch (_) {
        /* GBP is optional when cross feed is unavailable. */
      }
    }
    if (!rates.any((e) => e.code == 'USD') ||
        !rates.any((e) => e.code == 'EUR')) {
      throw const AppException(
        AppErrorKind.invalidData,
        'Required currencies missing',
      );
    }
    // Older mirrors did not include a source timestamp. The rates are still
    // valid when the required values pass validation, so use fetch time rather
    // than showing a false empty state.
    final fetchedAt = DateTime.now().toUtc();
    final date = DateTime.tryParse(
      json['generated_by_tomanify_at']?.toString() ?? '',
    );
    return RateSnapshot(
      rates: rates,
      fetchedAt: fetchedAt,
      sourceDate: (date ?? fetchedAt).toUtc(),
      provider: AppConfig.providerName,
      rateType: AppConfig.providerType,
    );
  }

  Future<dynamic> _fetchFeed() async {
    // A custom endpoint must remain authoritative: falling back from it could
    // silently show a different market. For the built-in provider, try three
    // equivalent hosts because access to GitHub raw/CDN varies by ISP.
    final builtIn = AppConfig.ratesUrl ==
        'https://raw.githubusercontent.com/rate-json/default/main/data.json';
    if (!builtIn) return _http.getJson(AppConfig.ratesUrl);

    // Seeded so the throw below always has a typed error to report, even if the
    // candidate list is ever emptied; each failed attempt overwrites it.
    Object lastError = const AppException(
      AppErrorKind.server,
      'All rate providers failed',
    );
    for (final url in <String>[
      AppConfig.ratesUrl,
      AppConfig.fallbackRatesUrl,
      AppConfig.mirrorRatesUrl,
    ]) {
      try {
        return await _http.getJson(url);
      } catch (error) {
        lastError = error;
      }
    }
    // Preserve the original typed AppException so the controller can keep its
    // normal offline/cached-data behaviour.
    try {
      return _fromTgju(await _http.getJson(AppConfig.liveFallbackRatesUrl));
    } catch (error) {
      lastError = error;
    }
    throw lastError;
  }

  /// TGJU publishes its own board JSON in rial. Keep this adapter defensive:
  /// the board has changed shape in the past and values may be comma-formatted.
  Map<String, dynamic> _fromTgju(dynamic raw) {
    if (raw is! Map) throw const FormatException('TGJU root');
    final values = <String, dynamic>{};
    const keys = <String, List<String>>{
      'USD': ['price_dollar_rl', 'price_dollar', 'usd'],
      'EUR': ['price_eur', 'price_euro', 'eur'],
      'GBP': ['price_gbp', 'price_pound', 'gbp'],
      'AED': ['price_aed', 'price_dirham', 'aed'],
      'TRY': ['price_try', 'price_lira', 'try'],
      'CNY': ['price_cny', 'price_yuan', 'cny'],
    };
    dynamic find(dynamic node, String key) {
      if (node is Map) {
        for (final entry in node.entries) {
          if (entry.key.toString().toLowerCase() == key.toLowerCase()) {
            final value = entry.value;
            if (value is Map) {
              for (final name in ['p', 'price', 'value', 'v']) {
                if (value[name] != null) return value[name];
              }
            }
            return value;
          }
          final result = find(entry.value, key);
          if (result != null) return result;
        }
      } else if (node is List) {
        for (final item in node) {
          final result = find(item, key);
          if (result != null) return result;
        }
      }
      return null;
    }

    for (final entry in keys.entries) {
      final value = find(
          raw,
          entry.value.firstWhere(
            (key) => find(raw, key) != null,
            orElse: () => '',
          ));
      final number = num.tryParse(value?.toString().replaceAll(',', '') ?? '');
      if (number != null && number > 0) values[entry.key] = number / 10;
    }
    if (values['USD'] == null || values['EUR'] == null) {
      throw const FormatException('TGJU required rates missing');
    }
    return {
      'values': values,
      'generated_by_tomanify_at': DateTime.now().toUtc().toIso8601String(),
    };
  }
}
