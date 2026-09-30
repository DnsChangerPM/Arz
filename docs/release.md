# Release

Run the `Build and release` workflow manually with `APP_VERSION` in strict `major.minor.patch` form, or push a `vX.Y.Z` tag. CI calculates Android versionCode as `major*1,000,000 + minor*1,000 + patch`, runs formatting/analyze/tests, signs APK, builds Windows and Inno Setup installer, verifies artifacts, creates a non-duplicate tag/release, and uploads checksums.

Android signing secrets: `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`. Encode the JKS as base64. Never commit it or `android/key.properties`.

Set all four to ship a properly signed APK. If any of them is missing the workflow no longer fails: it logs a warning, Gradle falls back to the Android debug key (see the `signingConfig` fallback in `android/app/build.gradle`), and the release notes are annotated. A debug-signed APK installs for testing but cannot be updated over a release-signed install and must not be distributed to users.

Windows Authenticode signing is not configured because no certificate was supplied; add certificate-backed signing before public distribution.
