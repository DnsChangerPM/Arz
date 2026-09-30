enum AppErrorKind { offline, timeout, unauthorized, rateLimited, server, invalidData, unknown }
class AppException implements Exception {
  const AppException(this.kind, this.message, {this.retryAfter});
  final AppErrorKind kind;
  final String message;
  final Duration? retryAfter;
  String get userMessage => switch (kind) {
    AppErrorKind.offline => 'اتصال اینترنت در دسترس نیست.',
    AppErrorKind.timeout => 'زمان دریافت اطلاعات به پایان رسید.',
    AppErrorKind.rateLimited => 'تعداد درخواست‌ها زیاد است؛ کمی بعد تلاش کنید.',
    AppErrorKind.server => 'سرویس نرخ ارز موقتاً در دسترس نیست.',
    AppErrorKind.invalidData => 'اطلاعات دریافتی معتبر نیست.',
    AppErrorKind.unauthorized => 'دسترسی به سرویس امکان‌پذیر نیست.',
    _ => 'خطایی رخ داد. دوباره تلاش کنید.',
  };
  @override String toString() => 'AppException($kind, $message)';
}
