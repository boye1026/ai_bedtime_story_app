import 'package:flutter/material.dart';
import '../models/child_info.dart';
import '../models/story.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/tts_service.dart';
import '../theme/app_colors.dart';
import '../widgets/loading_animation.dart';

/// 故事展示页
/// 展示生成的故事内容，支持语音朗读和收藏
class StoryDisplayPage extends StatefulWidget {
  const StoryDisplayPage({super.key});

  @override
  State<StoryDisplayPage> createState() => _StoryDisplayPageState();
}

class _StoryDisplayPageState extends State<StoryDisplayPage> {
  /// 孩子信息（从上一页传入，用于生成新故事）
  ChildInfo? _childInfo;

  /// 已有故事（从收藏页传入，直接展示）
  Story? _existingStory;

  /// 是否已初始化（防止重复加载）
  bool _isInitialized = false;

  /// 生成的故事
  Story? _story;

  /// 是否正在加载
  bool _isLoading = true;

  /// 加载错误信息
  String? _errorMessage;

  /// TTS服务
  final TtsService _ttsService = TtsService();

  /// 是否正在朗读
  bool _isSpeaking = false;

  /// 存储服务
  final StorageService _storageService = StorageService();

  /// API服务
  final ApiService _apiService = ApiService();

  /// 是否已收藏
  bool _isFavorited = false;

  /// 朗读进度（0.0 - 1.0）
  double _speakingProgress = 0.0;

  @override
  void initState() {
    super.initState();
    // 初始化TTS回调
    _ttsService.onStart = () {
      if (mounted) setState(() => _isSpeaking = true);
    };
    _ttsService.onCompleted = () {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
          _speakingProgress = 0.0;
        });
      }
    };
    _ttsService.onError = (msg) {
      if (mounted) {
        setState(() => _isSpeaking = false);
        _showSnackBar('语音播放出错: $msg');
      }
    };
    _ttsService.onProgress = (text, start, end, word) {
      if (mounted && text.isNotEmpty) {
        setState(() {
          _speakingProgress = end / text.length;
        });
      }
    };
  }

  @override
  void dispose() {
    _ttsService.dispose();
    _apiService.dispose();
    super.dispose();
  }

  /// 加载故事
  Future<void> _loadStory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 调用API生成故事
      final story = await _apiService.generateStory(_childInfo);

      if (mounted) {
        setState(() {
          _story = story;
          _isLoading = false;
        });

        // 检查是否已收藏
        final favorited = await _storageService.isFavorited(story.id);
        if (mounted) {
          setState(() => _isFavorited = favorited);
        }
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = '生成故事失败，请稍后重试';
        });
      }
    }
  }

  /// 重新生成故事
  Future<void> _regenerateStory() async {
    // 停止当前朗读
    await _ttsService.stop();
    await _loadStory();
  }

  /// 切换朗读状态
  Future<void> _toggleSpeaking() async {
    if (_story == null) return;

    if (_isSpeaking) {
      await _ttsService.pause();
    } else if (_ttsService.isPaused) {
      await _ttsService.resume();
    } else {
      await _ttsService.speak(_story!.content);
    }
  }

  /// 停止朗读
  Future<void> _stopSpeaking() async {
    await _ttsService.stop();
    if (mounted) {
      setState(() {
        _isSpeaking = false;
        _speakingProgress = 0.0;
      });
    }
  }

  /// 切换收藏状态
  Future<void> _toggleFavorite() async {
    if (_story == null) return;

    if (_isFavorited) {
      // 取消收藏
      await _storageService.removeFavorite(_story!.id);
      if (mounted) {
        setState(() {
          _isFavorited = false;
          _story = _story!.copyWith(isFavorited: false);
        });
        _showSnackBar('已取消收藏');
      }
    } else {
      // 添加收藏
      await _storageService.addFavorite(_story!);
      if (mounted) {
        setState(() {
          _isFavorited = true;
          _story = _story!.copyWith(isFavorited: true);
        });
        _showSnackBar('已收藏故事');
      }
    }
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
    // 从路由参数获取数据（仅首次）
    if (!_isInitialized) {
      final args =
          ModalRoute.of(context)?.settings.arguments;
      if (args is ChildInfo) {
        // 从信息设置页传入，需要生成新故事
        _childInfo = args;
      } else if (args is Story) {
        // 从收藏页传入，直接展示已有故事
        _existingStory = args;
        _story = args;
        _isLoading = false;
        _isFavorited = args.isFavorited;
      }
      _isInitialized = true;
      // 首次加载故事（仅当从设置页进入时才调用API生成）
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_childInfo != null && _story == null && _errorMessage == null) {
          _loadStory();
        }
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_story?.title ?? '专属故事'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () {
            _ttsService.stop();
            Navigator.pop(context);
          },
        ),
        actions: [
          // 分享按钮（预留）
          IconButton(
            icon: const Icon(Icons.share_outline),
            onPressed: () {
              _showSnackBar('分享功能即将上线');
            },
          ),
        ],
      ),
      body: _buildBody(),
      // 底部操作栏
      bottomNavigationBar: _story != null ? _buildBottomBar() : null,
    );
  }

  /// 构建页面主体
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: LoadingAnimation(
          message: '正在编织梦境...',
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorView();
    }

    if (_story == null) {
      return const Center(
        child: Text('暂无故事内容'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 故事标题
          Text(
            _story!.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          // 故事元信息
          Row(
            children: [
              // 风格标签
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _story!.style,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 日期
              Text(
                _story!.formattedDate,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 分割线
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.primary.withOpacity(0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 故事正文
          Text(
            _story!.content,
            style: const TextStyle(
              fontSize: 18,
              height: 1.8,
              color: AppColors.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 80), // 底部留白，避免被操作栏遮挡
        ],
      ),
    );
  }

  /// 构建错误视图
  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '😢',
              style: TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? '出了点小问题',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _regenerateStory,
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
              child: const Text('重新生成'),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建底部操作栏
  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 朗读进度条（朗读中显示）
          if (_isSpeaking || _ttsService.isPaused)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  // 进度条
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _speakingProgress,
                      backgroundColor:
                          AppColors.primary.withOpacity(0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 播放控制按钮
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 停止按钮
                      IconButton(
                        icon: const Icon(Icons.stop_circle_outline),
                        color: AppColors.textSecondary,
                        onPressed: _stopSpeaking,
                      ),
                      const SizedBox(width: 16),
                      // 播放/暂停按钮
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            _isSpeaking
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: _toggleSpeaking,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // 占位（保持对称）
                      const SizedBox(width: 48),
                    ],
                  ),
                ],
              ),
            ),

          // 操作按钮行
          Row(
            children: [
              // 朗读按钮
              Expanded(
                child: _buildActionButton(
                  icon: _isSpeaking
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  label: _isSpeaking ? '暂停朗读' : '语音朗读',
                  color: AppColors.primary,
                  onTap: _toggleSpeaking,
                ),
              ),
              const SizedBox(width: 12),
              // 收藏按钮
              Expanded(
                child: _buildActionButton(
                  icon: _isFavorited
                      ? Icons.favorite
                      : Icons.favorite_border,
                  label: _isFavorited ? '已收藏' : '收藏',
                  color: _isFavorited
                      ? AppColors.favorite
                      : AppColors.textSecondary,
                  onTap: _toggleFavorite,
                ),
              ),
              const SizedBox(width: 12),
              // 重新生成按钮
              Expanded(
                child: _buildActionButton(
                  icon: Icons.refresh,
                  label: '重新生成',
                  color: AppColors.secondary,
                  onTap: _regenerateStory,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
