package com.tomanrates.app
import android.content.Context
import androidx.work.*
import okhttp3.OkHttpClient
import okhttp3.Request
import org.json.JSONObject
import java.util.Calendar
import java.util.concurrent.TimeUnit
class RateRefreshWorker(c:Context,p:WorkerParameters):Worker(c,p){
 override fun doWork():Result=try{val client=OkHttpClient.Builder().connectTimeout(8,TimeUnit.SECONDS).readTimeout(10,TimeUnit.SECONDS).build();val req=Request.Builder().url("https://raw.githubusercontent.com/rate-json/default/main/data.json").header("Accept","application/json").build();client.newCall(req).execute().use{r->if(r.code==429||r.code>=500)return Result.retry();if(!r.isSuccessful)return Result.failure();val values=JSONObject(r.body?.string()?:return Result.retry()).getJSONObject("values");val usd=values.getLong("USD");val eur=values.getLong("EUR");if(usd<=0||eur<=0)return Result.failure();applicationContext.getSharedPreferences(RateWidgetProvider.PREFS,Context.MODE_PRIVATE).edit().putLong("usd",usd).putLong("eur",eur).putLong("updatedAt",System.currentTimeMillis()).apply();RateWidgetProvider.updateAll(applicationContext);Result.success()}}catch(e:Exception){Result.retry()}
 companion object{fun schedule(c:Context){val now=Calendar.getInstance();val next=Calendar.getInstance().apply{set(Calendar.HOUR_OF_DAY,9);set(Calendar.MINUTE,0);set(Calendar.SECOND,0);set(Calendar.MILLISECOND,0);if(before(now))add(Calendar.DAY_OF_YEAR,1)};val request=PeriodicWorkRequestBuilder<RateRefreshWorker>(24,TimeUnit.HOURS).setInitialDelay(next.timeInMillis-now.timeInMillis,TimeUnit.MILLISECONDS).setConstraints(Constraints.Builder().setRequiredNetworkType(NetworkType.CONNECTED).build()).setBackoffCriteria(BackoffPolicy.EXPONENTIAL,30,TimeUnit.MINUTES).build();WorkManager.getInstance(c).enqueueUniquePeriodicWork("daily_rate_refresh",ExistingPeriodicWorkPolicy.UPDATE,request)}}
}
