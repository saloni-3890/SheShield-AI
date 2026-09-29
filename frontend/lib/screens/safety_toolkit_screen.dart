import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'fake_call_screen.dart';
import 'location_share_screen.dart';
import 'siren_screen.dart';
class SafetyToolkitScreen extends StatelessWidget {
  const SafetyToolkitScreen({super.key});

  Future<void> _callNumber(
    BuildContext context,
    String number,
  ) async {
    final uri = Uri.parse('tel:$number');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to call $number'),
        ),
      );
    }
  }

  void _showSafetyTips(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              20,
              10,
              20,
              30,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Quick Safety Tips',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                _Tip(
                  icon: Icons.people_outline,
                  title: 'Stay Around People',
                  text:
                      'Move towards a busy or well-lit public place if you feel unsafe.',
                ),
                _Tip(
                  icon: Icons.phone_in_talk_outlined,
                  title: 'Contact Someone You Trust',
                  text:
                      'Keep a trusted person informed when you are in an uncomfortable situation.',
                ),
                _Tip(
                  icon: Icons.location_on_outlined,
                  title: 'Share Your Location',
                  text:
                      'Share your current location with someone you trust when appropriate.',
                ),
                _Tip(
                  icon: Icons.warning_amber_outlined,
                  title: 'Trust Your Instincts',
                  text:
                      'If something feels wrong, prioritize your safety and leave the situation.',
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Safety Toolkit',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.pink.shade50,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.shield,
                    size: 45,
                    color: Colors.pink,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Be Prepared',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 7),
                  Text(
                    'Quick-access tools and resources for situations where every second matters.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Emergency Tools',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: _ToolkitCard(
                    icon: Icons.phone_callback_outlined,
                    title: 'Fake Call',
                    subtitle: 'Create a fake incoming call',
                   onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const FakeCallScreen(),
    ),
  );
},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ToolkitCard(
                    icon: Icons.notifications_active_outlined,
                    title: 'Siren',
                    subtitle: 'Emergency alarm',
                    onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const SirenScreen(),
    ),
  );
},
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _ToolkitCard(
                    icon: Icons.contacts_outlined,
                    title: 'Contacts',
                    subtitle: 'Access trusted contacts',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/emergency-contacts',
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ToolkitCard(
                    icon: Icons.location_on_outlined,
                    title: 'Location',
                    subtitle: 'Location safety tools',
                  onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const LocationShareScreen(),
    ),
  );
},
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            const Text(
              'Emergency Helplines',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            _HelplineCard(
              title: 'Emergency',
              subtitle: 'Police • Ambulance • Fire',
              number: '112',
              icon: Icons.emergency,
              onCall: () {
                _callNumber(context, '112');
              },
            ),

            const SizedBox(height: 12),

            _HelplineCard(
              title: 'Women Helpline',
              subtitle: 'Women safety assistance',
              number: '181',
              icon: Icons.support_agent,
              onCall: () {
                _callNumber(context, '181');
              },
            ),

            const SizedBox(height: 28),

            const Text(
              'Safety Knowledge',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            _ToolkitCard(
              icon: Icons.lightbulb_outline,
              title: 'Quick Safety Tips',
              subtitle:
                  'Simple things to remember during difficult situations',
              fullWidth: true,
              onTap: () {
                _showSafetyTips(context);
              },
            ),

            const SizedBox(height: 15),

            _ToolkitCard(
              icon: Icons.auto_awesome,
              title: 'Ask SheShield AI',
              subtitle:
                  'Get personalized guidance for your situation',
              fullWidth: true,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/ai-companion',
                );
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _ToolkitCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool fullWidth;

  const _ToolkitCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: Colors.pink.shade50,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: Colors.pink,
                  size: 25,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios,
                size: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HelplineCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String number;
  final IconData icon;
  final VoidCallback onCall;

  const _HelplineCard({
    required this.title,
    required this.subtitle,
    required this.number,
    required this.icon,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              child: Icon(icon),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            Text(
              number,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(width: 10),

            IconButton(
              onPressed: onCall,
              icon: const Icon(Icons.call),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tip extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _Tip({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.pink,
            size: 28,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    height: 1.4,
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