class Story {
  final String id;
  final String title;
  final String content;
  final String summary;
  final String? imageUrl;
  final List<String> tags;
  final DateTime createdAt;

  Story({
    required this.id,
    required this.title,
    required this.content,
    required this.summary,
    this.imageUrl,
    required this.tags,
    required this.createdAt,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      summary: json['summary'] as String,
      imageUrl: json['imageUrl'] as String?,
      tags: List<String>.from(json['tags'] as List),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'summary': summary,
      'imageUrl': imageUrl,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
