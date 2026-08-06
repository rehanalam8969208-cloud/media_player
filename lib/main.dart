import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:ui';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MediaXApp());
}

class MediaXApp extends StatelessWidget {
  const MediaXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MediaX Offline Pro',
      theme: ThemeData(
        fontFamily: 'Roboto',
        brightness: Brightness.light,
        primaryColor: const Color(0xFF0284C7),
      ),
      home: const HomeScreen(),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;

  const GlassCard({super.key, required this.child, required this.margin, required this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.65),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  spreadRadius: 1,
                )
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0; // 0 for Videos, 1 for Music
  List<File> offlineVideos = [];
  List<File> offlineMusic = [];

  // Pick Offline Video from Device
  Future<void> _pickVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null && result.files.single.path != null) {
      setState(() {
        offlineVideos.add(File(result.files.single.path!));
      });
    }
  }

  // Pick Offline Music from Device
  Future<void> _pickMusic() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null && result.files.single.path != null) {
      setState(() {
        offlineMusic.add(File(result.files.single.path!));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Light Foggy Blue Background Theme (Lighthouse style)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF93C5FD),
                  Color(0xFF60A5FA),
                  Color(0xFF3B82F6),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                GlassCard(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("OFFLINE MEDIA PLAYER", style: TextStyle(color: Color(0xFF475569), fontSize: 12, fontWeight: FontWeight.bold)),
                          SizedBox(height: 2),
                          Text("MediaX Pro", style: TextStyle(color: Color(0xFF0F172A), fontSize: 24, fontWeight: FontWeight.w900)),
                        ],
                      ),
                      IconButton(
                        onPressed: _currentTab == 0 ? _pickVideo : _pickMusic,
                        icon: const Icon(Icons.add_rounded, color: Color(0xFF0F172A), size: 30),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF0284C7).withOpacity(0.2),
                          shape: const CircleBorder(),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: _currentTab == 0 ? _buildVideoList() : _buildMusicList(),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: BottomNavigationBar(
            backgroundColor: Colors.white.withOpacity(0.25),
            elevation: 0,
            currentIndex: _currentTab,
            selectedItemColor: const Color(0xFF0D9488),
            unselectedItemColor: const Color(0xFF475569),
            onTap: (index) => setState(() => _currentTab = index),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.video_library_rounded, size: 26), label: 'Local Videos'),
              BottomNavigationBarItem(icon: Icon(Icons.library_music_rounded, size: 26), label: 'Local Music'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoList() {
    if (offlineVideos.isEmpty) {
      return const Center(child: Text("No videos added! Tap '+' to select from phone.", style: TextStyle(color: Color(0xFF334155), fontWeight: FontWeight.bold), textAlign: TextAlign.center));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: offlineVideos.length,
      itemBuilder: (context, index) {
        final file = offlineVideos[index];
        final fileName = file.path.split('/').last;
        return GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => VideoPlayerScreen(videoFile: file, title: fileName)));
          },
          child: GlassCard(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.play_circle_fill_rounded, color: Color(0xFF0F172A), size: 36),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(fileName, style: const TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF475569), size: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMusicList() {
    if (offlineMusic.isEmpty) {
      return const Center(child: Text("No music added! Tap '+' to select from phone.", style: TextStyle(color: Color(0xFF334155), fontWeight: FontWeight.bold), textAlign: TextAlign.center));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: offlineMusic.length,
      itemBuilder: (context, index) {
        final file = offlineMusic[index];
        final fileName = file.path.split('/').last;
        return GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => MusicPlayerScreen(musicFile: file, title: fileName)));
          },
          child: GlassCard(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D9488).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.audiotrack_rounded, color: Color(0xFF0F172A), size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(fileName, style: const TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
                const Icon(Icons.play_arrow_rounded, color: Color(0xFF0D9488), size: 28),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Local Video Player Screen
class VideoPlayerScreen extends StatefulWidget {
  final File videoFile;
  final String title;
  const VideoPlayerScreen({super.key, required this.videoFile, required this.title});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.videoFile)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.transparent, title: Text(widget.title, style: const TextStyle(color: Colors.white)), iconTheme: const IconThemeData(color: Colors.white)),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0D9488),
        onPressed: () {
          setState(() {
            _isPlaying ? _controller.pause() : _controller.play();
            _isPlaying = !_isPlaying;
          });
        },
        child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
      ),
    );
  }
}

// Local Music Player Screen
class MusicPlayerScreen extends StatefulWidget {
  final File musicFile;
  final String title;
  const MusicPlayerScreen({super.key, required this.musicFile, required this.title});

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _playMusic();
  }

  void _playMusic() async {
    await _audioPlayer.play(DeviceFileSource(widget.musicFile.path));
    setState(() => _isPlaying = true);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF93C5FD), Color(0xFF3B82F6)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Color(0xFF0F172A))),
              const Spacer(),
              GlassCard(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
                    const Icon(Icons.music_note_rounded, size: 80, color: Color(0xFF0D9488)),
                    const SizedBox(height: 20),
                    Text(widget.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 40),
                    IconButton(
                      iconSize: 64,
                      color: const Color(0xFF0D9488),
                      icon: Icon(_isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded),
                      onPressed: () async {
                        if (_isPlaying) {
                          await _audioPlayer.pause();
                        } else {
                          await _audioPlayer.resume();
                        }
                        setState(() => _isPlaying = !_isPlaying);
                      },
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
