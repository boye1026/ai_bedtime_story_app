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

  // 回调函数
  VoidCallback? onStart;
  VoidCallback? onComplete;
  Function(String)? onError;

  Future<void> init() async {
    try {
      // 设置语言为中文
      await _flutterTts.setLanguage("zh-CN");
      // 设置语速 (0.0-1.0)
      await _flutterTts.setSpeechRate(0.5);
      // 设置音调 (0.5-2.0)
      await _flutterTts.setPitch(1.0);
      // 设置音量 (0.0-1.0)
      await _flutterTts.setVolume(1.0);

      // 设置事件回调
      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
        _isPaused = false;
        onStart?.call();
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        _isPaused = false;
        onComplete?.call();
      });

      _flutterTts.setErrorHandler((msg) {
        _isSpeaking = false;
        _isPaused = false;
        onError?.call(msg);
      });

      _flutterTts.setCancelHandler(() {
        _isSpeaking = false;
        _isPaused = false;
      });
    } catch (e) {
      debugPrint('TTS初始化错误: $e');
    }
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;

    try {
      await stop();
      _currentText = text;
      int result = await _flutterTts.speak(text);
      if (result == 0) {
        _isSpeaking = true;
        _isPaused = false;
      } else {
        onError?.call('朗读失败');
      }
    } catch (e) {
      debugPrint('TTS朗读错误: $e');
      onError?.call(e.toString());
    }
  }

  Future<void> pause() async {
    try {
      int result = await _flutterTts.pause();
      if (result == 0) {
        _isPaused = true;
        _isSpeaking = false;
      }
    } catch (e) {
      debugPrint('TTS暂停错误: $e');
    }
  }

  Future<void> resume() async {
    try {
      if (_isPaused) {
        int result = await _flutterTts.speak(_currentText);
        if (result == 0) {
          _isSpeaking = true;
          _isPaused = false;
        }
      }
    } catch (e) {
      debugPrint('TTS恢复错误: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _isSpeaking = false;
      _isPaused = false;
    } catch (e) {
      debugPrint('TTS停止错误: $e');
    }
  }

  bool get isSpeaking => _isSpeaking;
  bool get isPaused => _isPaused;

  void dispose() {
    stop();
    _flutterTts.setStartHandler(null);
    _flutterTts.setCompletionHandler(null);
    _flutterTts.setErrorHandler(null);
    _flutterTts.setCancelHandler(null);
  }
}
