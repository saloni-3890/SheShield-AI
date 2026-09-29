import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SirenScreen extends StatefulWidget {
  const SirenScreen({super.key});

  @override
  State<SirenScreen> createState() => _SirenScreenState();
}

class _SirenScreenState extends State<SirenScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool isPlaying = false;

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> startSiren() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);

      await _audioPlayer.play(
        AssetSource('sounds/siren.wav'),
      );

      await HapticFeedback.vibrate();

      if (!mounted) return;

      setState(() {
        isPlaying = true;
      });
    } catch (e) {
      debugPrint('Siren error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to start siren: $e'),
        ),
      );
    }
  }

  Future<void> stopSiren() async {
    await _audioPlayer.stop();

    if (!mounted) return;

    setState(() {
      isPlaying = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Emergency Siren',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),

            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isPlaying ? 190 : 160,
              height: isPlaying ? 190 : 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isPlaying
                    ? Colors.red.shade100
                    : Colors.pink.shade50,
              ),
              child: Center(
                child: Icon(
                  Icons.notifications_active,
                  size: 85,
                  color: isPlaying
                      ? Colors.red
                      : Colors.pink,
                ),
              ),
            ),

            const SizedBox(height: 35),

            Text(
              isPlaying
                  ? 'SIREN ACTIVE'
                  : 'Emergency Siren',
              style: const TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              isPlaying
                  ? 'The alarm is currently playing.'
                  : 'Use the siren to attract attention when you feel unsafe.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton.icon(
                onPressed: isPlaying
                    ? stopSiren
                    : startSiren,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isPlaying ? Colors.red : Colors.pink,
                  foregroundColor: Colors.white,
                ),
                icon: Icon(
                  isPlaying
                      ? Icons.stop
                      : Icons.volume_up,
                ),
                label: Text(
                  isPlaying
                      ? 'STOP SIREN'
                      : 'START SIREN',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            Text(
              'Use responsibly in emergency situations.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}