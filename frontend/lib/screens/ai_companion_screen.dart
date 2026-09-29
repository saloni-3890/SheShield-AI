import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';

import '../services/ai_service.dart';
import '../services/sos_service.dart';
class AiCompanionScreen extends StatefulWidget {
  const AiCompanionScreen({super.key});

  @override
  State<AiCompanionScreen> createState() => _AiCompanionScreenState();
}

class _AiCompanionScreenState extends State<AiCompanionScreen> {
  final TextEditingController _problemController = TextEditingController();

  bool _loading = false;
  Map<String, dynamic>? _result;
  String? _error;
final SosService _sosService = SosService();
  Future<void> _analyzeProblem() async {
    final problem = _problemController.text.trim();

    if (problem.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please describe your problem first.'),
        ),
      );
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });

    try {
      final result = await AiService.analyzeProblem(problem);

      if (!mounted) return;

      setState(() {
        _result = result;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'Unable to analyze your problem. Please try again.';
      });
    }
  }
  Future<void> _activateSosFromAi() async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Activate Emergency SOS?'),
        content: const Text(
          'This will share your current location and alert your emergency contacts.\n\n'
          'Only continue if you are in immediate danger.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('ACTIVATE SOS'),
          ),
        ],
      );
    },
  );

  if (confirmed != true) return;

  try {
    if (!mounted) return;

    setState(() {
      _loading = true;
    });

    await _sosService.activateSOS();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '🚨 SOS Activated!\n'
          'Location saved and emergency contacts notified.',
        ),
        duration: Duration(seconds: 5),
      ),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('SOS failed: $e'),
        duration: const Duration(seconds: 4),
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }
}
Future<void> _callEmergency() async {
  final uri = Uri.parse('tel:112');


  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Unable to open emergency dialer.'),
      ),
    );
  }
}
Future<void> _shareCurrentLocation() async {
  try {
    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location permission is required.'),
        ),
      );
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    final lat = position.latitude;
    final lng = position.longitude;

    final mapsLink =
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng';

    await SharePlus.instance.share(
      ShareParams(
        text: '''
🚨 I may need help.

📍 My current location:
$mapsLink

Latitude: $lat
Longitude: $lng
''',
      ),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Unable to share location: $e'),
      ),
    );
  }
}

  @override
  void dispose() {
    _problemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'SheShield AI',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'What’s bothering you?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Tell SheShield AI what is happening. '
                'We’ll help you understand the situation and decide what to do next.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 24),

              TextField(
                controller: _problemController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText:
                      'Describe your situation or problem...',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(18),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _analyzeProblem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Analyze Situation',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              if (_error != null)
                _buildError(),

              if (_result != null)
                _buildResult(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        _error!,
        style: TextStyle(
          color: Colors.red.shade700,
        ),
      ),
    );
  }

  Widget _buildResult() {
  final category = _result?['category'] ?? 'GENERAL';
  final riskLevel = _result?['riskLevel'] ?? 'NOT_APPLICABLE';
  final summary = _result?['summary'] ?? '';

  final keyPoints =
      List<String>.from(_result?['keyPoints'] ?? []);

  final actionPlan =
      List<String>.from(_result?['actionPlan'] ?? []);

  final whenToSeekHelp =
      _result?['whenToSeekHelp'] ?? '';

  final supportMessage =
      _result?['supportMessage'] ?? '';
  final safetyRecommendation =
    _result?['safetyRecommendation'] ?? '';

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Category
      _buildSectionTitle('Problem Category'),
      _buildCard(
        child: Row(
          children: [
            const Icon(
              Icons.psychology,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                category.replaceAll('_', ' '),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),

      const SizedBox(height: 16),

      // Risk Level
      _buildSectionTitle('Risk Level'),
      _buildCard(
        child: Text(
          riskLevel,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      const SizedBox(height: 16),

      // Situation
      _buildSectionTitle('Situation'),
      _buildCard(
        child: Text(
          summary,
          style: const TextStyle(
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ),

      const SizedBox(height: 16),

      // Key Points
      if (keyPoints.isNotEmpty) ...[
        _buildSectionTitle('Key Points'),
        _buildList(keyPoints),
        const SizedBox(height: 16),
      ],

      // Action Plan
      if (actionPlan.isNotEmpty) ...[
        _buildSectionTitle('Action Plan'),
        _buildList(actionPlan),
        const SizedBox(height: 16),
      ],

      // When to seek help
      if (whenToSeekHelp.isNotEmpty &&
          whenToSeekHelp != 'NOT_APPLICABLE') ...[
        _buildSectionTitle('When to Seek Help'),
        _buildCard(
          child: Text(
            whenToSeekHelp,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
      // Safety Recommendation
if (safetyRecommendation.isNotEmpty &&
    safetyRecommendation != 'NOT_APPLICABLE') ...[
  _buildSectionTitle('Safety Recommendation'),
  _buildCard(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.shield_outlined,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            safetyRecommendation,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  ),
  const SizedBox(height: 16),
],
      // Emergency Actions
      if (riskLevel == 'HIGH' || riskLevel == 'CRITICAL') ...[
        _buildSectionTitle('Immediate Safety Actions'),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _callEmergency,
            icon: const Icon(Icons.call),
            label: const Text(
              'CALL EMERGENCY 112',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
SizedBox(
  width: double.infinity,
  height: 52,
  child: OutlinedButton.icon(
    onPressed: _shareCurrentLocation,
    icon: const Icon(Icons.location_on),
    label: const Text(
      'SHARE MY LOCATION',
      style: TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
    style: OutlinedButton.styleFrom(
      foregroundColor: Colors.black,
      side: const BorderSide(color: Colors.black),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
  ),
),
 const SizedBox(height: 12),

SizedBox(
  width: double.infinity,
  height: 52,
  child: ElevatedButton.icon(
    onPressed: _loading ? null : _activateSosFromAi,
    icon: const Icon(Icons.warning_rounded),
    label: const Text(
      'ACTIVATE SOS',
      style: TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
  ),
),

const SizedBox(height: 16),
        const SizedBox(height: 16),
      ],
      // Support message
      if (supportMessage.isNotEmpty) ...[
        _buildSectionTitle('A Message for You'),
        _buildCard(
          child: Text(
            supportMessage,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ),
      ],
    ],
  );
}

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }

  Widget _buildList(List<String> items) {
    return Column(
      children: items.map((item) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '✓ ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}