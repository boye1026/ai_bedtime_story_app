/// 故事模型
/// 用于存储生成的故事内容及相关元信息
class Story {
  /// 故事唯一标识
  final String id;

  /// 故事标题
  final String title;

  /// 故事正文内容
  final String content;

  /// 创建时间
  final DateTime createdAt;

  /// 关联的孩子姓名
  final String childName;

  /// 故事风格
  final String style;

  /// 是否已收藏
  bool isFavorited;

  Story({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.childName,
    required this.style,
    this.isFavorited = false,
  });

  /// 从JSON创建对象
  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      childName: json['childName'] as String? ?? '',
      style: json['style'] as String? ?? '童话风',
      isFavorited: json['isFavorited'] as bool? ?? false,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'childName': childName,
      'style': style,
      'isFavorited': isFavorited,
    };
  }

  /// 获取故事摘要（取前50个字符）
  String get summary {
    if (content.length <= 50) return content;
    return '${content.substring(0, 50)}...';
  }

  /// 格式化创建日期
  String get formattedDate {
    return '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-'
        '${createdAt.day.toString().padLeft(2, '0')} '
        '${createdAt.hour.toString().padLeft(2, '0')}:'
        '${createdAt.minute.toString().padLeft(2, '0')}';
  }

  /// 复制并修改部分字段
  Story copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    String? childName,
    String? style,
    bool? isFavorited,
  }) {
    return Story(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      childName: childName ?? this.childName,
      style: style ?? this.style,
      isFavorited: isFavorited ?? this.isFavorited,
    );
  }

  @override
  String toString() {
    return 'Story(id: $id, title: $title, childName: $childName, '
        'style: $style, isFavorited: $isFavorited)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Story && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
