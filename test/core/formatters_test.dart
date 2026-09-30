import 'package:flutter_test/flutter_test.dart';import 'package:toman_rates/core/utils/formatters.dart';
void main(){test('formats whole toman',(){expect(RateFormatter.toman(52400),'52,400 تومان');expect(RateFormatter.toman(null),'—');expect(RateFormatter.toman(-1),'—');});test('Persian digits',()=>expect(RateFormatter.persianDigits('2026'),'۲۰۲۶'));}
