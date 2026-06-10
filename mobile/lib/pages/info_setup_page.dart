import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/child_info_service.dart';
import '../models/child_info.dart';
import '../theme/app_theme.dart';
import 'story_list_page.dart';

class InfoSetupPage extends StatefulWidget {
  const InfoSetupPage({Key? key}) : super(key: key);

  @override
  State<InfoSetupPage> createState() => _InfoSetupPageState();
}

class _InfoSetupPageState extends State<InfoSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _childInfoService = ChildInfoService();
  
  // 表单控制器
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _interestController = TextEditingController();
  
  // 选择的值
  String _selectedGender = 'boy';
  String _selectedStoryType = 'adventure';
  String _selectedLanguage = 'zh-CN';
  
  // 年龄范围
  int _selectedAge = 5;
  
  // 提交状态 - 改为 final 并初始化
  bool _isSubmitting = false;
  
  // 年龄选项
  final List<int> _ageOptions = List.generate(13, (index) => index + 3);
  
  // 性别选项
  final List<Map<String, dynamic>> _genderOptions = [
    {'value': 'boy', 'label': '男孩', 'icon': Icons.boy},
    {'value': 'girl', 'label': '女孩', 'icon': Icons.girl},
    {'value': 'other', 'label': '其他', 'icon': Icons.child_care},
  ];
  
  // 故事类型选项
  final List<Map<String, dynamic>> _storyTypeOptions = [
    {'value': 'adventure', 'label': '冒险', 'icon': Icons.hiking, 'color': Colors.orange},
    {'value': 'fairy_tale', 'label': '童话', 'icon': Icons.auto_stories, 'color': Colors.purple},
    {'value': 'educational', 'label': '教育', 'icon': Icons.school, 'color': Colors.blue},
    {'value': 'animal', 'label': '动物', 'icon': Icons.pets, 'color': Colors.green},
    {'value': 'fantasy', 'label': '奇幻', 'icon': Icons.star, 'color': Colors.pink},
    {'value': 'daily_life', 'label': '日常生活', 'icon': Icons.home, 'color': Colors.teal},
  ];
  
  // 语言选项
  final List<Map<String, dynamic>> _languageOptions = [
    {'value': 'zh-CN', 'label': '简体中文', 'flag': '🇨🇳'},
    {'value': 'zh-TW', 'label': '繁體中文', 'flag': '🇹🇼'},
    {'value': 'en', 'label': 'English', 'flag': '🇺🇸'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedInfo();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _interestController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedInfo() async {
    final savedInfo = await _childInfoService.getChildInfo();
    if (savedInfo != null) {
      setState(() {
        _nameController.text = savedInfo.name;
        _selectedAge = savedInfo.age;
        _selectedGender = savedInfo.gender;
        _selectedStoryType = savedInfo.storyType;
        _selectedLanguage = savedInfo.language;
        if (savedInfo.interests.isNotEmpty) {
          _interestController.text = savedInfo.interests.join(',');
        }
      });
    }
  }

  Future<void> _submitInfo() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });
      
      try {
        // 解析兴趣
        List<String> interests = _interestController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        
        final childInfo = ChildInfo(
          name: _nameController.text,
          age: _selectedAge,
          gender: _selectedGender,
          storyType: _selectedStoryType,
          interests: interests,
          language: _selectedLanguage,
          createdAt: DateTime.now(),
        );
        
        await _childInfoService.saveChildInfo(childInfo);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('信息已保存，正在生成专属故事...'),
              backgroundColor: Colors.green,
            ),
          );
          
          // 跳转到故事列表页
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const StoryListPage(),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('保存失败: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('宝宝档案'),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('退出设置'),
                content: const Text('确定要退出吗？未保存的信息将会丢失。'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('退出'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 头部说明
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.1),
                    AppTheme.secondaryColor.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.auto_stories,
                    size: 48,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '让我们认识一下你的宝宝',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '填写信息后，我将为宝宝生成专属的睡前故事',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 基本信息卡片
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, color: AppTheme.primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          '基本信息',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // 姓名
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: '宝宝昵称',
                        hintText: '请输入宝宝的昵称',
                        prefixIcon: Icon(Icons.badge),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入宝宝昵称';
                        }
                        if (value.length < 2) {
                          return '昵称至少2个字符';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 年龄
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '年龄',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _selectedAge,
                              isExpanded: true,
                              items: _ageOptions.map((age) {
                                return DropdownMenuItem(
                                  value: age,
                                  child: Text('$age 岁'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedAge = value!;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 性别
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '性别',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: _genderOptions.map((option) {
                            return Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedGender = option['value'];
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _selectedGender == option['value']
                                        ? AppTheme.primaryColor
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _selectedGender == option['value']
                                          ? AppTheme.primaryColor
                                          : Colors.grey[300]!,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        option['icon'],
                                        color: _selectedGender == option['value']
                                            ? Colors.white
                                            : Colors.grey[600],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        option['label'],
                                        style: TextStyle(
                                          color: _selectedGender == option['value']
                                              ? Colors.white
                                              : Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 故事偏好卡片
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.favorite, color: AppTheme.primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          '故事偏好',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // 故事类型
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '喜欢的故事类型',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        const SizedBox(height: 8),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 2.5,
                          children: _storyTypeOptions.map((option) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedStoryType = option['value'];
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _selectedStoryType == option['value']
                                      ? (option['color'] as Color).withOpacity(0.2)
                                      : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _selectedStoryType == option['value']
                                        ? option['color']
                                        : Colors.grey[300]!,
                                    width: _selectedStoryType == option['value'] ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      option['icon'],
                                      size: 20,
                                      color: _selectedStoryType == option['value']
                                          ? option['color']
                                          : Colors.grey[600],
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        option['label'],
                                        style: TextStyle(
                                          color: _selectedStoryType == option['value']
                                              ? option['color']
                                              : Colors.grey[700],
                                          fontWeight: _selectedStoryType == option['value']
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 兴趣爱好
                    TextFormField(
                      controller: _interestController,
                      decoration: const InputDecoration(
                        labelText: '兴趣爱好',
                        hintText: '例如：恐龙,太空,公主,动物...',
                        prefixIcon: Icon(Icons.interests),
                        helperText: '多个兴趣用逗号分隔',
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 语言设置卡片
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.language, color: AppTheme.primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          '语言设置',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: _languageOptions.map((option) {
                        return FilterChip(
                          label: Text('${option['flag']} ${option['label']}'),
                          selected: _selectedLanguage == option['value'],
                          onSelected: (selected) {
                            setState(() {
                              _selectedLanguage = option['value'];
                            });
                          },
                          selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                          checkmarkColor: AppTheme.primaryColor,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // 提交按钮
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitInfo,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      '开始专属故事之旅',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
            
            const SizedBox(height: 16),
            
            // 提示文字
            Center(
              child: Text(
                '所有信息仅用于个性化故事生成，不会泄露',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
