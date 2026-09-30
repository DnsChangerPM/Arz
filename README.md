# Toman Rates — نرخ تومان

Production-oriented Flutter app for Iranian free-market reference rates on Android and Windows. It renders cached data immediately, validates and refreshes in the background, exposes a native Android widget, and offers a compact responsive Windows/tray experience.

## Features

- USD, EUR, AED, TRY and CNY directly in toman; GBP is clearly marked as a USD-cross derived value.
- Persian RTL Material 3 light/dark UI, responsive cards, skeleton/error/offline states, pull/manual/periodic refresh.
- SharedPreferences JSON cache with schema, source date, fetch time, provider and rate type.
- Dio timeouts, status mapping, bounded exponential retry, schema/range validation and safe stale fallback.
- Native Kotlin Android AppWidget and WorkManager refresh around local 09:00.
- Windows resizable panel, tray actions, Inno Setup installer and opt-in Scheduled Task.
- Validated remote minimum-version policy and non-bypassable update screen.
- Offline unit/widget-ready tests and GitHub Actions release automation.

## Toolchain and support

CI pins Flutter 3.35.4 / its bundled Dart SDK. Android minimum is API 24 (Android 7.0). Modern Flutter supports Windows 10/11 x64; **Windows 7 is not supported**. See [Windows details](docs/windows.md).

## Architecture

Feature-first flow: presentation → controller → repository contract → repository implementation → remote/local source. Riverpod hosts app state; widgets do not call HTTP. Important paths:

```text
lib/core/                         config, networking, cache, errors, theme, utilities
lib/features/exchange_rates/      domain models, provider adapter, repository, controller/UI
lib/features/forced_update/       remote policy, SemVer logic, blocking screen
lib/features/settings/            settings/about UI
lib/services/widget_bridge.dart   Flutter ↔ Android method channel
android/.../RateWidgetProvider.kt native widget
android/.../RateRefreshWorker.kt  independent background fetch
windows/runner/                   standard Flutter desktop runner
installer/toman_rates.iss         installer and scheduled refresh task
```

The detailed design is in [docs/architecture.md](docs/architecture.md); implementation-specific API, widget, Windows and release notes are in `docs/`.

## Data provider and units

The no-key Tomanify public JSON feed is the primary provider. It is a free-market reference snapshot updated roughly 3–4 times daily—not a real-time trading quote. It directly supplies **toman**, so the app performs no rial conversion. The invariant for any future IRR adapter is `1 toman = 10 IRR`, therefore `toman = IRR / 10`. Attribution and commercial-use restrictions are documented in [docs/api.md](docs/api.md).

No production fake values are included. When neither network nor cache is available, an empty state is shown.

## Local development

Install Flutter 3.35.4 and platform prerequisites, then:

```bash
flutter pub get
dart format lib test integration_test
flutter analyze --fatal-infos
flutter test
flutter run -d android
flutter run -d windows
```

Override configuration without source changes:

```bash
flutter run --dart-define=RATES_URL=https://... \
  --dart-define=CROSS_RATES_URL=https://... \
  --dart-define=VERSION_URL=https://... \
  --dart-define=TELEGRAM_URL=https://t.me/your_real_channel \
  --dart-define=REFRESH_MINUTES=15
```

There is intentionally no invented Telegram channel. Set it in the remotely hosted version JSON when known. `config/version.json` is a deployable template; host it at the configured `VERSION_URL` (the default points to this repository's main branch).

## Forced update format

```json
{
  "current_version": "1.2.0",
  "minimum_supported_version": "1.1.0",
  "download_url": "https://github.com/owner/repository/releases/latest",
  "telegram_url": "https://t.me/real_channel",
  "release_notes": "..."
}
```

Versions use numeric SemVer comparison. HTTPS URLs and required fields are validated. A fresh or cached valid policy blocks only when installed is below minimum; first-time server failure does not lock users out. The full-screen gate has no normal navigation escape and provides open/copy fallback.

## Builds and release

```bash
flutter build apk --release --build-name 1.2.0 --build-number 1002000
flutter build windows --release --build-name 1.2.0 --build-number 1002000
iscc /DAppVersion=1.2.0 installer/toman_rates.iss
```

Android local release signing uses untracked `android/key.properties`. CI requires the four Android signing secrets listed in [docs/release.md](docs/release.md). Run `.github/workflows/build-release.yml` with `APP_VERSION`; it validates, tests, signs/builds, packages, checks artifacts, tags and publishes `TomanRates-X.Y.Z-Android.apk` and `TomanRates-X.Y.Z-Windows.exe` with SHA-256 files.

## Known limitations

- The free feed has no SLA, provides snapshots only 3–4 times/day, and commercial distribution requires provider permission.
- WorkManager and Windows Task Scheduler are best effort; sleeping/offline devices cannot guarantee exactly 09:00.
- Windows 7 is outside current Flutter support.
- A Windows Authenticode certificate was not supplied, so CI cannot sign the EXE. Configure certificate-backed signing before public release.
- No Telegram URL is invented; deployment must configure the real channel.
