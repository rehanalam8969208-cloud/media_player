import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
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
      title: 'MediaX Pro',
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

  final List<Map<String, String>> sampleVideos = [
    {
      'title': 'Nature Foggy Morning',
      'url': 'https://assets.mixkit.co/videos/preview/mixkit-forest-stream-in-the-fog-4228-large.mp4',
      'duration': '0:45'
    },
    {
      'title': 'Ocean Waves Relax',
      'url': 'https://assets.mixkit.co/videos/preview/mixkit-sea-ocean-waves-coastal-view-1159-large.mp4',
      'duration': '0:30'
    },
  ];

  final List<Map<String, String>> sampleMusic = [
    {
      'title': 'Peaceful Acoustic Guitar',
      'artist': 'AudioLibrary',
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'
    },
    {
      'title': 'Ambient Chill Sound',
      'artist': 'Relaxing Beats',
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3'
    },
  ];

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
                          Text("MEDIA PLAYER", style: TextStyle(color: Color(0xFF475569), fontSize: 12, fontWeight: FontWeight.bold)),
                          SizedBox(height: 2),
                          Text("MediaX Pro", style: TextStyle(color: Color(0xFF0F172A), fontSize: 24, fontWeight: FontWeight.w900)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7).withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF0284C7), width: 1.5),
                        ),
                        child: const Icon(Icons.play_arrow_rounded, color: Color(0xFF0F172A), size: 24),
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
              BottomNavigationBarItem(icon: Icon(Icons.video_library_rounded, size: 26), label: 'Videos'),
              BottomNavigationBarItem(icon: Icon(Icons.music_note_rounded, size: 26), label: 'Music'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sampleVideos.length,
      itemBuilder: (context, index) {
        final video = sampleVideos[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => VideoPlayerScreen(videoUrl: video['url']!, title: video['title']!)));
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(video['title']!, style: const TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text("Duration: ${video['duration']}", style: const TextStyle(color: Color(0xFF475569), fontSize: 13)),
                    ],
                  ),
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
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sampleMusic.length,
      itemBuilder: (context, index) {
        final music = sampleMusic[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => MusicPlayerScreen(musicUrl: music['url']!, title: music['title']!, artist: music['artist']!)));
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(music['title']!, style: const TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(music['artist']!, style: const TextStyle(color: Color(0xFF475569), fontSize: 13)),
                    ],
                  ),
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

// Full Video Player Screen
class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String title;
  const VideoPlayerScreen({super.key, required this.videoUrl, required this.title});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
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

// Music Player Screen
class MusicPlayerScreen extends StatefulWidget {
  final String musicUrl;
  final String title;
  final String artist;
  const MusicPlayerScreen({super.key, required this.musicUrl, required this.title, required this.artist});

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
    await _audioPlayer.play(UrlSource(widget.musicUrl));
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
                    Text(widget.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)), textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text(widget.artist, style: const TextStyle(fontSize: 16, color: Color(0xFF475569)), textAlign: TextAlign.center),
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
