// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const BedtimeStoryApp());
}

class BedtimeStoryApp extends StatelessWidget {
  const BedtimeStoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI睡前故事',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.latoTextTheme(),
        useMaterial3: true,
      ),
      home: const StoryPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class StoryPage extends StatefulWidget {
  const StoryPage({super.key});

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  final FlutterTts _flutterTts = FlutterTts();
  final TextEditingController _storyController = TextEditingController();
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("zh-CN");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
    
    // 设置语音完成回调
    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
      });
    });
  }

  Future<void> _speakStory() async {
    if (_storyController.text.isEmpty) {
      _showSnackBar('请先输入或选择故事内容');
      return;
    }
    
    setState(() {
      _isSpeaking = true;
    });
    await _flutterTts.speak(_storyController.text);
  }

  Future<void> _stopSpeaking() async {
    await _flutterTts.stop();
    setState(() {
      _isSpeaking = false;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI睡前故事',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 故事输入区域
            Expanded(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '故事内容',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: TextField(
                          controller: _storyController,
                          maxLines: null,
                          expands: true,
                          decoration: InputDecoration(
                            hintText: '输入你想要听的故事...\n\n例如：从前有一座美丽的城堡...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 示例故事按钮
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildStoryButton('🐻 小熊的冒险', '小熊在森林里迷路了，它遇到了许多动物朋友，最后在小兔子的帮助下找到了回家的路。'),
                _buildStoryButton('🌟 星星公主', '在遥远的星空王国，有一位善良的星星公主，她用魔法帮助了所有需要帮助的人。'),
                _buildStoryButton('🦁 勇敢的小狮子', '小狮子虽然年纪小，但非常勇敢，它保护了森林里的小动物们。'),
                _buildStoryButton('🌈 彩虹桥', '彩虹桥连接着两个世界，只有心存善良的人才能走过这座桥。'),
              ],
            ),
            const SizedBox(height: 16),
            
            // 控制按钮
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSpeaking ? null : _speakStory,
                    icon: const Icon(Icons.play_arrow, size: 28),
                    label: const Text(
                      '播放故事',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _stopSpeaking,
                    icon: const Icon(Icons.stop, size: 28),
                    label: const Text(
                      '停止',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // 状态指示
            if (_isSpeaking)
              Container(
                padding: const EdgeInsets.all(8),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text('正在播放故事...'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryButton(String title, String content) {
    return ActionChip(
      label: Text(title),
      onPressed: () {
        _storyController.text = content;
        _showSnackBar('已加载示例故事');
      },
      backgroundColor: Colors.deepPurple.shade100,
      elevation: 2,
    );
  }

  @override
  void dispose() {
    _storyController.dispose();
    _flutterTts.stop();
    super.dispose();
  }
}
