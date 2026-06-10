import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/story.dart';

class ApiService {
  // 模拟 API 调用
  Future<List<Story>> getRecommendedStories() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(seconds: 1));
    
    // 返回模拟数据
    return [
      Story(
        id: '1',
        title: '勇敢的小兔子',
        content: '从前有一只勇敢的小兔子...',
        summary: '一个关于勇气的故事',
        tags: ['勇敢', '动物'],
        createdAt: DateTime.now(),
      ),
      Story(
        id: '2',
        title: '星星的魔法',
        content: '在遥远的天空中...',
        summary: '一个充满魔法的故事',
        tags: ['魔法', '奇幻'],
        createdAt: DateTime.now(),
      ),
    ];
  }

  Future<Map<String, dynamic>> generateStory(Map<String, dynamic> params) async {
    await Future.delayed(const Duration(seconds: 2));
    
    return {
      'success': true,
      'story': {
        'title': '专属故事',
        'content': '这是一个为你的孩子生成的故事...',
        'summary': '专属定制故事',
      },
    };
  }
}
