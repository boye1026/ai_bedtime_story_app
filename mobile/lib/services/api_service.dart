import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/child_info.dart';
import '../models/story.dart';

/// 故事模板接口
/// 预留故事模板扩展位置，支持不同风格的故事模板
abstract class StoryTemplate {
  /// 模板名称
  String get name;

  /// 模板描述
  String get description;

  /// 模板图标
  String get icon;

  /// 根据孩子信息生成提示词
  String buildPrompt(ChildInfo childInfo);
}

/// 童话风故事模板
class FairyTaleTemplate implements StoryTemplate {
  @override
  String get name => '童话风';

  @override
  String get description => '充满魔法与奇幻的经典童话';

  @override
  String get icon => '🏰';

  @override
  String buildPrompt(ChildInfo childInfo) {
    return '请为${childInfo.age}岁的${childInfo.name}创作一个温馨的童话故事。'
        '孩子喜欢${childInfo.interests.join('、')}。'
        '故事要体现${childInfo.educationDirections.join('、')}的品质。'
        '语言要优美柔和，适合睡前朗读。';
  }
}

/// 冒险风故事模板
class AdventureTemplate implements StoryTemplate {
  @override
  String get name => '冒险风';

  @override
  String get description => '刺激有趣的探险旅程';

  @override
  String get icon => '🗺️';

  @override
  String buildPrompt(ChildInfo childInfo) {
    return '请为${childInfo.age}岁的${childInfo.name}创作一个精彩的冒险故事。'
        '孩子喜欢${childInfo.interests.join('、')}。'
        '故事要体现${childInfo.educationDirections.join('、')}的品质。'
        '情节要有趣但不吓人，适合睡前阅读。';
  }
}

/// 温馨风故事模板
class WarmTemplate implements StoryTemplate {
  @override
  String get name => '温馨风';

  @override
  String get description => '温暖治愈的日常小故事';

  @override
  String get icon => '🌙';

  @override
  String buildPrompt(ChildInfo childInfo) {
    return '请为${childInfo.age}岁的${childInfo.name}创作一个温馨治愈的故事。'
        '孩子喜欢${childInfo.interests.join('、')}。'
        '故事要体现${childInfo.educationDirections.join('、')}的品质。'
        '氛围要温暖安宁，帮助孩子安心入睡。';
  }
}

/// 启蒙风故事模板
class EducationTemplate implements StoryTemplate {
  @override
  String get name => '启蒙风';

  @override
  String get description => '寓教于乐的成长故事';

  @override
  String get icon => '📚';

  @override
  String buildPrompt(ChildInfo childInfo) {
    return '请为${childInfo.age}岁的${childInfo.name}创作一个寓教于乐的故事。'
        '孩子喜欢${childInfo.interests.join('、')}。'
        '重点培养${childInfo.educationDirections.join('、')}的品质。'
        '通过故事让孩子在快乐中学习成长。';
  }
}

/// 后端API调用服务
/// 负责与后端服务器进行HTTP通信
class ApiService {
  /// HTTP客户端
  final http.Client _client;

  /// 故事模板列表
  static final List<StoryTemplate> storyTemplates = [
    FairyTaleTemplate(),
    AdventureTemplate(),
    WarmTemplate(),
    EducationTemplate(),
  ];

  /// 构造函数
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// 根据风格获取对应的故事模板
  StoryTemplate? getTemplate(String styleName) {
    try {
      return storyTemplates.firstWhere((t) => t.name == styleName);
    } catch (_) {
      return storyTemplates.first; // 默认返回童话风
    }
  }

  /// 生成故事
  /// [childInfo] 孩子信息
  /// [token] 用户认证令牌（可选）
  /// 返回生成的故事对象
  Future<Story> generateStory(ChildInfo childInfo, {String? token}) async {
    try {
      // 获取对应的故事模板
      final template = getTemplate(childInfo.storyStyle);
      final prompt = template?.buildPrompt(childInfo) ?? '';

      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.generateStory}');
      final headers = token != null
          ? ApiConfig.authHeaders(token)
          : ApiConfig.defaultHeaders;

      final response = await _client
          .post(
            url,
            headers: headers,
            body: jsonEncode({
              'childName': childInfo.name,
              'age': childInfo.age,
              'interests': childInfo.interests,
              'educationDirections': childInfo.educationDirections,
              'storyStyle': childInfo.storyStyle,
              'prompt': prompt,
            }),
          )
          .timeout(Duration(milliseconds: ApiConfig.timeoutMs));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Story.fromJson(data['data']);
      } else {
        throw ApiException(
          message: '生成故事失败: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      throw ApiException(message: '网络连接失败: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: '生成故事时发生错误: $e');
    }
  }

  /// 检查VIP状态
  /// [userId] 用户ID
  /// [token] 用户认证令牌
  /// 返回VIP状态信息
  Future<Map<String, dynamic>> checkVipStatus(
      String userId, String token) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.checkVipStatus}');
      final response = await _client
          .get(
            url,
            headers: ApiConfig.authHeaders(token),
          )
          .timeout(Duration(milliseconds: ApiConfig.timeoutMs));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] as Map<String, dynamic>;
      } else {
        throw ApiException(
          message: '检查VIP状态失败: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      throw ApiException(message: '网络连接失败: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: '检查VIP状态时发生错误: $e');
    }
  }

  /// 激活VIP
  /// [userId] 用户ID
  /// [planId] 套餐ID
  /// [token] 用户认证令牌
  /// 返回激活结果
  Future<Map<String, dynamic>> activateVip(
      String userId, String planId, String token) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.activateVip}');
      final response = await _client
          .post(
            url,
            headers: ApiConfig.authHeaders(token),
            body: jsonEncode({
              'userId': userId,
              'planId': planId,
            }),
          )
          .timeout(Duration(milliseconds: ApiConfig.timeoutMs));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] as Map<String, dynamic>;
      } else {
        throw ApiException(
          message: '激活VIP失败: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      throw ApiException(message: '网络连接失败: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: '激活VIP时发生错误: $e');
    }
  }

  /// 释放资源
  void dispose() {
    _client.close();
  }
}

/// API异常类
class ApiException implements Exception {
  /// 错误信息
  final String message;

  /// HTTP状态码
  final int? statusCode;

  ApiException({required this.message, this.statusCode});

  @override
  String toString() => 'ApiException: $message (statusCode: $statusCode)';
}
