class CurrencyRate {
  const CurrencyRate({
    required this.code,
    required this.toman,
    required this.isDerived,
  });
  final String code;
  final num toman;
  final bool isDerived;
  Map<String, dynamic> toJson() => {
    'code': code,
    'toman': toman,
    'isDerived': isDerived,
  };
  factory CurrencyRate.fromJson(Map<String, dynamic> j) => CurrencyRate(
    code: j['code'] as String,
    toman: j['toman'] as num,
    isDerived: j['isDerived'] as bool? ?? false,
  );
}

class RateSnapshot {
  const RateSnapshot({
    required this.rates,
    required this.fetchedAt,
    required this.sourceDate,
    required this.provider,
    required this.rateType,
    this.isCached = false,
  });
  final List<CurrencyRate> rates;
  final DateTime fetchedAt;
  final DateTime sourceDate;
  final String provider, rateType;
  final bool isCached;
  RateSnapshot asCached() => RateSnapshot(
    rates: rates,
    fetchedAt: fetchedAt,
    sourceDate: sourceDate,
    provider: provider,
    rateType: rateType,
    isCached: true,
  );
  Map<String, dynamic> toJson() => {
    'schema': 1,
    'rates': rates.map((e) => e.toJson()).toList(),
    'fetchedAt': fetchedAt.toUtc().toIso8601String(),
    'sourceDate': sourceDate.toUtc().toIso8601String(),
    'provider': provider,
    'rateType': rateType,
  };
  factory RateSnapshot.fromJson(Map<String, dynamic> j) {
    if (j['schema'] != 1) {
      throw const FormatException('Unsupported cache schema');
    }
    final rs = j['rates'];
    if (rs is! List) throw const FormatException('rates');
    return RateSnapshot(
      rates: rs
          .map(
            (e) => CurrencyRate.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList(),
      fetchedAt: DateTime.parse(j['fetchedAt'] as String),
      sourceDate: DateTime.parse(j['sourceDate'] as String),
      provider: j['provider'] as String,
      rateType: j['rateType'] as String,
      isCached: true,
    );
  }
}

abstract interface class ExchangeRateRepository {
  Future<RateSnapshot?> cached();
  Future<RateSnapshot> refresh();
}
