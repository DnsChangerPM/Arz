import '../../../core/storage/json_store.dart';
import '../../../services/widget_bridge.dart';
import '../domain/models.dart';
import 'exchange_rate_remote_data_source.dart';
class ExchangeRateRepositoryImpl implements ExchangeRateRepository {
  ExchangeRateRepositoryImpl(this._remote,this._store,this._widget); final ExchangeRateRemoteDataSource _remote; final JsonStore _store; final WidgetBridge _widget;
  static const _key='rate_snapshot_v1';
  @override Future<RateSnapshot?> cached() async { final j=_store.read(_key); if(j==null)return null; try{return RateSnapshot.fromJson(j);}catch(_){return null;} }
  @override Future<RateSnapshot> refresh() async { final result=await _remote.fetch(); await _store.write(_key,result.toJson()); await _widget.update(result); return result; }
}
