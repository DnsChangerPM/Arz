import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
class JsonStore {
  JsonStore(this._preferences); final SharedPreferences _preferences;
  static Future<JsonStore> create() async => JsonStore(await SharedPreferences.getInstance());
  Map<String,dynamic>? read(String key) { final raw=_preferences.getString(key); if(raw==null)return null; try { final v=jsonDecode(raw); return v is Map<String,dynamic>?v:null; } catch(_){return null;} }
  Future<void> write(String key, Map<String,dynamic> value) => _preferences.setString(key,jsonEncode(value));
  String? readString(String key)=>_preferences.getString(key);
  Future<void> writeString(String key,String value)=>_preferences.setString(key,value);
  bool? readBool(String key)=>_preferences.getBool(key);
  Future<void> writeBool(String key,bool value)=>_preferences.setBool(key,value);
}
