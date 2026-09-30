import 'package:intl/intl.dart';
class RateFormatter {
  static final _number = NumberFormat.decimalPattern('en_US');
  static String toman(num? value) => value == null || !value.isFinite || value < 0 ? '—' : '${_number.format(value.round())} تومان';
  static String persianDigits(String input) { const e='0123456789', p='۰۱۲۳۴۵۶۷۸۹'; return input.split('').map((c) { final i=e.indexOf(c); return i<0 ? c : p[i]; }).join(); }
}
