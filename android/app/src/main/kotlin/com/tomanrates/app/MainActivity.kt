package com.tomanrates.app
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
class MainActivity: FlutterActivity() {
 override fun configureFlutterEngine(engine: FlutterEngine) { super.configureFlutterEngine(engine); MethodChannel(engine.dartExecutor.binaryMessenger,"com.tomanrates.app/widget").setMethodCallHandler { call,result -> when(call.method){
  "updateWidget"->{ val p=getSharedPreferences(RateWidgetProvider.PREFS,Context.MODE_PRIVATE);p.edit().putLong("usd",(call.argument<Number>("usd")?:0).toLong()).putLong("eur",(call.argument<Number>("eur")?:0).toLong()).putLong("updatedAt",(call.argument<Number>("updatedAt")?:0).toLong()).apply();RateWidgetProvider.updateAll(this);result.success(null)}
  "scheduleDaily"->{RateRefreshWorker.schedule(this);result.success(null)} else->result.notImplemented() } } }
}
