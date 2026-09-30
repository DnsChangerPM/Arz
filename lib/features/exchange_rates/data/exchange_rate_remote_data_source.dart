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

    Object? lastError;
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
    throw lastError ??
        const AppException(AppErrorKind.server, 'All rate providers failed');
  }
}
