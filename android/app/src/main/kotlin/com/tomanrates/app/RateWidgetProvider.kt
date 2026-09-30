package com.tomanrates.app
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import java.text.NumberFormat
import java.text.SimpleDateFormat
import java.util.*
class RateWidgetProvider: AppWidgetProvider(){
 override fun onUpdate(context:Context,manager:AppWidgetManager,ids:IntArray){ids.forEach{update(context,manager,it)};RateRefreshWorker.schedule(context)}
 companion object { const val PREFS="toman_widget";fun updateAll(c:Context){val m=AppWidgetManager.getInstance(c);m.getAppWidgetIds(ComponentName(c,RateWidgetProvider::class.java)).forEach{update(c,m,it)}}
  private fun update(c:Context,m:AppWidgetManager,id:Int){val p=c.getSharedPreferences(PREFS,Context.MODE_PRIVATE);val usd=p.getLong("usd",0);val eur=p.getLong("eur",0);val at=p.getLong("updatedAt",0);val v=RemoteViews(c.packageName,R.layout.rate_widget);if(usd>0){val f=NumberFormat.getIntegerInstance(Locale.US);v.setTextViewText(R.id.usd_rate,"USD   ${f.format(usd)} تومان");v.setTextViewText(R.id.eur_rate,"EUR   ${f.format(eur)} تومان");v.setTextViewText(R.id.updated_at,"بروزرسانی: "+SimpleDateFormat("HH:mm",Locale("fa")).format(Date(at)))}else{v.setTextViewText(R.id.usd_rate,"در انتظار دریافت نرخ ارز");v.setTextViewText(R.id.eur_rate,"");v.setTextViewText(R.id.updated_at,"")};val intent=Intent(c,MainActivity::class.java);v.setOnClickPendingIntent(R.id.widget_root,PendingIntent.getActivity(c,0,intent,PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT));m.updateAppWidget(id,v)} }
}
