import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// 首页
/// 应用的主入口页面，展示APP名称和开始按钮
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  /// 星星动画控制器
  late AnimationController _starAnimController;

  /// 星星缩放动画
  late Animation<double> _starScaleAnimation;

  /// 浮动动画控制器
  late AnimationController _floatController;

  /// 浮动偏移动画
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    // 星星缩放动画
    _starAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _starScaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _starAnimController,
        curve: Curves.easeInOut,
      ),
    );

    // 按钮浮动动画
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -4, end: 4).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _starAnimController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // 背景渐变
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF667EEA),
              Color(0xFF764BA2),
              Color(0xFFF093FB),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // 背景装饰元素
              ..._buildBackgroundDecorations(),

              // 主要内容
              Column(
                children: [
                  // 顶部栏
                  _buildTopBar(),

                  // 中间内容区
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),

                          // APP名称
                          _buildAppName(),

                          const SizedBox(height: 12),

                          // 副标题
                          _buildSubtitle(),

                          const SizedBox(height: 60),

                          // 开始按钮
                          _buildStartButton(),

                          const SizedBox(height: 40),

                          // 装饰月亮
                          _buildMoonDecoration(),
                        ],
                      ),
                    ),
                  ),

                  // 底部声明
                  _buildDisclaimer(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建顶部栏
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 个人中心入口
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建APP名称
  Widget _buildAppName() {
    return AnimatedBuilder(
      animation: _starScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _starScaleAnimation.value,
          child: child,
        );
      },
      child: const Text(
        '✨ 梦境故事屋 ✨',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建副标题
  Widget _buildSubtitle() {
    return const Text(
      '为宝贝编织独一无二的睡前故事',
      style: TextStyle(
        fontSize: 16,
        color: Colors.white70,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  /// 构建开始按钮
  Widget _buildStartButton() {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: child,
        );
      },
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/info-setup');
        },
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD93D), Color(0xFFFF6B9D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6B9D).withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '⭐',
                style: TextStyle(fontSize: 22),
              ),
              SizedBox(width: 10),
              Text(
                '开始定制故事',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 10),
              Text(
                '⭐',
                style: TextStyle(fontSize: 22),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建月亮装饰
  Widget _buildMoonDecoration() {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value * 0.5),
          child: child,
        );
      },
      child: const Text(
        '🌙',
        style: TextStyle(fontSize: 48),
      ),
    );
  }

  /// 构建底部声明
  Widget _buildDisclaimer() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Text(
        '内容仅供亲子娱乐与启蒙参考',
        style: TextStyle(
          fontSize: 12,
          color: Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }

  /// 构建背景装饰元素
  List<Widget> _buildBackgroundDecorations() {
    return [
      // 左上角星星
      Positioned(
        top: 60,
        left: 30,
        child: AnimatedBuilder(
          animation: _starScaleAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: 0.3 + _starScaleAnimation.value * 0.2,
              child: child,
            );
          },
          child: const Text('⭐', style: TextStyle(fontSize: 20)),
        ),
      ),
      // 右上角星星
      Positioned(
        top: 100,
        right: 50,
        child: AnimatedBuilder(
          animation: _starAnimController,
          builder: (context, child) {
            return Opacity(
              opacity: 0.2 + _starScaleAnimation.value * 0.3,
              child: child,
            );
          },
          child: const Text('✨', style: TextStyle(fontSize: 16)),
        ),
      ),
      // 左下角星星
      Positioned(
        bottom: 120,
        left: 40,
        child: AnimatedBuilder(
          animation: _starAnimController,
          builder: (context, child) {
            return Opacity(
              opacity: 0.2 + _starScaleAnimation.value * 0.2,
              child: child,
            );
          },
          child: const Text('🌟', style: TextStyle(fontSize: 14)),
        ),
      ),
      // 右下角星星
      Positioned(
        bottom: 180,
        right: 35,
        child: AnimatedBuilder(
          animation: _starScaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _starScaleAnimation.value,
              child: child,
            );
          },
          child: const Text('⭐', style: TextStyle(fontSize: 18)),
        ),
      ),
      // 中间偏左装饰
      Positioned(
        top: 200,
        left: 20,
        child: AnimatedBuilder(
          animation: _floatAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _floatAnimation.value * 0.3),
              child: child,
            );
          },
          child: const Text('💫', style: TextStyle(fontSize: 12)),
        ),
      ),
    ];
  }
}

