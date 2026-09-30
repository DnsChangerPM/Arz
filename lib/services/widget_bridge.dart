import 'dart:io';
import 'package:flutter/services.dart';
import '../features/exchange_rates/domain/models.dart';

class WidgetBridge {
  static const _channel = MethodChannel('com.tomanrates.app/widget');
  Future<void> update(RateSnapshot snapshot) async {
    if (!Platform.isAndroid) return;
    num? value(String c) {
      for (final r in snapshot.rates) {
        if (r.code == c) return r.toman;
      }
      return null;
    }

    try {
      await _channel.invokeMethod<void>('updateWidget', {
        'usd': value('USD')?.round(),
        'eur': value('EUR')?.round(),
        'updatedAt': snapshot.fetchedAt.millisecondsSinceEpoch,
      });
    } on PlatformException {
      /* Main data remains valid if widget update fails. */
    }
  }

  Future<void> schedule() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<void>('scheduleDaily');
    } on PlatformException {
      /* best effort */
    }
  }
}
