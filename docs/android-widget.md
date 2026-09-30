# Android widget

`RateWidgetProvider.kt` is a native `AppWidgetProvider` using `RemoteViews`. Flutter writes validated USD/EUR values over `com.tomanrates.app/widget`; Kotlin saves a minimal snapshot in private SharedPreferences and redraws all instances. The provider renders an honest waiting message before any snapshot exists.

`RateRefreshWorker.kt` independently fetches and validates the same Toman feed with OkHttp. A unique periodic WorkManager request has a connected-network constraint, exponential retry, and initial delay to the next local 09:00. Android Doze may delay execution. It is intentionally not advertised as exact. Main-app refreshes also redraw the widget. API 24 is the minimum.
