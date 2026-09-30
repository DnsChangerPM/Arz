import 'dart:async';
import 'package:dio/dio.dart';
import '../errors/app_exception.dart';

class HttpClient {
  HttpClient({Dio? dio}) : _dio = dio ?? Dio(BaseOptions(connectTimeout: const Duration(seconds: 8), receiveTimeout: const Duration(seconds: 10), sendTimeout: const Duration(seconds: 8), headers: {'Accept':'application/json','User-Agent':'TomanRates/1'}));
  final Dio _dio;
  Future<dynamic> getJson(String url, {int attempts = 3}) async {
    Object? last;
    for (var i=0; i<attempts; i++) {
      try {
        final response = await _dio.get<dynamic>(url);
        if (response.statusCode == 200) return response.data;
        throw _fromStatus(response.statusCode ?? 0, response.headers.value('retry-after'));
      } on DioException catch (e) {
        last = _fromDio(e);
        if (last is AppException && (last.kind == AppErrorKind.unauthorized || last.kind == AppErrorKind.invalidData)) rethrow;
      } on FormatException catch (e) { throw AppException(AppErrorKind.invalidData, e.message); }
      if (i + 1 < attempts) await Future<void>.delayed(Duration(milliseconds: 350 * (1 << i)));
    }
    throw last is AppException ? last : const AppException(AppErrorKind.unknown, 'Request failed');
  }
  AppException _fromDio(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout || e.type == DioExceptionType.sendTimeout) return const AppException(AppErrorKind.timeout, 'timeout');
    if (e.response != null) return _fromStatus(e.response!.statusCode ?? 0, e.response!.headers.value('retry-after'));
    return AppException(AppErrorKind.offline, e.type.name);
  }
  AppException _fromStatus(int status, String? retry) {
    if (status == 401 || status == 403) return AppException(AppErrorKind.unauthorized, 'HTTP $status');
    if (status == 429) return AppException(AppErrorKind.rateLimited, 'HTTP 429', retryAfter: Duration(seconds: int.tryParse(retry ?? '') ?? 60));
    if (status >= 500) return AppException(AppErrorKind.server, 'HTTP $status');
    return AppException(AppErrorKind.invalidData, 'HTTP $status');
  }
}
