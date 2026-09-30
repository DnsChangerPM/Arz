import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models.dart';
class RatesState { const RatesState({this.snapshot,this.loading=false,this.error}); final RateSnapshot? snapshot; final bool loading; final String? error; RatesState copy({RateSnapshot? snapshot,bool? loading,String? error,bool clearError=false})=>RatesState(snapshot:snapshot??this.snapshot,loading:loading??this.loading,error:clearError?null:error??this.error); }
class RatesController extends StateNotifier<RatesState> {
  RatesController(this._repository):super(const RatesState()); final ExchangeRateRepository _repository; Timer? _timer;
  Future<void> start({Duration interval=const Duration(minutes:15)}) async { final cached=await _repository.cached(); if(cached!=null)state=RatesState(snapshot:cached); unawaited(refresh()); _timer=Timer.periodic(interval,(_)=>refresh(silent:true)); }
  Future<void> refresh({bool silent=false}) async { if(state.loading)return; state=state.copy(loading:!silent,clearError:true); try{state=RatesState(snapshot:await _repository.refresh());}catch(e){state=state.copy(loading:false,error:'دریافت نرخ‌های جدید ممکن نشد. اطلاعات ذخیره‌شده نمایش داده می‌شود.');} }
  @override void dispose(){_timer?.cancel();super.dispose();}
}
