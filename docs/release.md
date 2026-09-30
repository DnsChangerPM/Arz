# Release

Run the `Build and release` workflow manually with `APP_VERSION` in strict `major.minor.patch` form, or push a `vX.Y.Z` tag. CI calculates Android versionCode as `major*1,000,000 + minor*1,000 + patch`, runs formatting/analyze/tests, signs APK, builds Windows and Inno Setup installer, verifies artifacts, creates a non-duplicate tag/release, and uploads checksums.

Required repository secrets: `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`. Encode the JKS as single-line base64. Never commit it or `android/key.properties`. Windows Authenticode signing is not configured because no certificate was supplied; add certificate-backed signing before public distribution.
