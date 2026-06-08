import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// 加载动画组件
/// 展示星星旋转和月亮升起的可爱加载动画
class LoadingAnimation extends StatefulWidget {
  /// 加载提示文字
  final String? message;

  /// 动画尺寸
  final double size;

  const LoadingAnimation({
    super.key,
    this.message,
    this.size = 120,
  });

  @override
  State<LoadingAnimation> createState() => _LoadingAnimationState();
}

class _LoadingAnimationState extends State<LoadingAnimation>
    with TickerProviderStateMixin {
  /// 星星旋转动画控制器
  late AnimationController _starController;

  /// 月亮升起动画控制器
  late AnimationController _moonController;

  /// 星星闪烁动画控制器
  late AnimationController _twinkleController;

  /// 星星旋转角度
  late Animation<double> _starRotation;

  /// 月亮位置偏移
  late Animation<double> _moonOffset;

  /// 星星闪烁透明度
  late Animation<double> _twinkleOpacity;

  @override
  void initState() {
    super.initState();

    // 星星旋转动画 - 持续旋转
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _starRotation = Tween<double>(begin: 0, end: 2 * 3.14159).animate(
      CurvedAnimation(
        parent: _starController,
        curve: Curves.linear,
      ),
    );

    // 月亮升起动画 - 上下浮动
    _moonController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _moonOffset = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(
        parent: _moonController,
        curve: Curves.easeInOut,
      ),
    );

    // 星星闪烁动画
    _twinkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _twinkleOpacity = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _twinkleController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _starController.dispose();
    _moonController.dispose();
    _twinkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 动画区域
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 旋转的星星组
                AnimatedBuilder(
                  animation: _starRotation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _starRotation.value,
                      child: child,
                    );
                  },
                  child: _buildStarGroup(),
                ),

                // 中心月亮
                AnimatedBuilder(
                  animation: _moonOffset,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _moonOffset.value),
                      child: child,
                    );
                  },
                  child: _buildMoon(),
                ),

                // 闪烁的小星星
                ..._buildTwinklingStars(),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // 加载文字
          Text(
            widget.message ?? '正在编织梦境...',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建旋转星星组
  Widget _buildStarGroup() {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CustomPaint(
        painter: _StarGroupPainter(),
      ),
    );
  }

  /// 构建月亮
  Widget _buildMoon() {
    return Container(
      width: widget.size * 0.35,
      height: widget.size * 0.35,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFD93D),
            Color(0xFFFFEAA7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD93D).withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Center(
        child: Text(
          '🌙',
          style: TextStyle(fontSize: widget.size * 0.22),
        ),
      ),
    );
  }

  /// 构建闪烁小星星
  List<Widget> _buildTwinklingStars() {
    final positions = [
      const Offset(-0.35, -0.35),
      const Offset(0.35, -0.30),
      const Offset(-0.38, 0.25),
      const Offset(0.30, 0.35),
    ];

    return positions.map((pos) {
      return AnimatedBuilder(
        animation: _twinkleOpacity,
        builder: (context, child) {
          return Opacity(
            opacity: _twinkleOpacity.value,
            child: Positioned(
              left: (pos.dx + 0.5) * widget.size - 8,
              top: (pos.dy + 0.5) * widget.size - 8,
              child: const Text(
                '✨',
                style: TextStyle(fontSize: 16),
              ),
            ),
          );
        },
      );
    }).toList();
  }
}

/// 星星组绘制器
class _StarGroupPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.42;

    // 绘制4颗装饰星星
    for (int i = 0; i < 4; i++) {
      final angle = (i * 3.14159 / 2);
      final x = center.dx + radius * (angle == 0 ? 1 : angle == 1.57 ? 0 : -1);
      final y = center.dy +
          radius * (angle == 0 ? 0 : angle == 1.57 ? 1 : angle == 3.14 ? 0 : -1);

      final paint = Paint()
        ..color = const Color(0xFFFFD93D).withOpacity(0.6)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), 3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
