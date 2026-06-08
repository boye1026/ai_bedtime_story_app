import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'pages/home_page.dart';
import 'pages/info_setup_page.dart';
import 'pages/story_display_page.dart';
import 'pages/profile_page.dart';
import 'pages/favorites_page.dart';
import 'pages/membership_page.dart';

/// 应用根组件
/// 配置MaterialApp、路由管理和全局主题
class BedtimeStoryApp extends StatelessWidget {
  const BedtimeStoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 设置状态栏样式
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return MaterialApp(
      // 应用标题
      title: '梦境故事屋',

      // 调试模式
      debugShowCheckedModeBanner: false,

      // 主题配置
      theme: AppTheme.lightTheme,

      // 路由配置
      initialRoute: '/',
      onGenerateRoute: _generateRoute,

      // 页面过渡动画
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => const Scaffold(
          body: Center(
            child: Text('页面不存在'),
          ),
        ),
      ),
    );
  }

  /// 路由生成器
  /// 管理应用内所有页面的路由跳转
  Route<dynamic> _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        // 首页
        return _buildPageRoute(const HomePage(), settings);

      case '/info-setup':
        // 信息设置页
        return _buildPageRoute(const InfoSetupPage(), settings);

      case '/story-display':
        // 故事展示页
        return _buildPageRoute(const StoryDisplayPage(), settings);

      case '/profile':
        // 个人中心
        return _buildPageRoute(const ProfilePage(), settings);

      case '/favorites':
        // 我的收藏
        return _buildPageRoute(const FavoritesPage(), settings);

      case '/membership':
        // 会员中心
        return _buildPageRoute(const MembershipPage(), settings);

      default:
        // 未知路由，返回首页
        return _buildPageRoute(const HomePage(), settings);
    }
  }

  /// 构建页面路由（带过渡动画）
  PageRouteBuilder _buildPageRoute(
      Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // 使用从右到左的滑入动画
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        final tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        final offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
    );
  }
}
