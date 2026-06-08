import 'package:flutter/material.dart';
import '../models/story.dart';
import '../theme/app_colors.dart';

/// 故事卡片组件
/// 用于在列表中展示故事的摘要信息
class StoryCard extends StatelessWidget {
  /// 故事数据
  final Story story;

  /// 点击回调
  final VoidCallback? onTap;

  /// 删除回调（用于左滑删除）
  final VoidCallback? onDismiss;

  /// 是否显示删除功能
  final bool showDismiss;

  const StoryCard({
    super.key,
    required this.story,
    this.onTap,
    this.onDismiss,
    this.showDismiss = false,
  });

  /// 获取风格对应的颜色
  Color _getStyleColor(String style) {
    switch (style) {
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

  /// 获取风格对应的图标
  String _getStyleIcon(String style) {
    switch (style) {
      case '童话风':
        return '🏰';
      case '冒险风':
        return '🗺️';
      case '温馨风':
        return '🌙';
      case '启蒙风':
        return '📚';
      default:
        return '📖';
    }
  }

  @override
  Widget build(BuildContext context) {
    final styleColor = _getStyleColor(story.style);

    Widget card = Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 左侧风格图标
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: styleColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      _getStyleIcon(story.style),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // 右侧内容
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 标题
                      Text(
                        story.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // 摘要
                      Text(
                        story.summary,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      // 底部信息栏
                      Row(
                        children: [
                          // 风格标签
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: styleColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              story.style,
                              style: TextStyle(
                                fontSize: 11,
                                color: styleColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // 日期
                          Text(
                            story.formattedDate,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textHint,
                            ),
                          ),
                          const Spacer(),
                          // 收藏图标
                          if (story.isFavorited)
                            const Icon(
                              Icons.favorite,
                              color: AppColors.favorite,
                              size: 18,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // 如果需要显示删除功能，包裹Dismissible
    if (showDismiss && onDismiss != null) {
      return Dismissible(
        key: Key(story.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: AppColors.error,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.delete_outline,
            color: Colors.white,
            size: 28,
          ),
        ),
        confirmDismiss: (direction) async {
          // 显示确认对话框
          return await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('确认删除'),
              content: const Text('确定要删除这个故事吗？'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text(
                    '删除',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              ],
            ),
          );
        },
        onDismissed: (direction) => onDismiss!(),
        child: card,
      );
    }

    return card;
  }
}
