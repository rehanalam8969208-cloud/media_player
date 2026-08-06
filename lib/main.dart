import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:ui';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyMusicApp());
}

class MyMusicApp extends StatelessWidget {
  const MyMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Music',
      theme: ThemeData(
        fontFamily: 'Roboto',
        brightness: Brightness.light,
        primaryColor: const Color(0xFF0284C7),
      ),
      home: const MusicHomeScreen(),
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

class MusicHomeScreen extends StatefulWidget {
  const MusicHomeScreen({super.key});

  @override
  State<MusicHomeScreen> createState() => _MusicHomeScreenState();
}

class _MusicHomeScreenState extends State<MusicHomeScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<File> playlist = [];
  int currentIndex = -1;
  bool isPlaying = false;
  String currentSongName = "No song playing";

  @override
  void initState() {
    super.initState();
    _requestPermissionsOnStartup();

    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });
  }

  // App khulte hi storage aur notification ki permission maangne ke liye
  Future<void> _requestPermissionsOnStartup() async {
    await [
      Permission.storage,
      Permission.audio,
      Permission.notification,
    ].request();
  }

  // Phone se audio files select karne ke liye
  Future<void> _pickMusicFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        for (var path in result.paths) {
          if (path != null) {
            playlist.add(File(path));
          }
        }
      });
    }
  }

  void _playSong(int index) async {
    if (index < 0 || index >= playlist.length) return;
    currentIndex = index;
    File file = playlist[index];
    currentSongName = file.path.split('/').last;

    await _audioPlayer.stop();
    await _audioPlayer.play(DeviceFileSource(file.path));
    setState(() {});
  }

  void _togglePlayPause() async {
    if (currentIndex == -1 && playlist.isNotEmpty) {
      _playSong(0);
      return;
    }
    if (isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
  }

  void _playNext() {
    if (playlist.isEmpty) return;
    int nextIndex = (currentIndex + 1) % playlist.length;
    _playSong(nextIndex);
  }

  void _playPrevious() {
    if (playlist.isEmpty) return;
    int prevIndex = (currentIndex - 1 + playlist.length) % playlist.length;
    _playSong(prevIndex);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Light Foggy Blue Background (Lighthouse Theme)
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
                // Top Header Card
                GlassCard(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("OFFLINE PLAYER", style: TextStyle(color: Color(0xFF475569), fontSize: 12, fontWeight: FontWeight.bold)),
                          SizedBox(height: 2),
                          Text("My Music", style: TextStyle(color: Color(0xFF0F172A), fontSize: 24, fontWeight: FontWeight.w900)),
                        ],
                      ),
                      IconButton(
                        onPressed: _pickMusicFiles,
                        icon: const Icon(Icons.add_rounded, color: Color(0xFF0F172A), size: 30),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF0284C7).withOpacity(0.2),
                          shape: const CircleBorder(),
                        ),
                      )
                    ],
                  ),
                ),

                // Song List View
                Expanded(
                  child: playlist.isEmpty
                      ? const Center(
                          child: Text(
                            "No music added!\nTap '+' to import songs from your phone.",
                            style: TextStyle(color: Color(0xFF334155), fontWeight: FontWeight.bold, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: playlist.length,
                          itemBuilder: (context, index) {
                            final file = playlist[index];
                            final fileName = file.path.split('/').last;
                            final bool isCurrent = currentIndex == index;

                            return GestureDetector(
                              onTap: () => _playSong(index),
                              child: GlassCard(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: isCurrent ? const Color(0xFF0D9488).withOpacity(0.4) : const Color(0xFF0284C7).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Icon(
                                        isCurrent ? Icons.graphic_eq_rounded : Icons.music_note_rounded,
                                        color: const Color(0xFF0F172A),
                                        size: 26,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        fileName,
                                        style: TextStyle(
                                          color: isCurrent ? const Color(0xFF0D9488) : const Color(0xFF0F172A),
                                          fontSize: 16,
                                          fontWeight: isCurrent ? FontWeight.w900 : FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (isCurrent)
                                      const Icon(Icons.play_arrow_rounded, color: Color(0xFF0D9488), size: 28),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),

                // Bottom Mini Player Controls (Notification & UI Control Bar)
                if (playlist.isNotEmpty)
                  GlassCard(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          currentSongName,
                          style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.skip_previous_rounded, size: 36, color: Color(0xFF0F172A)),
                              onPressed: _playPrevious,
                            ),
                            IconButton(
                              icon: Icon(isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded, size: 50, color: const Color(0xFF0D9488)),
                              onPressed: _togglePlayPause,
                            ),
                            IconButton(
                              icon: const Icon(Icons.skip_next_rounded, size: 36, color: Color(0xFF0F172A)),
                              onPressed: _playNext,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
