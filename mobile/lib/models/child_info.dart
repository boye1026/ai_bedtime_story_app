/// 孩子信息模型
/// 用于存储孩子的基本信息，作为生成故事的输入参数
class ChildInfo {
  /// 孩子姓名
  final String name;

  /// 孩子年龄 (1-12岁)
  final int age;

  /// 兴趣爱好列表
  /// 可选值: 动物、太空、海洋、恐龙、公主、汽车、音乐、画画
  final List<String> interests;

  /// 启蒙方向列表
  /// 可选值: 勇敢、礼貌、自律、友善
  final List<String> educationDirections;

  /// 故事风格
  /// 可选值: 童话风、冒险风、温馨风、启蒙风
  final String storyStyle;

  ChildInfo({
    required this.name,
    required this.age,
    this.interests = const [],
    this.educationDirections = const [],
    this.storyStyle = '童话风',
  });

  /// 从JSON创建对象
  factory ChildInfo.fromJson(Map<String, dynamic> json) {
    return ChildInfo(
      name: json['name'] as String? ?? '',
      age: json['age'] as int? ?? 4,
      interests: List<String>.from(json['interests'] as List? ?? []),
      educationDirections:
          List<String>.from(json['educationDirections'] as List? ?? []),
      storyStyle: json['storyStyle'] as String? ?? '童话风',
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'interests': interests,
      'educationDirections': educationDirections,
      'storyStyle': storyStyle,
    };
  }

  /// 复制并修改部分字段
  ChildInfo copyWith({
    String? name,
    int? age,
    List<String>? interests,
    List<String>? educationDirections,
    String? storyStyle,
  }) {
    return ChildInfo(
      name: name ?? this.name,
      age: age ?? this.age,
      interests: interests ?? this.interests,
      educationDirections: educationDirections ?? this.educationDirections,
      storyStyle: storyStyle ?? this.storyStyle,
    );
  }

  @override
  String toString() {
    return 'ChildInfo(name: $name, age: $age, interests: $interests, '
        'educationDirections: $educationDirections, storyStyle: $storyStyle)';
  }
}
