import 'package:flutter_tts/flutter_tts.dart';

/// 语音朗读服务
/// 使用系统TTS引擎实现故事的语音朗读功能
class TtsService {
  /// flutter_tts实例
  final FlutterTts _flutterTts;

  /// 当前是否正在播放
  bool _isPlaying = false;

  /// 当前是否处于暂停状态
  bool _isPaused = false;

  /// 播放进度回调
  void Function(String text, int start, int end, String word)? onProgress;

  /// 播放完成回调
  VoidCallback? onCompleted;

  /// 播放开始回调
  VoidCallback? onStart;

  /// 播放错误回调
  void Function(String message)? onError;

  /// 获取当前播放状态
  bool get isPlaying => _isPlaying;

  /// 获取当前暂停状态
  bool get isPaused => _isPaused;

  /// 构造函数
  TtsService() : _flutterTts = FlutterTts() {
    _initTts();
  }

  /// 初始化TTS配置
  Future<void> _initTts() async {
    try {
      // 设置语言为中文
      await _flutterTts.setLanguage('zh-CN');

      // 设置语速：0.8（适中偏慢，适合睡前故事）
      await _flutterTts.setSpeechRate(0.8);

      // 设置音调：1.2（稍高，适合童声效果）
      await _flutterTts.setPitch(1.2);

      // 设置音量
      await _flutterTts.setVolume(1.0);

      // 设置音频流为媒体
      await _flutterTts.setAudioCategory('media');

      // 注册回调
      _flutterTts.setStartHandler(() {
        _isPlaying = true;
        _isPaused = false;
        onStart?.call();
      });

      _flutterTts.setCompletionHandler(() {
        _isPlaying = false;
        _isPaused = false;
        onCompleted?.call();
      });

      _flutterTts.setCancelHandler(() {
        _isPlaying = false;
        _isPaused = false;
      });

      _flutterTts.setPauseHandler(() {
        _isPaused = true;
        _isPlaying = false;
      });

      _flutterTts.setContinueHandler(() {
        _isPaused = false;
        _isPlaying = true;
      });

      _flutterTts.setErrorHandler((msg) {
        _isPlaying = false;
        _isPaused = false;
        onError?.call(msg);
      });

      _flutterTts.setProgressHandler((text, start, end, word) {
        onProgress?.call(text, start, end, word);
      });
    } catch (e) {
      // TTS初始化失败，静默处理
      // 在实际使用中可以记录日志
    }
  }

  /// 播放文本
  /// [text] 要朗读的文本内容
  Future<void> speak(String text) async {
    try {
      // 如果正在播放，先停止
      if (_isPlaying || _isPaused) {
        await stop();
      }
      await _flutterTts.speak(text);
    } catch (e) {
      onError?.call('播放失败: $e');
    }
  }

  /// 暂停播放
  Future<void> pause() async {
    try {
      await _flutterTts.pause();
    } catch (e) {
      onError?.call('暂停失败: $e');
    }
  }

  /// 继续播放
  Future<void> resume() async {
    try {
      await _flutterTts.resume();
    } catch (e) {
      onError?.call('继续播放失败: $e');
    }
  }

  /// 停止播放
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _isPlaying = false;
      _isPaused = false;
    } catch (e) {
      onError?.call('停止失败: $e');
    }
  }

  /// 释放资源
  Future<void> dispose() async {
    await stop();
    try {
      await _flutterTts.stop();
    } catch (_) {}
  }
}
