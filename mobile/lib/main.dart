import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey.shade50,
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final FlutterTts _flutterTts = FlutterTts();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _interestController = TextEditingController();
  String _selectedStyle = '童话';
  String _generatedStory = '';
  bool _isLoading = false;
  bool _isPlaying = false;

  final List<String> _storyStyles = ['童话', '冒险', '温馨', '启蒙'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _initTTS();
    _loadSavedData();
  }

  Future<void> _initTTS() async {
    await _flutterTts.setLanguage("zh-CN");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
    _flutterTts.setCompletionHandler(() {
      setState(() => _isPlaying = false);
    });
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('child_name') ?? '';
      _interestController.text = prefs.getString('child_interest') ?? '';
    });
  }

  Future<void> _saveChildInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('child_name', _nameController.text);
    await prefs.setString('child_interest', _interestController.text);
  }

  Future<void> _generateStory() async {
    if (_nameController.text.isEmpty) {
      _showSnackBar('请输入宝宝的名字');
      return;
    }

    await _saveChildInfo();

    setState(() {
      _isLoading = true;
      _generatedStory = '';
    });

    await Future.delayed(const Duration(seconds: 2));
    
    final stories = {
      '童话': '从前有一个美丽的花园，住着一位小公主${_nameController.text}。她善良勇敢，每天都和小动物们一起玩耍。',
      '冒险': '勇敢的${_nameController.text}踏上了寻找魔法宝石的冒险之旅，途中遇到了许多挑战。',
      '温馨': '在一个温暖的夜晚，${_nameController.text}和家人们围坐在火炉旁，分享着快乐的故事。',
      '启蒙': '${_nameController.text}今天学会了分享，他/她发现分享能让快乐加倍。',
    };
    
    setState(() {
      _generatedStory = stories[_selectedStyle]! + 
        ' ${_interestController.text.isNotEmpty ? '他/她特别喜欢$_interestController.text，这让他/她的冒险更加精彩。' : ''}';
      _isLoading = false;
    });
  }

  Future<void> _speakStory() async {
    if (_generatedStory.isNotEmpty) {
      setState(() => _isPlaying = true);
      await _flutterTts.speak(_generatedStory);
    }
  }

  Future<void> _stopStory() async {
    await _flutterTts.stop();
    setState(() => _isPlaying = false);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('AI睡前故事'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.deepPurple.shade400, Colors.purple.shade200],
                  ),
                ),
                child: Stack(
                  children: [
                    ...List.generate(20, (index) {
                      return Positioned(
                        left: (index * 50) % MediaQuery.of(context).size.width,
                        top: (index * 30) % 200,
                        child: AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, 5 * _animationController.value),
                              child: child,
                            );
                          },
                          child: Icon(
                            Icons.star,
                            color: Colors.white.withOpacity(0.3),
                            size: 20,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: '宝宝的名字',
                              prefixIcon: Icon(Icons.child_care),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _interestController,
                            decoration: const InputDecoration(
                              labelText: '兴趣爱好（可选）',
                              prefixIcon: Icon(Icons.favorite),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _selectedStyle,
                            decoration: const InputDecoration(
                              labelText: '故事风格',
                              prefixIcon: Icon(Icons.auto_stories),
                              border: OutlineInputBorder(),
                            ),
                            items: _storyStyles.map((style) {
                              return DropdownMenuItem(
                                value: style,
                                child: Text(style),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedStyle = value!);
                            },
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _generateStory,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator()
                                  : const Text('生成故事', style: TextStyle(fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_generatedStory.isNotEmpty)
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.auto_stories, color: Colors.deepPurple),
                                SizedBox(width: 8),
                                Text(
                                  '生成的故事',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _generatedStory,
                              style: const TextStyle(height: 1.5),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _isPlaying ? null : _speakStory,
                                    icon: const Icon(Icons.play_arrow),
                                    label: const Text('播放'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _stopStory,
                                    icon: const Icon(Icons.stop),
                                    label: const Text('停止'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _interestController.dispose();
    _flutterTts.stop();
    super.dispose();
  }
}
