import 'package:flutter/material.dart';
import '../models/story.dart';
import '../pages/story_display_page.dart';
import '../services/storage_service.dart';
import '../theme/app_colors.dart';
import '../widgets/story_card.dart';

/// 我的收藏页面
/// 展示用户收藏的故事列表，支持左滑删除
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  /// 存储服务
  final StorageService _storageService = StorageService();

  /// 收藏的故事列表
  List<Story> _favorites = [];

  /// 是否正在加载
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  /// 加载收藏列表
  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    final stories = await _storageService.getFavorites();
    if (mounted) {
      setState(() {
        _favorites = stories;
        _isLoading = false;
      });
    }
  }

  /// 删除收藏
  Future<void> _removeFavorite(String storyId) async {
    await _storageService.removeFavorite(storyId);
    if (mounted) {
      setState(() {
        _favorites.removeWhere((s) => s.id == storyId);
      });
      _showSnackBar('已取消收藏');
    }
  }

  /// 导航到故事详情
  void _navigateToStory(Story story) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const StoryDisplayPage(),
        settings: RouteSettings(
          arguments: story,
        ),
      ),
    );
  }

  /// 显示提示信息
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('我的收藏'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  /// 构建页面主体
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 空状态
    if (_favorites.isEmpty) {
      return _buildEmptyState();
    }

    // 故事列表
    return RefreshIndicator(
      onRefresh: _loadFavorites,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _favorites.length,
        itemBuilder: (context, index) {
          final story = _favorites[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: StoryCard(
              story: story,
              showDismiss: true,
              onTap: () => _navigateToStory(story),
              onDismiss: () => _removeFavorite(story.id),
            ),
          );
        },
      ),
    );
  }

  /// 构建空状态视图
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 可爱插画（使用emoji代替）
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '📚',
                  style: TextStyle(fontSize: 56),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '还没有收藏故事哦',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '去生成一个喜欢的故事，收藏起来吧！',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // 返回首页按钮
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text('去生成故事'),
            ),
          ],
        ),
      ),
    );
  }
}
