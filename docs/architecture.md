# Toman Rates architecture

## Runtime composition

The application is one feature-first Flutter codebase with native platform shells. Dependencies point inward:

```text
Flutter widgets
  -> RatesController (StateNotifier)
  -> ExchangeRateRepository interface
  -> ExchangeRateRepositoryImpl
       -> ExchangeRateRemoteDataSource
       -> JsonStore (SharedPreferences)
       -> WidgetBridge (Android MethodChannel)
```

`main.dart` creates dependencies and performs stale-while-revalidate startup: open preferences, start UI from cache, asynchronously check minimum version and refresh rates. The UI never calls HTTP or platform APIs directly.

## Exchange rates

`TomanifyRemoteDataSource` is the current replaceable provider adapter. Tomanify's documented feed directly represents Iranian free-market reference values in **toman** and updates about 3–4 times daily. No IRR conversion is applied. A future IRR adapter must use `toman = rial / 10` exactly once before returning domain models.

USD and EUR are mandatory. AED, TRY and CNY are used when valid. Since Tomanify does not currently publish GBP, GBP can be calculated from the provider's free-market USD/Toman anchor and ExchangeRate-API's USD/GBP cross-rate; `CurrencyRate.isDerived` makes the UI disclose this. Failure of the cross feed omits GBP rather than invalidating direct rates.

Dio enforces connection/send/receive timeouts. `HttpClient` maps timeout, connectivity, authorization, rate-limit, server and malformed response failures into typed errors and performs three bounded attempts with exponential delay. The adapter checks shape, source date, required currencies, positivity and a defensive upper bound.

## Cache

`JsonStore` uses `SharedPreferences` because only one small atomic snapshot and a few settings are needed; a database would add needless migration and native complexity. The snapshot includes schema, rates, derived marker, source/fetch timestamps, provider and rate type. Invalid/unknown cache schemas are ignored. A successful remote response is persisted before Android widget notification. Cached state is explicitly marked in UI.

## Flutter UI

Material 3 light/dark themes are centralized in `AppTheme`. Persian is the initial RTL locale while ISO codes remain LTR. The rate grid uses sliver constraints rather than fixed screen sizes and changes column count naturally on Android and resizable Windows windows. It includes skeletons, no-cache error/retry, cached status, timestamp, source/type attribution, pull-to-refresh, toolbar refresh and accessible semantic card labels.

`RatesController` owns startup refresh, a configurable 15-minute foreground timer, deduplication and errors. It disposes its timer. Settings currently include theme, effective refresh interval, data source and package/about information.

## Android

Minimum SDK is 24. `MainActivity` exposes only `updateWidget` and `scheduleDaily` through a method channel. `RateWidgetProvider` reads private native SharedPreferences and renders USD, EUR and update time with `RemoteViews`; before cache it shows a waiting message. It does not require Flutter Activity to be running.

`RateRefreshWorker` is a native Kotlin/OkHttp WorkManager worker. It validates USD/EUR, persists and redraws independently. Unique periodic work has a network constraint, retry/backoff and initial delay until next local 09:00. WorkManager is intentionally best-effort under Doze. Every foreground success also updates the widget.

## Windows

The normal Flutter window has minimum/initial constraints suitable for a compact panel and responsive content. `tray_manager` provides Open, Refresh and Exit; `window_manager` controls the desktop window. Inno Setup installs the complete Flutter Release directory, shortcuts and uninstall metadata. Its opt-in per-user Task Scheduler entry launches `background_refresh.cmd` around 09:00. The `--background-refresh` startup path fetches/persists without creating a window and returns a process status.

The selected current Flutter toolchain supports Windows 10/11 x64, not Windows 7. No Windows 7 support is claimed.

## Forced update

`VersionRepository` loads a validated HTTPS JSON policy and falls back to the last valid cache. Versions use numeric semantic comparison. HTTPS download URL is required. The official Telegram update channel is `https://t.me/WidgetArz`; a valid remote policy can override it. Malformed or first-run unavailable policy does not lock users out. When installed version is below minimum, the app root becomes a `PopScope(canPop: false)` full-screen update view. It offers an external URL and clipboard fallback and does not instantiate normal navigation.

## Configuration and security

Endpoints, interval, provider labels and supported codes are centralized in `AppConfig` and can be overridden with compile-time `--dart-define`. No secret is present in source. Android rejects cleartext traffic. CI reconstructs signing files in runner temporary storage from GitHub secrets. Logs do not print response headers or credentials.

## Verification strategy

Offline tests cover SemVer ordering, URL/policy validation, number formatting, cache serialization, documented IRR/Toman arithmetic, primary payload parsing, missing required currencies and forced-update decisions. Remote tests use a custom Dio adapter and never access the internet. CI runs formatting, analyzer and tests before either platform release build.
