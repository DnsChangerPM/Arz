class AppConfig {
  const AppConfig._();
  static const appName = 'نرخ تومان';
  static const providerName = 'Tomanify';
  static const providerType = 'نرخ مرجع بازار آزاد';
  static const ratesUrl = String.fromEnvironment('RATES_URL', defaultValue: 'https://raw.githubusercontent.com/rate-json/default/main/data.json');
  static const crossRatesUrl = String.fromEnvironment('CROSS_RATES_URL', defaultValue: 'https://open.er-api.com/v6/latest/USD');
  static const versionUrl = String.fromEnvironment('VERSION_URL', defaultValue: 'https://raw.githubusercontent.com/DnsChangerPM/Arz/main/config/version.json');
  static const fallbackTelegramUrl = String.fromEnvironment('TELEGRAM_URL', defaultValue: 'https://t.me/WidgetArz');
  static const refreshMinutes = int.fromEnvironment('REFRESH_MINUTES', defaultValue: 15);
  static const staleHours = 12;
  static const supportedCurrencies = ['USD', 'EUR', 'GBP', 'AED', 'TRY', 'CNY'];
}
