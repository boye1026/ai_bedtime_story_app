import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/child_info.dart';

class ChildInfoService {
  static const String _storageKey = 'child_info';

  // 保存孩子信息
  Future<void> saveChildInfo(ChildInfo childInfo) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(childInfo.toJson());
    await prefs.setString(_storageKey, jsonString);
  }

  // 获取孩子信息
  Future<ChildInfo?> getChildInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    
    if (jsonString == null) {
      return null;
    }
    
    try {
      final json = jsonDecode(jsonString);
      return ChildInfo.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  // 删除孩子信息
  Future<void> deleteChildInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  // 检查是否已设置信息
  Future<bool> hasChildInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_storageKey);
  }
}
