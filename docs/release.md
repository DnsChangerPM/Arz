# Release

Run the `Build and release` workflow manually with `APP_VERSION` in strict `major.minor.patch` form, or push a `vX.Y.Z` tag. CI calculates Android versionCode as `major*1,000,000 + minor*1,000 + patch`, runs formatting/analyze/tests, signs APK, builds Windows and Inno Setup installer, verifies artifacts, creates a non-duplicate tag/release, and uploads checksums.

Android signing secrets: `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`. Encode the JKS as base64. Never commit it or `android/key.properties`.

Set all four to ship a properly signed APK. If any of them is missing the workflow no longer fails: it logs a warning, Gradle falls back to the Android debug key (see the `signingConfig` fallback in `android/app/build.gradle`), and the release notes are annotated. A debug-signed APK installs for testing but cannot be updated over a release-signed install and must not be distributed to users.

Windows Authenticode signing is not configured because no certificate was supplied; add certificate-backed signing before public distribution.

## Build toolchain pins

| Piece | Version | Why it is pinned here |
| --- | --- | --- |
| Flutter | 3.35.4 | Matches the Flutter version the project is developed and tested against. |
| Android Gradle Plugin | 8.9.1 (`android/settings.gradle`) | Current AndroidX releases pulled in transitively (`androidx.core:core:1.17.x`, `androidx.browser:browser:1.9.x`) refuse to build below AGP 8.9.1. |
| Gradle | 8.12 (`android/gradle/wrapper/gradle-wrapper.properties`) | AGP 8.9.x requires Gradle 8.11.1+; 8.12 is the wrapper Flutter 3.35 ships. The wrapper properties file is committed so CI cannot silently fall back to an older Gradle. |
| compileSdk / targetSdk | 36 (`android/app/build.gradle`) | `androidx.core:core:1.17` and friends require compiling against Android 16. |
| Java / Kotlin JVM target | 17 | AGP 8.9 and the AndroidX 1.17 line need JDK 17; CI installs Temurin 17. |
| Windows runner | `windows-2022` | GitHub migrated `windows-latest`/`windows-2025` to Visual Studio 2026 (v18). Flutter 3.35 only knows VS 2019/2022, so it silently falls back to the `Visual Studio 16 2019` CMake generator and the build fails with `could not find any instance of Visual Studio`. The Windows job also asserts via `vswhere` that a VS 2022 C++ toolchain is present before building, so a future image change fails fast with a clear message instead of a confusing CMake error. |

When bumping Flutter, re-check this table: AGP, Gradle and the Visual Studio generator all move together.
