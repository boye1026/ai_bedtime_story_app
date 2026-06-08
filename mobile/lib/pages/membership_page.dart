import 'package:flutter/material.dart';
import '../services/ad_service.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../theme/app_colors.dart';

/// 会员中心页面
/// 展示会员套餐和权益，支持购买和观看广告获取免费次数
class MembershipPage extends StatefulWidget {
  const MembershipPage({super.key});

  @override
  State<MembershipPage> createState() => _MembershipPageState();
}

class _MembershipPageState extends State<MembershipPage> {
  /// 广告服务
  final AdService _adService = AdService();

  /// API服务
  final ApiService _apiService = ApiService();

  /// 存储服务
  final StorageService _storageService = StorageService();

  /// 选中的套餐索引
  int _selectedPlanIndex = 1; // 默认选中月会员

  /// 是否正在购买
  bool _isPurchasing = false;

  /// 是否正在观看广告
  bool _isWatchingAd = false;

  /// 会员套餐数据
  final List<Map<String, dynamic>> _plans = const [
    {
      'name': '周会员',
      'price': '19.9',
      'period': '周',
      'originalPrice': '29.9',
      'badge': null,
      'features': ['每日生成5个故事', '基础故事模板'],
    },
    {
      'name': '月会员',
      'price': '19.9',
      'period': '月',
      'originalPrice': '39.9',
      'badge': '推荐',
      'features': ['无限生成故事', '解锁精品故事库', '专属故事模板'],
    },
    {
      'name': '季度会员',
      'price': '49',
      'period': '季',
      'originalPrice': '119.7',
      'badge': '超值',
      'features': ['无限生成故事', '解锁精品故事库', '专属故事模板', '优先体验新功能'],
    },
  ];

  /// 会员权益列表
  final List<Map<String, String>> _benefits = const [
    {'icon': '♾️', 'title': '无限生成故事', 'desc': '不再受次数限制'},
    {'icon': '📖', 'title': '解锁精品故事库', 'desc': '海量优质故事模板'},
    {'icon': '🎨', 'title': '专属故事模板', 'desc': 'VIP专属定制模板'},
    {'icon': '🚀', 'title': '优先体验新功能', 'desc': '第一时间体验新特性'},
  ];

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  /// 购买会员
  Future<void> _purchaseVip() async {
    setState(() => _isPurchasing = true);

    try {
      // 调用API激活VIP
      final plan = _plans[_selectedPlanIndex];
      final result = await _apiService.activateVip(
        'user_id', // 实际使用时替换为真实用户ID
        plan['name'] as String,
        'token', // 实际使用时替换为真实token
      );

      // 更新本地用户信息
      await _storageService.updateUser({
        'isVip': true,
        'vipExpireDate': result['expireDate'],
      });

      if (mounted) {
        _showSnackBar('会员开通成功！');
        Navigator.pop(context, true); // 返回并刷新
      }
    } on ApiException catch (e) {
      if (mounted) {
        _showSnackBar(e.message);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('购买失败，请稍后重试');
      }
    } finally {
      if (mounted) {
        setState(() => _isPurchasing = false);
      }
    }
  }

  /// 观看广告获取免费次数
  Future<void> _watchAdForFreeCount() async {
    setState(() => _isWatchingAd = true);

    try {
      final earned = await _adService.showRewardedAd();
      if (earned) {
        // 更新本地用户免费次数
        final user = await _storageService.getUser();
        if (user != null) {
          user.addFreeCountFromAd();
          await _storageService.saveUser(user);
        }
        if (mounted) {
          _showSnackBar('获得1次免费生成机会！');
        }
      } else {
        if (mounted) {
          _showSnackBar('需要完整观看广告才能获得奖励');
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('广告加载失败，请稍后重试');
      }
    } finally {
      if (mounted) {
        setState(() => _isWatchingAd = false);
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('会员中心'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========== 会员权益介绍 ==========
            _buildBenefitsHeader(),
            const SizedBox(height: 24),

            // ========== 套餐选择 ==========
            _buildPlanCards(),
            const SizedBox(height: 24),

            // ========== 权益列表 ==========
            _buildBenefitsList(),
            const SizedBox(height: 24),

            // ========== 广告入口 ==========
            _buildAdEntry(),
            const SizedBox(height: 32),

            // ========== 购买按钮 ==========
            _buildPurchaseButton(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// 构建会员权益头部
  Widget _buildBenefitsHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD93D), Color(0xFFFF6B9D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Text(
            '👑',
            style: TextStyle(fontSize: 40),
          ),
          const SizedBox(height: 8),
          const Text(
            '开通会员，畅享无限故事',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '让宝贝每晚都有新故事陪伴入眠',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建套餐卡片
  Widget _buildPlanCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '选择套餐',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(_plans.length, (index) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 0 : 6,
                  right: index == _plans.length - 1 ? 0 : 6,
                ),
                child: _buildPlanCard(index),
              ),
            );
          }),
        ),
      ],
    );
  }

  /// 构建单个套餐卡片
  Widget _buildPlanCard(int index) {
    final plan = _plans[index];
    final isSelected = _selectedPlanIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedPlanIndex = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.08)
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE8E8E8),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? AppColors.cardShadow : null,
        ),
        child: Column(
          children: [
            // 推荐标签
            if (plan['badge'] != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : const Color(0xFFFF6B9D),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  plan['badge'] as String,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              const SizedBox(height: 18),
            const SizedBox(height: 8),

            // 套餐名称
            Text(
              plan['name'] as String,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            // 价格
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '¥',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color:
                        isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
                Text(
                  plan['price'] as String,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color:
                        isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
                Text(
                  '/${plan['period']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            // 原价
            Text(
              '¥${plan['originalPrice']}',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textHint,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建权益列表
  Widget _buildBenefitsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '会员权益',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ..._benefits.map((benefit) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Text(
                  benefit['icon']!,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        benefit['title']!,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        benefit['desc']!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 20,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  /// 构建广告入口
  Widget _buildAdEntry() {
    return GestureDetector(
      onTap: _isWatchingAd ? null : _watchAdForFreeCount,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFFFD93D).withOpacity(0.5),
            width: 1.5,
          ),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD93D).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('🎬', style: TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '看广告免费获得1次生成机会',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '完整观看广告即可获得奖励',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
            if (_isWatchingAd)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.accent,
                ),
              )
            else
              const Icon(
                Icons.chevron_right,
                color: AppColors.textHint,
              ),
          ],
        ),
      ),
    );
  }

  /// 构建购买按钮
  Widget _buildPurchaseButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isPurchasing ? null : _purchaseVip,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          padding: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD93D), Color(0xFFFF6B9D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6B9D).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Container(
            alignment: Alignment.center,
            child: _isPurchasing
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '👑',
                        style: TextStyle(fontSize: 22),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '立即开通 ¥${_plans[_selectedPlanIndex]['price']}/${_plans[_selectedPlanIndex]['period']}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
