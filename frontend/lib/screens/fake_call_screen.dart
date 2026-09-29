import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
class FakeCallScreen extends StatefulWidget {
  const FakeCallScreen({super.key});

  @override
  State<FakeCallScreen> createState() => _FakeCallScreenState();
}

class _FakeCallScreenState extends State<FakeCallScreen> {
  final TextEditingController callerController =
      TextEditingController(text: 'Mom');

  int selectedDelay = 5;
  Timer? timer;

  bool callStarted = false;

  @override
  void dispose() {
    timer?.cancel();
    callerController.dispose();
    super.dispose();
  }

  void startFakeCall() {
    final callerName = callerController.text.trim();

    if (callerName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter caller name'),
        ),
      );
      return;
    }

    setState(() {
      callStarted = true;
    });

    timer = Timer(
      Duration(seconds: selectedDelay),
      () {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => IncomingCallScreen(
              callerName: callerName,
            ),
          ),
        );
      },
    );
  }

  void cancelFakeCall() {
    timer?.cancel();

    setState(() {
      callStarted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Fake Call',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.phone_callback,
              size: 60,
              color: Colors.pink,
            ),

            const SizedBox(height: 20),

            const Text(
              'Fake Call Simulator',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Schedule a simulated incoming call when you need a reason to step away from an uncomfortable situation.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 35),

            TextField(
              controller: callerController,
              enabled: !callStarted,
              decoration: const InputDecoration(
                labelText: 'Caller Name',
                hintText: 'e.g. Mom, Dad, Friend',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Call after',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 10,
              children: [5, 10, 30].map((seconds) {
                return ChoiceChip(
                  label: Text('$seconds sec'),
                  selected: selectedDelay == seconds,
                  onSelected: callStarted
                      ? null
                      : (selected) {
                          if (selected) {
                            setState(() {
                              selectedDelay = seconds;
                            });
                          }
                        },
                );
              }).toList(),
            ),

            const Spacer(),

            if (callStarted)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  onPressed: cancelFakeCall,
                  icon: const Icon(Icons.close),
                  label: const Text(
                    'CANCEL FAKE CALL',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: startFakeCall,
                  icon: const Icon(Icons.phone),
                  label: const Text(
                    'START FAKE CALL',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 15),

            Center(
              child: Text(
                'For safety situations only',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ============================================================
// INCOMING CALL SCREEN
// ============================================================

class IncomingCallScreen extends StatefulWidget {
  final String callerName;

  const IncomingCallScreen({
    super.key,
    required this.callerName,
  });

  @override
  State<IncomingCallScreen> createState() =>
      _IncomingCallScreenState();
}
class _IncomingCallScreenState extends State<IncomingCallScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _startRingtone();
  }

  Future<void> _startRingtone() async {
    try {
      await HapticFeedback.vibrate();

      await _audioPlayer.setReleaseMode(
        ReleaseMode.loop,
      );

      await _audioPlayer.play(
        AssetSource('sounds/ringtone.mp3'),
      );
    } catch (e) {
      debugPrint('Ringtone error: $e');
    }
  }

  Future<void> _stopRingtone() async {
    await _audioPlayer.stop();
    await _audioPlayer.dispose();
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  void acceptCall() async {
    await _stopRingtone();

    if (!mounted) return;

    Navigator.pop(context);
  }

  void declineCall() async {
    await _stopRingtone();

    if (!mounted) return;

    Navigator.pop(context);
  }

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 80),

            const Text(
              'Incoming Call',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 35),

            const CircleAvatar(
              radius: 65,
              backgroundColor: Colors.white24,
              child: Icon(
                Icons.person,
                size: 75,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 25),

            Text(
              widget.callerName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Mobile',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 16,
              ),
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 55,
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      FloatingActionButton(
                        heroTag: 'decline',
                        backgroundColor: Colors.red,
                      onPressed: declineCall,
                        child: const Icon(
                          Icons.call_end,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Decline',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  Column(
                    children: [
                      FloatingActionButton(
                        heroTag: 'accept',
                        backgroundColor: Colors.green,
                       onPressed: acceptCall,
                        child: const Icon(
                          Icons.call,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Accept',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}