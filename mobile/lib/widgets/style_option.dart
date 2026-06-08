import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// 风格选择组件
/// 用于展示和选择故事风格，每个选项以卡片形式展示
class StyleOption extends StatelessWidget {
  /// 风格名称
  final String name;

  /// 风格描述
  final String description;

  /// 风格图标（emoji）
  final String icon;

  /// 是否选中
  final bool isSelected;

  /// 选中回调
  final ValueChanged<bool>? onChanged;

  const StyleOption({
    super.key,
    required this.name,
    required this.description,
    required this.icon,
    this.isSelected = false,
    this.onChanged,
  });

  /// 获取风格对应的颜色
  Color _getStyleColor() {
    switch (name) {
      case '童话风':
        return const Color(0xFF6C63FF);
      case '冒险风':
        return const Color(0xFF00B894);
      case '温馨风':
        return const Color(0xFFFF6B9D);
      case '启蒙风':
        return const Color(0xFFFDCB6E);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStyleColor();

    return GestureDetector(
      onTap: () => onChanged?.call(!isSelected),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.08) : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE8E8E8),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : AppColors.cardShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 图标
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withOpacity(isSelected ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    icon,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // 文字信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 风格名称
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? color : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // 风格描述
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: isSelected
                            ? color.withOpacity(0.8)
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // 选中指示器
              if (isSelected)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
