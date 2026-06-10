import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  String _currentText = '';
  bool _isSpeaking = false;
  bool _isPaused = false;

  VoidCallback? onStart;
  VoidCallback? onComplete;
  Function(String)? onError;

  Future<void> init() async {
    try {
      await _flutterTts.setLanguage("zh-CN");
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setVolume(1.0);

      // 设置回调 - 修复 Null 错误
      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
        _isPaused = false;
        if (onStart != null) onStart!();
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        _isPaused = false;
        if (onComplete != null) onComplete!();
      });

      _flutterTts.setErrorHandler((msg) {
        _isSpeaking = false;
        _isPaused = false;
        if (onError != null) onError!(msg);
      });

      _flutterTts.setCancelHandler(() {
        _isSpeaking = false;
        _isPaused = false;
      });
    } catch (e) {
      debugPrint('TTS初始化错误: $e');
    }
  }

  // ... 其他方法保持不变
}
