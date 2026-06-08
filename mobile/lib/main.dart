import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'services/storage_service.dart';
import 'services/ad_service.dart';
import 'models/user.dart';

/// 应用入口
/// 初始化服务并启动应用
void main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化本地存储服务
  final storageService = StorageService();
  await storageService.init();

  // 初始化默认用户（如果不存在）
  final user = await storageService.getUser();
  if (user == null) {
    await storageService.saveUser(User());
  }

  // 初始化广告服务
  final adService = AdService();
  await adService.init();

  // 启动应用
  runApp(
    // 使用Provider提供全局服务
    MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storageService),
        Provider<AdService>.value(value: adService),
      ],
      child: const BedtimeStoryApp(),
    ),
  );
}
