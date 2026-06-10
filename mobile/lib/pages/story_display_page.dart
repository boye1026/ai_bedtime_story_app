import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/tts_service.dart';

// 修复图标错误的部分
class StoryDisplayPage extends StatefulWidget {
  final String storyTitle;
  final String storyContent;
  final dynamic childInfo;
  final String? imageUrl;

  const StoryDisplayPage({
    Key? key,
    required this.storyTitle,
    required this.storyContent,
    this.childInfo,
    this.imageUrl,
  }) : super(key: key);

  @override
  State<StoryDisplayPage> createState() => _StoryDisplayPageState();
}

class _StoryDisplayPageState extends State<StoryDisplayPage> {
  final TTSService _ttsService = TTSService();
  bool _isPlaying = false;
  bool _isPaused = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initTTS();
  }

  Future<void> _initTTS() async {
    await _ttsService.init();
    setState(() {});
  }

  @override
  void dispose() {
    _ttsService.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.storyTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),  // 修复：使用 Icons.share
            onPressed: _shareStory,
          ),
        ],
      ),
      body: Column(
        children: [
          // 播放控制栏
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause_circle : 
                    (_isPaused ? Icons.play_circle : Icons.play_circle),
                    size: 48,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: _togglePlayback,
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.stop_circle, size: 48),  // 修复：使用 Icons.stop_circle
                  onPressed: _stopPlayback,
                  color: Colors.red,
                ),
              ],
            ),
          ),
          // 故事内容
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Text(
                widget.storyContent,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _togglePlayback() {
    if (_isPlaying) {
      _ttsService.pause();
      setState(() {
        _isPlaying = false;
        _isPaused = true;
      });
    } else {
      if (_isPaused) {
        _ttsService.resume();
      } else {
        _ttsService.speak(widget.storyContent);
      }
      setState(() {
        _isPlaying = true;
        _isPaused = false;
      });
    }
  }

  void _stopPlayback() {
    _ttsService.stop();
    setState(() {
      _isPlaying = false;
      _isPaused = false;
    });
  }

  Future<void> _shareStory() async {
    // 分享逻辑
  }
}
