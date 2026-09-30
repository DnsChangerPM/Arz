import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toman_rates/core/network/http_client.dart';
import 'package:toman_rates/features/exchange_rates/data/exchange_rate_remote_data_source.dart';

class Adapter implements HttpClientAdapter {
  Adapter(this.data);
  final dynamic data;
  @override
  Future<ResponseBody> fetch(
    RequestOptions o,
    Stream<List<int>>? s,
    Future<void>? c,
  ) async =>
      ResponseBody.fromString(
        data,
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      );
  @override
  void close({bool force = false}) {}
}

void main() {
  test('parses documented Toman feed without multiplying by ten', () async {
    final dio = Dio()
      ..httpClientAdapter = Adapter(
        '{"generated_by_tomanify_at":"2026-09-30","values":{"USD":253700,"EUR":287500,"AED":69109,"TRY":5267,"CNY":37850}}',
      );
    final result = await TomanifyRemoteDataSource(HttpClient(dio: dio)).fetch();
    expect(result.rates.firstWhere((r) => r.code == 'USD').toman, 253700);
    expect(result.rateType, contains('بازار آزاد'));
  });
  test('rejects missing required currency', () async {
    final dio = Dio()
      ..httpClientAdapter = Adapter(
        '{"generated_by_tomanify_at":"2026-09-30","values":{"USD":1}}',
      );
    expect(
      () => TomanifyRemoteDataSource(HttpClient(dio: dio)).fetch(),
      throwsException,
    );
  });
}
